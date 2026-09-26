import QtQuick
import Quickshell
import Quickshell.Widgets

import qs.core

Item {
    id: root
    required property string tab
    property string applicationQuery: ""

    readonly property var sourceRows: [
        { id: "applications", name: "Applications", description: "Installed desktop applications", available: true },
        { id: "actions", name: "Seashell Actions", description: "Settings and shell commands", available: true },
        { id: "web-apps", name: "Web Apps", description: "Coming later", available: false },
        { id: "shortcuts", name: "Shortcuts", description: "Coming later", available: false },
        { id: "calculator", name: "Calculator", description: "Coming later", available: false },
        { id: "clipboard", name: "Clipboard", description: "Coming later", available: false },
        { id: "files", name: "Files", description: "Coming later", available: false }
    ]

    function visibleApplications(entries, query) {
        const needle = query.trim().toLowerCase()
        return [...entries].filter(entry =>
            !needle || (entry.name || "").toLowerCase().includes(needle)
                || (entry.id || "").toLowerCase().includes(needle)
        ).sort((a, b) =>
            (a.name || "").localeCompare(b.name || "") || a.id.localeCompare(b.id)
        )
    }

    Flickable {
        anchors.fill: parent
        visible: root.tab === "sources"
        clip: true
        contentWidth: width
        contentHeight: sourceContent.implicitHeight

        Column {
            id: sourceContent
            width: parent.width
            spacing: 8

        Text {
            text: "LAUNCHER SOURCES"
            color: Theme.foreground
            font.family: Theme.fontUI
            font.pixelSize: 14
            font.bold: true
        }

        Text {
            text: "Choose which sources appear in the unified search."
            color: Theme.foregroundMuted
            font.family: Theme.fontUI
            font.pixelSize: 10
        }

            Repeater {
            model: root.sourceRows
            delegate: Rectangle {
                required property var modelData
                activeFocusOnTab: modelData.available
                width: parent.width
                height: 49
                radius: Theme.radiusSmall
                color: Theme.surface
                border.width: Theme.borderWidth
                border.color: activeFocus ? Theme.focus : Theme.border
                opacity: modelData.available ? 1 : 0.55

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                            || event.key === Qt.Key_Space) {
                        LauncherModel.setSourceEnabled(modelData.id,
                            !LauncherModel.sourceEnabled(modelData.id))
                        event.accepted = true
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    Text {
                        text: modelData.name
                        color: Theme.foreground
                        font.family: Theme.fontUI
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Text {
                        text: modelData.description
                        color: Theme.foregroundMuted
                        font.family: Theme.fontUI
                        font.pixelSize: 8
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.available
                        ? (LauncherModel.sourceEnabled(modelData.id) ? "ON" : "OFF")
                        : "LATER"
                    color: modelData.available && LauncherModel.sourceEnabled(modelData.id)
                        ? Theme.accent : Theme.foregroundMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: modelData.available
                    cursorShape: Qt.PointingHandCursor
                    onClicked: LauncherModel.setSourceEnabled(
                        modelData.id, !LauncherModel.sourceEnabled(modelData.id))
                }
            }
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: root.tab === "applications"

        Text {
            id: heading
            text: "APPLICATIONS"
            color: Theme.foreground
            font.family: Theme.fontUI
            font.pixelSize: 14
            font.bold: true
        }

        Text {
            id: help
            anchors.top: heading.bottom
            anchors.topMargin: 5
            text: "Hide apps from Seashell without changing their desktop entries."
            color: Theme.foregroundMuted
            font.family: Theme.fontUI
            font.pixelSize: 10
        }

        Rectangle {
            id: searchBox
            anchors.top: help.bottom
            anchors.topMargin: 14
            width: parent.width
            height: 38
            radius: Theme.radiusSmall
            color: Theme.surface
            border.width: Theme.borderWidth
            border.color: appSearch.activeFocus ? Theme.focus : Theme.border

            TextInput {
                id: appSearch
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.foreground
                selectionColor: Theme.accent
                selectedTextColor: Theme.accentForeground
                font.family: Theme.fontUI
                font.pixelSize: 11
                onTextChanged: root.applicationQuery = text
            }
            Text {
                visible: appSearch.text.length === 0
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "Search applications…"
                color: Theme.foregroundDisabled
                font.family: Theme.fontUI
                font.pixelSize: 11
            }
        }

        ListView {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: searchBox.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: 10
            clip: true
            spacing: 4
            model: root.visibleApplications(
                DesktopEntries.applications.values, root.applicationQuery)

            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: 50
                radius: Theme.radiusSmall
                color: Theme.surface
                border.width: Theme.borderWidth
                border.color: Theme.border

                readonly property bool hidden: LauncherModel.isHidden(modelData.id)

                IconImage {
                    id: icon
                    anchors.left: parent.left
                    anchors.leftMargin: 9
                    anchors.verticalCenter: parent.verticalCenter
                    width: 30
                    height: 30
                    source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                    asynchronous: true
                }
                Column {
                    anchors.left: icon.right
                    anchors.leftMargin: 10
                    anchors.right: action.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
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
                        text: hidden ? "HIDDEN · " + modelData.id : modelData.id
                        elide: Text.ElideRight
                        color: hidden ? Theme.warning : Theme.foregroundMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 8
                    }
                }
                Rectangle {
                    id: action
                    activeFocusOnTab: true
                    anchors.right: parent.right
                    anchors.rightMargin: 9
                    anchors.verticalCenter: parent.verticalCenter
                    width: 70
                    height: 28
                    radius: Theme.radiusSmall
                    color: hidden ? Theme.surfaceRaised : Theme.background
                    border.width: Theme.borderWidth
                    border.color: activeFocus ? Theme.focus : Theme.border
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                || event.key === Qt.Key_Space) {
                            LauncherModel.setHidden(modelData.id, !hidden)
                            event.accepted = true
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: hidden ? "SHOW" : "HIDE"
                        color: hidden ? Theme.accent : Theme.foregroundMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 8
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: LauncherModel.setHidden(modelData.id, !hidden)
                    }
                }
            }
        }
    }
}
