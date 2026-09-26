pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property int revision: 1

    function themeName(key) {
        switch (key) {
        case "gel":
            return "Gel"

        case "the-dome":
            return "The Dome"

        case "andarouni":
            return "Andarouni"

        case "shaal":
            return "Shaal"

        case "mamluk":
            return "Mamluk"

        case "iznik":
            return "İznik"

        case "tokyo-night":
            return "Tokyo Night"

        case "gruvbox-dark":
            return "Gruvbox Dark"

        case "rose-pine":
            return "Rosé Pine"

        default:
            return key
        }
    }

    readonly property var files: {
        const source =
            WallpaperManifest.entries || []

        const result = []

        for (
            let i = 0;
            i < source.length;
            ++i
        ) {
            const entry =
                source[i]

            const displayName =
                entry.group === "theme"
                    ? (
                        themeName(
                            entry.themeKey
                        )
                        + "/"
                        + entry.filename
                      )
                    : entry.filename

            result.push({
                path:
                    entry.path,

                filename:
                    entry.filename,

                displayName:
                    displayName,

                group:
                    entry.group,

                themeKey:
                    entry.themeKey,

                themeFolder:
                    entry.themeFolder,

                source:
                    sourceUrl(
                        entry.path
                    )
            })
        }

        return result
    }

    function sourceUrl(path) {
        if (!path)
            return ""

        if (
            path.startsWith("file:")
            || path.startsWith("qrc:")
            || path.startsWith("http:")
            || path.startsWith("https:")
        ) {
            return path
        }

        if (path.startsWith("/"))
            return "file://" + path

        return Quickshell.shellPath(
            path
        )
    }

    function fileByPath(path) {
        for (
            let i = 0;
            i < files.length;
            ++i
        ) {
            if (
                files[i].path === path
            ) {
                return files[i]
            }
        }

        return null
    }

    function rootFiles() {
        const dependency = revision

        return files.filter(
            item =>
                item.group === "root"
        )
    }

    function userFiles() {
        const dependency = revision

        return files.filter(
            item =>
                item.group === "user"
        )
    }

    function themeFiles(themeKey) {
        const dependency = revision

        return files.filter(
            item =>
                item.group === "theme"
                && item.themeKey
                   === themeKey
        )
    }

    function allThemeFiles() {
        const dependency = revision

        return files.filter(
            item =>
                item.group === "theme"
        )
    }

    function refresh() {
        revision += 1
    }
}
