pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property color background: "#101014"
    readonly property color foreground: "#eeeeee"
    readonly property color muted: "#8b8b95"
    readonly property color accent: "#8aadf4"
    readonly property color border: "#2a2a32"

    readonly property int barHeight: 38
    readonly property int borderWidth: 1
    readonly property int spacing: 10

    readonly property string fontFamily: "monospace"
}
