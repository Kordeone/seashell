import QtQuick

import qs.core
import qs.styles

Item {
    id: root

    width: 676
    height: 44
    z: open ? 200 : 1

    property bool open: false

    readonly property QtObject activeStyle:
        Styles.byId(Config.styleId)

    Rectangle {
        id: control

        anchors.fill: parent

        radius: Theme.radiusMedium
        color: Theme.surface

        border {
            width: root.open ? 2 : Theme.borderWidth
            color: root.open ? Theme.focus : Theme.border
        }

        Rectangle {
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }

            width: 58
            height: 22

            radius: Math.min(
                7,
                root.activeStyle.barRadius
            )

            color: Qt.rgba(
                Theme.background.r,
                Theme.background.g,
                Theme.background.b,
                root.activeStyle.panelOpacity
            )

            border {
                width: root.activeStyle.borderWidth
                color: Theme.border
            }

            Text {
                anchors.centerIn: parent

                text: "SEA"
                color: Theme.accent

                font {
                    family: root.activeStyle.fontUI
                    pixelSize: 9
                    bold: true
                }
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: 84
                verticalCenter: parent.verticalCenter
            }

            text: root.activeStyle.name
            color: Theme.foreground

            font {
                family: Theme.fontUI
                pixelSize: 12
                bold: true
            }
        }

        Text {
            anchors {
                right: parent.right
                rightMargin: 14
                verticalCenter: parent.verticalCenter
            }

            text: root.open ? "▲" : "▼"
            color: Theme.foregroundMuted

            font {
                family: Theme.fontMono
                pixelSize: 9
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.open = !root.open
            }
        }
    }

    Rectangle {
        id: popup

        visible: root.open

        anchors {
            left: parent.left
            right: parent.right
            top: control.bottom
            topMargin: 6
        }

        height:
            (Styles.all.length * 44) + 12

        radius: Theme.radiusMedium

        color: Qt.rgba(
            Theme.surfaceRaised.r,
            Theme.surfaceRaised.g,
            Theme.surfaceRaised.b,
            Theme.popupOpacity
        )

        border {
            width: Theme.borderWidth
            color: Theme.border
        }

        Column {
            anchors {
                fill: parent
                margins: 6
            }

            Repeater {
                model: Styles.all

                delegate: Rectangle {
                    required property int index
                    required property var modelData

                    width: parent.width
                    height: 44

                    radius: Theme.radiusSmall

                    color:
                        Config.styleId === modelData.key
                            ? Theme.surface
                            : "transparent"

                    Rectangle {
                        anchors {
                            left: parent.left
                            leftMargin: 8
                            verticalCenter: parent.verticalCenter
                        }

                        width: 52
                        height: 20

                        radius: Math.min(
                            7,
                            modelData.barRadius
                        )

                        color: Qt.rgba(
                            Theme.background.r,
                            Theme.background.g,
                            Theme.background.b,
                            modelData.panelOpacity
                        )

                        border {
                            width: modelData.borderWidth
                            color: Theme.border
                        }
                    }

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 72
                            verticalCenter: parent.verticalCenter
                        }

                        text: modelData.name

                        color:
                            Config.styleId === modelData.key
                                ? Theme.accent
                                : Theme.foreground

                        font {
                            family: modelData.fontUI
                            pixelSize: 11
                            bold:
                                Config.styleId === modelData.key
                        }
                    }

                    Text {
                        visible:
                            Config.styleId === modelData.key

                        anchors {
                            right: parent.right
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }

                        text: "ACTIVE"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 8
                            bold: true
                            letterSpacing: 1
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            Config.styleId = modelData.key
                            root.open = false
                        }
                    }
                }
            }
        }
    }
}
