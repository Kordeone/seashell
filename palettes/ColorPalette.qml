import QtQuick

QtObject {
    // Identity
    property string name: ""
    property string key: ""
    property bool dark: true

    // Base surfaces
    property color background: "#000000"
    property color surface: "#111111"
    property color surfaceRaised: "#222222"

    // Foreground
    property color foreground: "#ffffff"
    property color foregroundMuted: "#aaaaaa"
    property color foregroundDisabled: "#777777"

    // Accent
    property color accent: "#ffffff"
    property color accentForeground: "#000000"

    // Structure
    property color border: "#444444"
    property color focus: "#ffffff"

    // Semantic states
    property color success: "#00ff00"
    property color warning: "#ffff00"
    property color danger: "#ff0000"
}
