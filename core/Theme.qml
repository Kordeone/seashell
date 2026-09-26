pragma Singleton

import QtQuick
import Quickshell

import qs.styles
import qs.palettes

Singleton {
    readonly property QtObject activeStyle:
        Styles.byId(Config.styleId)

    readonly property QtObject activePalette:
        Palettes.byId(Config.paletteId)

    // Identity

    readonly property string styleName: activeStyle.name
    readonly property string styleId: activeStyle.key

    readonly property string paletteName: activePalette.name
    readonly property string paletteId: activePalette.key

    readonly property bool dark: activePalette.dark

    // Palette

    readonly property color background:
        activePalette.background

    readonly property color surface:
        activePalette.surface

    readonly property color surfaceRaised:
        activePalette.surfaceRaised

    readonly property color foreground:
        activePalette.foreground

    readonly property color foregroundMuted:
        activePalette.foregroundMuted

    readonly property color foregroundDisabled:
        activePalette.foregroundDisabled

    readonly property color accent:
        activePalette.accent

    readonly property color accentForeground:
        activePalette.accentForeground

    readonly property color border:
        activePalette.border

    readonly property color focus:
        activePalette.focus

    readonly property color success:
        activePalette.success

    readonly property color warning:
        activePalette.warning

    readonly property color danger:
        activePalette.danger

    // Component style

    readonly property real panelOpacity:
        activeStyle.panelOpacity

    readonly property real popupOpacity:
        activeStyle.popupOpacity

    readonly property real overlayOpacity:
        activeStyle.overlayOpacity

    readonly property real settingsBackdropOpacity:
        activeStyle.settingsBackdropOpacity

    readonly property real settingsPanelOpacity:
        activeStyle.settingsPanelOpacity

    readonly property int borderWidth:
        activeStyle.borderWidth

    readonly property int radiusSmall:
        activeStyle.radiusSmall

    readonly property int radiusMedium:
        activeStyle.radiusMedium

    readonly property int radiusLarge:
        activeStyle.radiusLarge

    readonly property int spacingXS:
        activeStyle.spacingXS

    readonly property int spacingSmall:
        activeStyle.spacingSmall

    readonly property int spacingMedium:
        activeStyle.spacingMedium

    readonly property int spacingLarge:
        activeStyle.spacingLarge

    readonly property int spacingXL:
        activeStyle.spacingXL

    readonly property string fontUI:
        Config.fontFamily === Typography.styleDefaultKey
            ? activeStyle.fontUI
            : Config.fontFamily

    readonly property string fontMono:
        activeStyle.fontMono

    readonly property int fontSmall:
        activeStyle.fontSmall

    readonly property int fontMedium:
        activeStyle.fontMedium

    readonly property int fontLarge:
        activeStyle.fontLarge

    readonly property int animationFast:
        activeStyle.animationFast

    readonly property int animationNormal:
        activeStyle.animationNormal

    readonly property int animationSlow:
        activeStyle.animationSlow

    readonly property int barHeight:
        activeStyle.barHeight

    readonly property int barRadius:
        activeStyle.barRadius

    readonly property int barMarginHorizontal:
        activeStyle.barMarginHorizontal

    readonly property int barMarginVertical:
        activeStyle.barMarginVertical

    readonly property int barFrameWidth:
        activeStyle.barFrameWidth

    readonly property int barBottomBorderWidth:
        activeStyle.barBottomBorderWidth

    readonly property real barBackdropOpacity:
        activeStyle.barBackdropOpacity
}
