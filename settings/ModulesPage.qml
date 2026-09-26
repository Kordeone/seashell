import QtQuick

import qs.core

Item {
    Flickable {
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: content.implicitHeight

        Column {
            id: content
            width: parent.width
            spacing: 10

            Text {
                text: "MODULE PROVIDERS"
                color: Theme.foreground
                font.family: Theme.fontUI
                font.pixelSize: 14
                font.bold: true
            }
            Text {
                text: "Select one implementation for each category."
                color: Theme.foregroundMuted
                font.family: Theme.fontUI
                font.pixelSize: 10
            }
            Text {
                topPadding: 8
                text: "BAR"
                color: Theme.accent
                font.family: Theme.fontMono
                font.pixelSize: 10
                font.bold: true
            }

            Repeater {
                model: ModuleManager.barProviders
                delegate: Rectangle {
                    required property var modelData
                    width: parent.width
                    height: 82
                    radius: Theme.radiusSmall
                    color: Theme.surface
                    border.width: Theme.borderWidth
                    border.color: ModuleManager.isActive("bar", modelData.id)
                        ? Theme.accent : Theme.border

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 13
                        anchors.right: providerAction.left
                        anchors.rightMargin: 8
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
                            text: modelData.builtIn ? "BUILT IN · INSTALLED"
                                : ModuleManager.waybarInstalled
                                    ? "INSTALLED · THEME SYNC"
                                    : "NOT INSTALLED · pacman -S --needed waybar"
                            color: Theme.foregroundMuted
                            font.family: Theme.fontMono
                            font.pixelSize: 8
                        }
                    }

                    Rectangle {
                        id: providerAction
                        activeFocusOnTab: !active
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 78
                        height: 30
                        radius: Theme.radiusSmall
                        color: Theme.surfaceRaised
                        border.width: Theme.borderWidth
                        border.color: activeFocus ? Theme.focus : Theme.border

                        readonly property bool active:
                            ModuleManager.isActive("bar", modelData.id)
                        readonly property bool canInstall:
                            modelData.id === "waybar"
                            && !ModuleManager.waybarInstalled
                            && ModuleManager.pkexecInstalled
                            && ModuleManager.pacmanInstalled
                            && !ModuleManager.installationRunning

                        function choose() {
                            if (active || (modelData.id === "waybar"
                                    && !ModuleManager.waybarInstalled && !canInstall))
                                return
                            if (modelData.id === "waybar" && !ModuleManager.waybarInstalled)
                                ModuleManager.installWaybar()
                            else
                                ModuleManager.activate("bar", modelData.id)
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                    || event.key === Qt.Key_Space) {
                                providerAction.choose()
                                event.accepted = true
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: providerAction.active ? "ACTIVE"
                                : modelData.id === "waybar" && !ModuleManager.waybarInstalled
                                    ? "INSTALL" : "USE"
                            color: providerAction.active ? Theme.accent : Theme.foreground
                            font.family: Theme.fontMono
                            font.pixelSize: 8
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: !providerAction.active
                                && (modelData.id !== "waybar"
                                    || ModuleManager.waybarInstalled
                                    || providerAction.canInstall)
                            cursorShape: Qt.PointingHandCursor
                            onClicked: providerAction.choose()
                        }
                    }
                }
            }

            Text {
                visible: ModuleManager.statusMessage.length > 0
                width: parent.width
                wrapMode: Text.Wrap
                text: ModuleManager.statusMessage
                color: Theme.foregroundMuted
                font.family: Theme.fontUI
                font.pixelSize: 9
            }
            Text {
                visible: !ModuleManager.waybarInstalled
                    && (!ModuleManager.pkexecInstalled || !ModuleManager.pacmanInstalled)
                text: "Installation needs pkexec and pacman on this system."
                color: Theme.warning
                font.family: Theme.fontUI
                font.pixelSize: 9
            }
            Text {
                topPadding: 15
                text: "COMING LATER"
                color: Theme.foregroundMuted
                font.family: Theme.fontMono
                font.pixelSize: 9
                font.bold: true
            }
            Repeater {
                model: ModuleManager.categories.filter(category => !category.ready)
                delegate: Rectangle {
                    required property var modelData
                    width: parent.width
                    height: 34
                    radius: Theme.radiusSmall
                    color: Theme.surface
                    opacity: 0.6
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name
                        color: Theme.foregroundMuted
                        font.family: Theme.fontUI
                        font.pixelSize: 9
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "LATER"
                        color: Theme.foregroundMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 8
                    }
                }
            }
        }
    }
}
