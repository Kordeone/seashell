import QtQuick

import qs.core

Item {
    id: root

    property var tabs: []
    property string currentKey: ""

    signal selected(string key)

    height: 32

    Row {
        anchors.fill: parent
        spacing: 6

        Repeater {
            model: root.tabs

            delegate: Rectangle {
                required property var modelData

                readonly property bool active:
                    root.currentKey === modelData.key

                width:
                    label.implicitWidth + 28

                height: 30

                radius: Theme.radiusSmall

                color:
                    active
                        ? Theme.surfaceRaised
                        : Theme.surface

                border {
                    width:
                        parent.active
                            ? 2
                            : Theme.borderWidth

                    color:
                        parent.active
                            ? Theme.accent
                            : Theme.border
                }

                Text {
                    id: label

                    anchors.centerIn: parent

                    text: modelData.name

                    color:
                        parent.active
                            ? Theme.accent
                            : Theme.foregroundMuted

                    font {
                        family: Theme.fontMono
                        pixelSize: 8
                        bold: true
                        letterSpacing: 0.8
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.selected(
                            modelData.key
                        )
                }
            }
        }
    }
}
