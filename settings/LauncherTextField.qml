import QtQuick

import qs.core

Rectangle {
    id: root
    property alias text: input.text
    property string placeholderText: ""
    property bool secret: false
    height: 34
    radius: Theme.radiusSmall
    color: Theme.surface
    border.width: Theme.borderWidth
    border.color: input.activeFocus ? Theme.focus : Theme.border

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.foreground
        selectionColor: Theme.accent
        selectedTextColor: Theme.accentForeground
        echoMode: root.secret ? TextInput.Password : TextInput.Normal
        font.family: Theme.fontUI
        font.pixelSize: 9
        clip: true
    }
    Text {
        visible: !input.text.length && !input.activeFocus
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: root.placeholderText
        color: Theme.foregroundDisabled
        font.family: Theme.fontUI
        font.pixelSize: 9
    }
}
