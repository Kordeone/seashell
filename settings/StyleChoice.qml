import QtQuick

import qs.core

Rectangle {
    id: root

    required property QtObject styleModel
    required property bool selected
    required property bool highlighted

    signal chosen()

    width: 320
    height: 132

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

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top

            leftMargin: 16
            rightMargin: 16
            topMargin: 16
        }

        height: 48

        radius: styleModel.barRadius > 10
            ? 10
            : styleModel.barRadius

        color: Qt.rgba(
            Theme.background.r,
            Theme.background.g,
            Theme.background.b,
            styleModel.panelOpacity
        )

        border {
            width: styleModel.borderWidth
            color: Theme.border
        }

        Text {
            anchors.centerIn: parent

            text: "SEA     •     01"
            color: Theme.foreground

            font {
                family: styleModel.fontUI
                pixelSize: 11
                bold: true
            }
        }
    }

    Text {
        anchors {
            left: parent.left
            leftMargin: 16
            bottom: parent.bottom
            bottomMargin: 30
        }

        text: styleModel.name
        color: Theme.foreground

        font {
            family: Theme.fontUI
            pixelSize: 13
            bold: true
        }
    }

    Text {
        anchors {
            left: parent.left
            leftMargin: 16
            bottom: parent.bottom
            bottomMargin: 12
        }

        text: selected ? "ACTIVE" : "SELECT"
        color: selected
            ? Theme.accent
            : Theme.foregroundMuted

        font {
            family: Theme.fontMono
            pixelSize: 9
            bold: selected
            letterSpacing: 1
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: root.chosen()
    }
}
