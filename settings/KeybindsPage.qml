import QtQuick

import qs.core

Item {
    id: root
    property string capturingId: ""
    property string proposed: ""
    property string message: ""

    focus: true
    onVisibleChanged: {
        if (!visible) {
            capturingId = ""
            proposed = ""
            message = ""
            HyprlandShortcuts.cancelPending()
        }
    }

    Keys.onPressed: event => {
        if (!capturingId)
            return
        event.accepted = true
        if (event.key === Qt.Key_Escape && event.modifiers === Qt.NoModifier) {
            capturingId = ""
            proposed = ""
            message = ""
            return
        }
        const value = Keybinds.fromEvent(event)
        if (!value)
            return
        proposed = Keybinds.normalized(value)
        const duplicate = Keybinds.duplicate(capturingId, proposed)
        message = duplicate ? "Already used by " + duplicate.name + "." : ""
    }

    Column {
        anchors.fill: parent
        spacing: 11

        Text {
            text: "SEASHELL SHORTCUTS"
            color: Theme.foreground
            font.family: Theme.fontUI
            font.pixelSize: 14
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.Wrap
            text: "Hyprland owns physical keys. Seashell registers stable logical shortcuts, then writes their physical mappings to a Seashell-owned Hyprland include."
            color: Theme.foregroundMuted
            font.family: Theme.fontUI
            font.pixelSize: 9
        }

        Repeater {
            model: Keybinds.actions
            delegate: Rectangle {
                required property var modelData
                width: parent.width
                height: 90 + ((HyprlandShortcuts.conflicts[modelData.id] || []).length ? 25 : 0)
                radius: Theme.radiusSmall
                color: Theme.surface
                border.width: Theme.borderWidth
                border.color: (HyprlandShortcuts.conflicts[modelData.id] || []).length
                    ? Theme.warning : Theme.border

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: buttons.left
                    anchors.rightMargin: 9
                    anchors.top: parent.top
                    anchors.topMargin: 9
                    spacing: 3

                    Text {
                        width: parent.width
                        text: modelData.name
                        elide: Text.ElideRight
                        color: Theme.foreground
                        font.family: Theme.fontUI
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Text {
                        width: parent.width
                        text: "Current: " + (root.capturingId === modelData.id
                            ? (root.proposed || "PRESS KEYS…")
                            : (Keybinds.binding(modelData.id) || "UNASSIGNED"))
                        elide: Text.ElideRight
                        color: root.capturingId === modelData.id ? Theme.accent : Theme.foreground
                        font.family: Theme.fontMono
                        font.pixelSize: 8
                        font.bold: true
                    }
                    Text {
                        width: parent.width
                        text: modelData.defaultBinding
                            ? "Default: " + modelData.defaultBinding : "Default: none"
                        color: Theme.foregroundMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 7
                    }
                    Text {
                        width: parent.width
                        visible: (HyprlandShortcuts.conflicts[modelData.id] || []).length > 0
                        text: {
                            const conflicts = HyprlandShortcuts.conflicts[modelData.id] || []
                            return conflicts.length ? "CONFLICT · " + conflicts[0].owner
                                + " · source: " + conflicts[0].source : ""
                        }
                        elide: Text.ElideRight
                        color: Theme.warning
                        font.family: Theme.fontMono
                        font.pixelSize: 7
                    }
                }

                Row {
                    id: buttons
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Rectangle {
                        id: changeButton
                        activeFocusOnTab: true
                        width: 56
                        height: 28
                        radius: Theme.radiusSmall
                        color: Theme.surfaceRaised
                        border.width: Theme.borderWidth
                        border.color: activeFocus ? Theme.focus : Theme.border
                        function choose() {
                            if (root.capturingId !== modelData.id) {
                                root.capturingId = modelData.id
                                root.proposed = ""
                                root.message = ""
                                HyprlandShortcuts.cancelPending()
                                root.forceActiveFocus()
                            } else if (root.proposed) {
                                const accepted = HyprlandShortcuts.requestApply(
                                    modelData.id, root.proposed, false)
                                if (accepted) {
                                    root.capturingId = ""
                                    root.proposed = ""
                                } else if (!HyprlandShortcuts.pendingApply) {
                                    root.message = HyprlandShortcuts.issue
                                }
                            }
                        }
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                    || event.key === Qt.Key_Space) {
                                changeButton.choose()
                                event.accepted = true
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: root.capturingId === modelData.id ? "APPLY" : "CHANGE"
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: 7
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: changeButton.choose()
                        }
                    }

                    Rectangle {
                        activeFocusOnTab: true
                        width: 48
                        height: 28
                        radius: Theme.radiusSmall
                        color: Theme.background
                        border.width: Theme.borderWidth
                        border.color: activeFocus ? Theme.focus : Theme.border
                        function choose() {
                            HyprlandShortcuts.cancelPending()
                            if (modelData.defaultBinding) {
                                const accepted = HyprlandShortcuts.requestApply(
                                    modelData.id, modelData.defaultBinding, true)
                                if (accepted) {
                                    root.capturingId = ""
                                    root.proposed = ""
                                }
                            } else {
                                HyprlandShortcuts.requestClear(modelData.id)
                            }
                        }
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                    || event.key === Qt.Key_Space) {
                                choose()
                                event.accepted = true
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: modelData.defaultBinding ? "RESET" : "CLEAR"
                            color: Theme.foregroundMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 7
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: parent.choose()
                        }
                    }
                }
            }
        }

        Text {
            visible: root.message.length > 0 || HyprlandShortcuts.issue.length > 0
            width: parent.width
            wrapMode: Text.Wrap
            text: root.message || HyprlandShortcuts.issue
            color: Theme.warning
            font.family: Theme.fontUI
            font.pixelSize: 9
        }
        Text {
            width: parent.width
            wrapMode: Text.Wrap
            text: Keybinds.backendStatus + "\n" + HyprlandShortcuts.generatedStatus
            color: Theme.foregroundMuted
            font.family: Theme.fontMono
            font.pixelSize: 7
        }
    }

    Rectangle {
            anchors.fill: parent
            visible: !!HyprlandShortcuts.pendingApply
            z: 100
            color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.78)
            MouseArea { anchors.fill: parent }

            Rectangle {
                anchors.centerIn: parent
                width: Math.min(360, parent.width - 20)
                height: conflictInfo.implicitHeight + 93
                radius: Theme.radiusMedium
                color: Theme.surfaceRaised
                border.width: Theme.borderWidth
                border.color: Theme.warning

                Column {
                    id: conflictInfo
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 15
                    spacing: 7

                    Text {
                        text: "Replace this Hyprland binding?"
                        color: Theme.foreground
                        font.family: Theme.fontUI
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.Wrap
                        text: "Hyprland currently assigns " + HyprlandShortcuts.pendingApply.binding
                            + " to another action. Confirming records the displaced bind and writes an unbind plus the Seashell logical shortcut into the generated include. Hyprland must load that include for the replacement to take effect."
                        color: Theme.foregroundMuted
                        font.family: Theme.fontUI
                        font.pixelSize: 9
                    }
                    Repeater {
                        model: HyprlandShortcuts.pendingConflicts
                        delegate: Text {
                            required property var modelData
                            width: parent.width
                            wrapMode: Text.Wrap
                            text: modelData.owner + "\n" + modelData.source
                            color: Theme.warning
                            font.family: Theme.fontMono
                            font.pixelSize: 7
                        }
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 12
                    spacing: 7

                    Rectangle {
                        width: 70
                        height: 28
                        radius: Theme.radiusSmall
                        color: Theme.background
                        border.width: Theme.borderWidth
                        border.color: Theme.border
                        Text {
                            anchors.centerIn: parent
                            text: "CANCEL"
                            color: Theme.foregroundMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 7
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: HyprlandShortcuts.cancelPending()
                        }
                    }
                    Rectangle {
                        width: 93
                        height: 28
                        radius: Theme.radiusSmall
                        color: Theme.surface
                        border.width: Theme.borderWidth
                        border.color: Theme.warning
                        Text {
                            anchors.centerIn: parent
                            text: "REPLACE"
                            color: Theme.warning
                            font.family: Theme.fontMono
                            font.pixelSize: 7
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (HyprlandShortcuts.confirmReplace()) {
                                    root.capturingId = ""
                                    root.proposed = ""
                                }
                            }
                        }
                    }
                }
            }
    }
}
