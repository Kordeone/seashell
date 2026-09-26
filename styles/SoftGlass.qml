import QtQuick

QtObject {
    readonly property string name: "Soft Glass"
    readonly property string key: "soft-glass"

    // Transparency
    readonly property real panelOpacity: 0.68
    readonly property real popupOpacity: 0.88
    readonly property real overlayOpacity: 0.60

    // Settings
    readonly property real settingsBackdropOpacity: 0.32
    readonly property real settingsPanelOpacity: 0.76

    // Shape
    readonly property int borderWidth: 1

    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 18

    // Spacing
    readonly property int spacingXS: 5
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 12
    readonly property int spacingLarge: 16
    readonly property int spacingXL: 24

    // Typography
    readonly property string fontUI: "sans-serif"
    readonly property string fontMono: "monospace"

    readonly property int fontSmall: 11
    readonly property int fontMedium: 12
    readonly property int fontLarge: 14

    // Motion
    readonly property int animationFast: 120
    readonly property int animationNormal: 220
    readonly property int animationSlow: 340

    // Bar
    readonly property int barHeight: 42
    readonly property int barRadius: 14
    readonly property int barMarginHorizontal: 8
    readonly property int barMarginVertical: 6

    // Rounded pill keeps its outline.
    readonly property int barFrameWidth: 1
    readonly property int barBottomBorderWidth: 0

    // Full-width dark rail underneath the floating glass pill.
    // Matches the Settings backdrop so the two surfaces feel
    // like the same component language.
    readonly property real barBackdropOpacity: 0.32
}
