import QtQuick

import qs.core

Rectangle {
    id: root

    required property QtObject paletteModel
    required property bool selected
    required property bool highlighted

    signal chosen()

    width: 160
    height: 98

    radius: Theme.radiusMedium
    color: Theme.surface

    border {
        width: selected || highlighted ? 2 : Theme.borderWidth

        color: highlighted
            ? Theme.focus
            : selected
                ? Theme.accent
                : Theme.border
    }

    Row {
        anchors {
            left: parent.left
            top: parent.top

            leftMargin: 12
            topMargin: 12
        }

        spacing: 4

        Rectangle {
            width: 22
            height: 22
            radius: Theme.radiusSmall
            color: paletteModel.background
        }

        Rectangle {
            width: 22
            height: 22
            radius: Theme.radiusSmall
            color: paletteModel.surfaceRaised
        }

        Rectangle {
            width: 22
            height: 22
            radius: Theme.radiusSmall
            color: paletteModel.accent
        }

        Rectangle {
            width: 22
            height: 22
            radius: Theme.radiusSmall
            color: paletteModel.warning
        }

        Rectangle {
            width: 22
            height: 22
            radius: Theme.radiusSmall
            color: paletteModel.danger
        }
    }

    Text {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom

            leftMargin: 12
            rightMargin: 8
            bottomMargin: 25
        }

        text: paletteModel.name
        color: Theme.foreground
        elide: Text.ElideRight

        font {
            family: Theme.fontUI
            pixelSize: 11
            bold: true
        }
    }

    Text {
        anchors {
            left: parent.left
            bottom: parent.bottom

            leftMargin: 12
            bottomMargin: 9
        }

        text: selected ? "ACTIVE" : ""
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

        onClicked: root.chosen()
    }
}
