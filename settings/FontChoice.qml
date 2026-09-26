import QtQuick

import qs.core

Rectangle {
    id: root

    required property string fontKey
    required property string displayName
    required property string previewFamily
    required property bool selected
    required property bool highlighted

    signal chosen()

    width: 160
    height: 72

    radius: Theme.radiusMedium
    color: Theme.surface

    border {
        width: selected || highlighted
            ? 2
            : Theme.borderWidth

        color: highlighted
            ? Theme.focus
            : selected
                ? Theme.accent
                : Theme.border
    }

    Text {
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 12
            topMargin: 9
        }

        text: "Aa 12"
        color: Theme.foreground

        font {
            family: root.previewFamily
            pixelSize: 16
        }
    }

    Text {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom

            leftMargin: 12
            rightMargin: 8
            bottomMargin: 9
        }

        text: root.displayName
        color: selected
            ? Theme.accent
            : Theme.foregroundMuted

        elide: Text.ElideRight

        font {
            family: root.previewFamily
            pixelSize: 10
            bold: selected
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: root.chosen()
    }
}
