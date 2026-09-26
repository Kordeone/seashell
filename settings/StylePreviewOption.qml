import QtQuick

import qs.core

Rectangle {
    id: root

    required property var styleData

    readonly property bool selected:
        Config.styleId === styleData.key

    height: 62

    radius: Theme.radiusMedium

    color:
        selected
            ? Theme.surfaceRaised
            : Theme.surface

    border {
        width: selected ? 2 : Theme.borderWidth
        color: selected ? Theme.accent : Theme.border
    }

    // Tiny live geometry sample.
    Rectangle {
        anchors {
            left: parent.left
            leftMargin: 14
            verticalCenter: parent.verticalCenter
        }

        width: 76
        height: 26

        radius: Math.min(
            9,
            root.styleData.barRadius
        )

        color: Qt.rgba(
            Theme.background.r,
            Theme.background.g,
            Theme.background.b,
            root.styleData.panelOpacity
        )

        border {
            width: root.styleData.borderWidth
            color: Theme.border
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            visible:
                root.styleData.barRadius === 0

            height: 1
            color: Theme.accent
            antialiasing: false
        }

        Text {
            anchors.centerIn: parent

            text: "SEA"

            color: Theme.accent

            font {
                family: root.styleData.fontUI
                pixelSize: 9
                bold: true
                letterSpacing: 1
            }
        }
    }

    Column {
        anchors {
            left: parent.left
            leftMargin: 108
            verticalCenter: parent.verticalCenter
        }

        spacing: 3

        Text {
            text: root.styleData.name

            color:
                root.selected
                    ? Theme.accent
                    : Theme.foreground

            font {
                family: Theme.fontUI
                pixelSize: 12
                bold: true
            }
        }

        Text {
            text:
                root.styleData.barRadius === 0
                    ? "Sharp · dense · direct"
                    : "Floating · soft · glass"

            color: Theme.foregroundMuted

            font {
                family: Theme.fontUI
                pixelSize: 9
            }
        }
    }

    Rectangle {
        visible: root.selected

        anchors {
            right: parent.right
            rightMargin: 14
            verticalCenter: parent.verticalCenter
        }

        width: 8
        height: 8
        radius: 4

        color: Theme.accent
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked:
            Config.styleId = root.styleData.key
    }
}
