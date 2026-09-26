import QtQuick

import qs.core

Rectangle {
    id: root
    property string label: "ACTION"
    property bool emphasized: false
    signal clicked()
    width: Math.max(62, label.length * 7 + 18)
    height: 28
    radius: Theme.radiusSmall
    color: emphasized ? Theme.surfaceRaised : Theme.background
    border.width: Theme.borderWidth
    border.color: activeFocus ? Theme.focus : emphasized ? Theme.accent : Theme.border
    activeFocusOnTab: true
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                || event.key === Qt.Key_Space) {
            root.clicked()
            event.accepted = true
        }
    }
    Text {
        anchors.centerIn: parent
        text: root.label
        color: root.emphasized ? Theme.accent : Theme.foregroundMuted
        font.family: Theme.fontMono
        font.pixelSize: 7
        font.bold: true
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
