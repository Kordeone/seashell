import QtQuick
import Quickshell

import qs.core

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight

    Rectangle {
        anchors.fill: parent
        color: Theme.background

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            height: Theme.borderWidth
            color: Theme.border
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: 14
                verticalCenter: parent.verticalCenter
            }

            text: "SEA"
            color: Theme.accent

            font {
                family: Theme.fontFamily
                pixelSize: 13
                bold: true
                letterSpacing: 2
            }
        }

        Text {
            anchors.centerIn: parent

            text: Config.shellName.toUpperCase()
            color: Theme.foreground

            font {
                family: Theme.fontFamily
                pixelSize: 12
                bold: true
                letterSpacing: 3
            }
        }

        Text {
            anchors {
                right: parent.right
                rightMargin: 14
                verticalCenter: parent.verticalCenter
            }

            text: "SHELL 01"
            color: Theme.muted

            font {
                family: Theme.fontFamily
                pixelSize: 11
                letterSpacing: 1
            }
        }
    }
}
