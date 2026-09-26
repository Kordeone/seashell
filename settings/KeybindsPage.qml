import QtQuick

import qs.core

Item {
    id: root
    property string capturingId: ""
    property string proposed: ""
    property string message: ""
    property var captureButton: null

    focus: true

    onVisibleChanged: {
        if (!visible) {
            capturingId = ""
            proposed = ""
            captureButton = null
            message = ""
        }
    }

    Keys.onPressed: event => {
        if (!capturingId)
            return
        event.accepted = true
        if (event.key === Qt.Key_Escape) {
            capturingId = ""
            proposed = ""
            message = ""
            captureButton = null
            return
        }
        const value = Keybinds.fromEvent(event)
        if (!value)
            return
        proposed = value
        const conflict = Keybinds.duplicate(capturingId, value)
        message = conflict ? "Already used by " + conflict.name : ""
        if (!conflict && captureButton)
            captureButton.forceActiveFocus()
    }

    Column {
        anchors.fill: parent
        spacing: 12

        Text {
            text: "SEASHELL SHORTCUTS"
            color: Theme.foreground
            font.family: Theme.fontUI
            font.pixelSize: 14
            font.bold: true
        }
        Text {
            text: "Click Change, press a combination, then Apply. Escape cancels."
            color: Theme.foregroundMuted
            font.family: Theme.fontUI
            font.pixelSize: 10
        }

        Repeater {
            model: Keybinds.actions
            delegate: Rectangle {
                required property var modelData
                width: parent.width
                height: 78
                radius: Theme.radiusSmall
                color: Theme.surface
                border.width: Theme.borderWidth
                border.color: Theme.border

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 13
                    anchors.right: controls.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Text {
                        text: modelData.name
                        color: Theme.foreground
                        font.family: Theme.fontUI
                        font.pixelSize: 11
                        font.bold: true
                    }
                    Text {
                        text: modelData.description
                        color: Theme.foregroundMuted
                        font.family: Theme.fontUI
                        font.pixelSize: 8
                    }
                    Text {
                        text: (root.capturingId === modelData.id
                            ? (root.proposed || "PRESS KEYS…")
                            : Keybinds.binding(modelData.id)).replace(/\+/g, " + ")
                        color: root.capturingId === modelData.id
                            ? Theme.accent : Theme.foreground
                        font.family: Theme.fontMono
                        font.pixelSize: 9
                        font.bold: true
                    }
                }

                Row {
                    id: controls
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Rectangle {
                        id: changeButton
                        activeFocusOnTab: true
                        width: 62
                        height: 29
                        radius: Theme.radiusSmall
                        color: Theme.surfaceRaised
                        border.width: Theme.borderWidth
                        border.color: activeFocus ? Theme.focus : Theme.border
                        function choose() {
                            if (root.capturingId !== modelData.id) {
                                root.capturingId = modelData.id
                                root.proposed = ""
                                root.message = ""
                                root.captureButton = changeButton
                                root.forceActiveFocus()
                            } else if (root.proposed) {
                                if (Keybinds.setBinding(modelData.id, root.proposed)) {
                                    root.capturingId = ""
                                    root.proposed = ""
                                    root.message = ""
                                    root.captureButton = null
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
                            font.pixelSize: 8
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: changeButton.choose()
                        }
                    }
                    Rectangle {
                        id: resetButton
                        activeFocusOnTab: true
                        width: 54
                        height: 29
                        radius: Theme.radiusSmall
                        color: Theme.background
                        border.width: Theme.borderWidth
                        border.color: activeFocus ? Theme.focus : Theme.border
                        function choose() {
                            if (!Keybinds.reset(modelData.id))
                                root.message = "Default conflicts with another Seashell shortcut"
                            else
                                root.message = ""
                            root.capturingId = ""
                            root.proposed = ""
                            root.captureButton = null
                        }
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                    || event.key === Qt.Key_Space) {
                                resetButton.choose()
                                event.accepted = true
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "RESET"
                            color: Theme.foregroundMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 8
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: resetButton.choose()
                        }
                    }
                }
            }
        }

        Text {
            visible: root.message.length > 0
            text: root.message
            color: Theme.warning
            font.family: Theme.fontUI
            font.pixelSize: 10
        }

        Text {
            width: parent.width
            wrapMode: Text.Wrap
            text: "Backend: Hyprland global shortcuts · " + Keybinds.backendStatus
            color: Theme.foregroundMuted
            font.family: Theme.fontMono
            font.pixelSize: 8
        }
    }
}
