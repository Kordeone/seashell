import QtQuick

import qs.core

Rectangle {
    id: root

    required property var paletteData

    readonly property bool selected:
        Config.paletteId === paletteData.key

    readonly property var swatches: [
        paletteData.accent,
        paletteData.focus,
        paletteData.warning,
        paletteData.success,
        paletteData.danger
    ]

    height: 60

    radius: Theme.radiusMedium

    color:
        selected
            ? Theme.surfaceRaised
            : Theme.surface

    border {
        width: selected ? 2 : Theme.borderWidth
        color: selected ? Theme.accent : Theme.border
    }

    Row {
        anchors {
            left: parent.left
            leftMargin: 13
            top: parent.top
            topMargin: 11
        }

        spacing: 5

        Repeater {
            model: root.swatches

            delegate: Rectangle {
                required property var modelData

                width: 17
                height: 12

                radius: 3
                color: modelData
            }
        }
    }

    Text {
        anchors {
            left: parent.left
            leftMargin: 13
            bottom: parent.bottom
            bottomMargin: 9
        }

        text: root.paletteData.name

        color:
            root.selected
                ? Theme.accent
                : Theme.foreground

        elide: Text.ElideRight

        width: parent.width - 26

        font {
            family: Theme.fontUI
            pixelSize: 10
            bold: root.selected
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked:
            Config.paletteId = root.paletteData.key
    }
}
