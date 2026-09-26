import QtQuick

import qs.core
import qs.styles

Rectangle {
    id: root

    required property string labelText
    required property string familyValue

    property bool styleDefault: false

    readonly property string previewFamily:
        styleDefault
            ? Styles.byId(Config.styleId).fontUI
            : familyValue

    readonly property bool selected:
        styleDefault
            ? Config.fontFamily === Typography.styleDefaultKey
            : Config.fontFamily === familyValue

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

    // All font cards use identical coordinates.
    Text {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top

            leftMargin: 13
            rightMargin: 13
            topMargin: 10
        }

        text: root.labelText

        color:
            root.selected
                ? Theme.accent
                : Theme.foreground

        elide: Text.ElideRight

        font {
            family: root.previewFamily
            pixelSize: 11
            bold: true
        }
    }

    Text {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom

            leftMargin: 13
            rightMargin: 13
            bottomMargin: 9
        }

        text:
            root.styleDefault
                ? root.previewFamily
                : "Aa 0123"

        color: Theme.foregroundMuted

        elide: Text.ElideRight

        font {
            family: root.previewFamily
            pixelSize: 9
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            Config.fontFamily =
                root.styleDefault
                    ? Typography.styleDefaultKey
                    : root.familyValue
        }
    }
}
