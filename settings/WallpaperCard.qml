import QtQuick

import qs.core

Rectangle {
    id: root

    required property var wallpaperData

    property bool selected: false
    property bool active: false
    property bool selectable: false
    property bool disabled: false

    signal toggled(string path)

    height: 110

    radius: Theme.radiusMedium

    color:
        selected
            ? Theme.surfaceRaised
            : Theme.surface

    opacity:
        disabled
            ? 0.42
            : 1.0

    border {
        width:
            selected
                ? 2
                : Theme.borderWidth

        color:
            selected
                ? Theme.accent
                : cardMouse.containsMouse
                  && selectable
                    ? Theme.focus
                    : Theme.border
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top

            margins: 5
        }

        height: 73

        radius: Theme.radiusSmall
        clip: true

        color: Theme.background

        Image {
            anchors.fill: parent

            source:
                root.wallpaperData.source

            fillMode:
                Image.PreserveAspectCrop

            horizontalAlignment:
                Image.AlignHCenter

            verticalAlignment:
                Image.AlignVCenter

            asynchronous: true
            cache: true
            smooth: true
        }

        Rectangle {
            visible:
                root.selected

            anchors {
                left: parent.left
                top: parent.top
                margins: 5
            }

            width: 20
            height: 20
            radius: 4

            color: Theme.accent

            Text {
                anchors.centerIn: parent

                text: "✓"

                color:
                    Theme.accentForeground

                font {
                    family: Theme.fontUI
                    pixelSize: 10
                    bold: true
                }
            }
        }

        Rectangle {
            visible:
                root.active

            anchors {
                right: parent.right
                top: parent.top
                margins: 5
            }

            width: 44
            height: 18
            radius: 4

            color: Theme.accent

            Text {
                anchors.centerIn: parent

                text: "ACTIVE"

                color:
                    Theme.accentForeground

                font {
                    family: Theme.fontMono
                    pixelSize: 6
                    bold: true
                }
            }
        }
    }

    Text {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom

            leftMargin: 8
            rightMargin: 8
            bottomMargin: 7
        }

        text:
            root.wallpaperData.displayName

        elide:
            Text.ElideMiddle

        color:
            selected
                ? Theme.accent
                : Theme.foreground

        font {
            family: Theme.fontUI
            pixelSize: 8
            bold: selected
        }
    }

    MouseArea {
        id: cardMouse

        anchors.fill: parent

        enabled:
            root.selectable
            && !root.disabled

        hoverEnabled: true

        cursorShape:
            enabled
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

        onClicked:
            root.toggled(
                root.wallpaperData.path
            )
    }
}
