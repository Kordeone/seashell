pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    readonly property string shellName: "Seashell"

    property alias styleId: settingsData.styleId
    property alias paletteId: settingsData.paletteId
    property alias fontFamily: settingsData.fontFamily
    property alias moduleFontOverrides: settingsData.moduleFontOverrides
    property alias clockFormat: settingsData.clockFormat
    property alias wallpaperFit: settingsData.wallpaperFit
    property alias wallpaperThemeOriented: settingsData.wallpaperThemeOriented
    property alias wallpaperManualSelection: settingsData.wallpaperManualSelection
    property alias wallpaperRotationMode: settingsData.wallpaperRotationMode
    property alias wallpaperIntervalMinutes: settingsData.wallpaperIntervalMinutes
    property alias hiddenApplications: settingsData.hiddenApplications
    property alias launcherSources: settingsData.launcherSources
    property alias keybinds: settingsData.keybinds
    property alias keybindApprovals: settingsData.keybindApprovals
    property alias activeModules: settingsData.activeModules
    property alias webApps: settingsData.webApps
    property alias launcherShortcuts: settingsData.launcherShortcuts

    FileView {
        id: settingsFile

        path: Quickshell.statePath("settings.json")

        watchChanges: true

        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: settingsData

            property string styleId: "pixel-modern"
            property string paletteId: "andarouni"
            property string fontFamily: "__style__"
            property var moduleFontOverrides: ({})
            property string clockFormat: "HH:mm"
            property string wallpaperFit: "cover"
            property bool wallpaperThemeOriented: true
            property var wallpaperManualSelection: []

        // palette key -> array of wallpaper paths.
        // Arrays are intentional: rotation support can be added
        // later without changing the persisted data model.

            property string wallpaperRotationMode: "sequence"
            property int wallpaperIntervalMinutes: 30
            property var hiddenApplications: []
            property var launcherSources: ({ applications: true, actions: true, webApps: true, shortcuts: true })
            property var keybinds: ({})
            property var keybindApprovals: ({})
            property var activeModules: ({ bar: "bar.seashell", launcher: "launcher.seashell",
                wallpaper: "wallpaper.seashell" })
            property var webApps: []
            property var launcherShortcuts: []
        }
    }

    // SEASHELL_RUNTIME_STATE_NORMALIZATION
    //
    // Keep old persisted values compatible with the current
    // schema. This runs in addition to one-time file migration,
    // so stale JsonAdapter values cannot resurrect old IDs.

    function normalizedPaletteId(value) {
        switch (value) {
        case "persian-carpet":
            return "gel"

        case "persian-dome":
            return "the-dome"

        case "persian-courtyard":
            return "andarouni"

        case "persian-tapestry":
            return "shaal"

        case "mamluk-glass":
            return "mamluk"

        case "gel":
        case "the-dome":
        case "andarouni":
        case "shaal":
        case "mamluk":
        case "iznik":
        case "tokyo-night":
        case "gruvbox-dark":
        case "rose-pine":
            return value

        default:
            return "andarouni"
        }
    }

    function normalizeRuntimeSettings() {
        const normalizedPalette =
            normalizedPaletteId(
                paletteId
            )

        if (
            normalizedPalette
            !== paletteId
        ) {
            paletteId =
                normalizedPalette
        }

        const overrides =
            moduleFontOverrides || {}

        if (
            overrides["bar"]
            && !overrides["bar.clock"]
        ) {
            const next =
                Object.assign(
                    {},
                    overrides
                )

            next["bar.clock"] =
                next["bar"]

            delete next["bar"]

            moduleFontOverrides =
                next
        } else if (
            overrides["bar"]
        ) {
            const next =
                Object.assign(
                    {},
                    overrides
                )

            delete next["bar"]

            moduleFontOverrides =
                next
        }
    }

    onPaletteIdChanged: {
        const normalized =
            normalizedPaletteId(
                paletteId
            )

        if (
            normalized
            !== paletteId
        ) {
            paletteId =
                normalized
        }
    }

    onModuleFontOverridesChanged: {
        const overrides =
            moduleFontOverrides || {}

        if (!overrides["bar"])
            return

        const next =
            Object.assign(
                {},
                overrides
            )

        if (
            !next["bar.clock"]
        ) {
            next["bar.clock"] =
                next["bar"]
        }

        delete next["bar"]

        moduleFontOverrides =
            next
    }

    Component.onCompleted:
        Qt.callLater(
            normalizeRuntimeSettings
        )

}
