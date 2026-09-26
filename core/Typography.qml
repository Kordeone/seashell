pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string styleDefaultKey: "__style__"
    readonly property string moreFontsKey: "__more__"

    // Fonts Qt can actually see on this Linux installation.
    readonly property var installedFamilies:
        Qt.fontFamilies()

    // Preferred families for the compact Settings section.
    // Only installed entries are exposed.
    readonly property var preferredCandidates: [
        "JetBrains Mono",
        "Inter",
        "IBM Plex Sans",
        "Noto Sans",
        "Noto Sans Mono",
        "DejaVu Sans"
    ]

    readonly property var featuredFamilies:
        buildFeaturedFamilies()

    readonly property var featuredOptions:
        [styleDefaultKey].concat(featuredFamilies)

    readonly property var settingsOptions:
        featuredOptions.concat([moreFontsKey])

    function hasFamily(family) {
        for (
            let i = 0;
            i < installedFamilies.length;
            ++i
        ) {
            if (installedFamilies[i] === family)
                return true
        }

        return false
    }

    function isFeatured(family) {
        for (
            let i = 0;
            i < featuredFamilies.length;
            ++i
        ) {
            if (featuredFamilies[i] === family)
                return true
        }

        return false
    }

    function filterFamilies(query) {
        const needle =
            query.trim().toLowerCase()

        if (needle.length === 0)
            return installedFamilies

        let result = []

        for (
            let i = 0;
            i < installedFamilies.length;
            ++i
        ) {
            const family =
                installedFamilies[i]

            if (
                family.toLowerCase().indexOf(needle)
                !== -1
            ) {
                result.push(family)
            }
        }

        return result
    }

    function buildFeaturedFamilies() {
        let result = []

        for (
            let i = 0;
            i < preferredCandidates.length;
            ++i
        ) {
            const family = preferredCandidates[i]

            if (hasFamily(family))
                result.push(family)
        }

        return result
    }

    // --------------------------------------------------------
    // Module typography inheritance
    //
    // Global typography is always the default.
    // A module differs only if an explicit override exists.
    // --------------------------------------------------------

    function normalizeModuleKey(moduleKey) {
        // Legacy compatibility:
        // the old "bar" override always represented the clock.
        if (moduleKey === "bar")
            return "bar.clock"

        return moduleKey
    }

    function moduleOverride(moduleKey) {
        const values = Config.moduleFontOverrides

        if (!values)
            return ""

        const normalizedKey =
            normalizeModuleKey(moduleKey)

        const value =
            values[normalizedKey]

        return typeof value === "string"
            ? value
            : ""
    }

    function moduleHasOverride(moduleKey) {
        return moduleOverride(moduleKey).length > 0
    }

    function moduleFontFamily(moduleKey, generalFamily) {
        const override = moduleOverride(moduleKey)

        return override.length > 0
            ? override
            : generalFamily
    }

    function setModuleOverride(moduleKey, family) {
        const normalizedKey =
            normalizeModuleKey(moduleKey)

        const current =
            Config.moduleFontOverrides || {}

        const next =
            Object.assign({}, current)

        // Remove obsolete legacy key whenever we touch Bar Clock.
        if (normalizedKey === "bar.clock")
            delete next["bar"]

        if (
            !family
            || family === "__general__"
        ) {
            delete next[normalizedKey]
        } else {
            next[normalizedKey] = family
        }

        Config.moduleFontOverrides = next
    }

    function clearModuleOverride(moduleKey) {
        setModuleOverride(
            moduleKey,
            "__general__"
        )
    }

}
