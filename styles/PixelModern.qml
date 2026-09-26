import QtQuick

QtObject {
    readonly property string name: "Pixel Modern"
    readonly property string key: "pixel-modern"

    // Transparency
    readonly property real panelOpacity: 1.0
    readonly property real popupOpacity: 0.98
    readonly property real overlayOpacity: 0.72

    // Settings
    readonly property real settingsBackdropOpacity: 0.72
    readonly property real settingsPanelOpacity: 0.98

    // Shape
    readonly property int borderWidth: 1

    readonly property int radiusSmall: 0
    readonly property int radiusMedium: 2
    readonly property int radiusLarge: 4

    // Spacing
    readonly property int spacingXS: 4
    readonly property int spacingSmall: 6
    readonly property int spacingMedium: 10
    readonly property int spacingLarge: 14
    readonly property int spacingXL: 20

    // Typography
    readonly property string fontUI: "monospace"
    readonly property string fontMono: "monospace"

    readonly property int fontSmall: 11
    readonly property int fontMedium: 12
    readonly property int fontLarge: 14

    // Motion
    readonly property int animationFast: 100
    readonly property int animationNormal: 180
    readonly property int animationSlow: 280

    // Bar
    readonly property int barHeight: 38
    readonly property int barRadius: 0
    readonly property int barMarginHorizontal: 0
    readonly property int barMarginVertical: 0

    // Edge-to-edge bar: dedicated separator is more stable
    // than using Rectangle.border on the whole surface.
    readonly property int barFrameWidth: 0
    readonly property int barBottomBorderWidth: 1

    // Pixel Modern already occupies the entire bar window.
    readonly property real barBackdropOpacity: 0.0
}
