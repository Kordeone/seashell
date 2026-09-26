import QtQuick

import qs.core

Item {
    id: root

    property string sectionName: ""
    property var items: []

    Text {
        id: title

        anchors {
            left: parent.left
            top: parent.top
        }

        text:
            root.sectionName.toUpperCase()

        color: Theme.foreground

        font {
            family: Theme.fontUI
            pixelSize: 16
            bold: true
        }
    }

    Text {
        anchors {
            left: parent.left
            right: parent.right
            top: title.bottom
            topMargin: 7
        }

        text:
            "Planned Seashell capabilities for this section."

        color: Theme.foregroundMuted

        font {
            family: Theme.fontUI
            pixelSize: 9
        }
    }

    Column {
        anchors {
            left: parent.left
            right: parent.right
            top: title.bottom
            topMargin: 38
        }

        spacing: 6

        Repeater {
            model: root.items

            delegate: Rectangle {
                required property string modelData

                width: parent.width
                height: 38

                radius: Theme.radiusSmall

                color: Theme.surface

                border {
                    width: Theme.borderWidth
                    color: Theme.border
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        leftMargin: 11
                        verticalCenter:
                            parent.verticalCenter
                    }

                    width: 6
                    height: 6
                    radius: 3

                    color: Theme.accent
                    opacity: 0.72
                }

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 29
                        verticalCenter:
                            parent.verticalCenter
                    }

                    text: modelData

                    color: Theme.foreground

                    font {
                        family: Theme.fontUI
                        pixelSize: 9
                    }
                }

                Text {
                    anchors {
                        right: parent.right
                        rightMargin: 12
                        verticalCenter:
                            parent.verticalCenter
                    }

                    text: "PLANNED"

                    color:
                        Theme.foregroundDisabled

                    font {
                        family: Theme.fontMono
                        pixelSize: 7
                        bold: true
                        letterSpacing: 0.7
                    }
                }
            }
        }
    }
}
