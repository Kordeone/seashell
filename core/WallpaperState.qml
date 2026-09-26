pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property int index: 0

    readonly property int catalogRevision:
        WallpaperCatalog.revision

    readonly property var themePool: {
        const dependency =
            catalogRevision

        return WallpaperCatalog
            .themeFiles(
                Config.paletteId
            )
    }

    readonly property var manualPool: {
        const dependency =
            catalogRevision

        const paths =
            Config.wallpaperManualSelection
            || []

        const result = []

        for (
            let i = 0;
            i < paths.length;
            ++i
        ) {
            const item =
                WallpaperCatalog
                    .fileByPath(
                        paths[i]
                    )

            if (item)
                result.push(item)
        }

        return result
    }

    readonly property var activePool:
        Config.wallpaperThemeOriented
            ? themePool
            : manualPool

    readonly property int count:
        activePool.length

    readonly property int safeIndex:
        count > 0
            ? index % count
            : 0

    readonly property var activeItem:
        count > 0
            ? activePool[safeIndex]
            : null

    readonly property string activePath:
        activeItem
            ? activeItem.path
            : ""

    readonly property string activeSource:
        activeItem
            ? activeItem.source
            : ""

    readonly property bool hasShellWallpaper:
        activeSource.length > 0

    readonly property int activeNumber:
        count > 0
            ? safeIndex + 1
            : 0

    function resetRotation() {
        index = 0

        if (rotationTimer.running)
            rotationTimer.restart()
    }

    function nextWallpaper() {
        if (count <= 1)
            return

        index =
            (
                safeIndex + 1
            )
            % count
    }

    function previousWallpaper() {
        if (count <= 1)
            return

        index =
            (
                safeIndex
                - 1
                + count
            )
            % count
    }

    Timer {
        id: rotationTimer

        interval:
            Math.max(
                1,
                Config.wallpaperIntervalMinutes
            )
            * 60
            * 1000

        repeat: true

        running:
            root.count > 1

        onTriggered:
            root.nextWallpaper()
    }

    Connections {
        target: Config

        function onPaletteIdChanged() {
            if (
                Config.wallpaperThemeOriented
            ) {
                root.resetRotation()
            }
        }

        function onWallpaperThemeOrientedChanged() {
            root.resetRotation()
        }

        function onWallpaperManualSelectionChanged() {
            if (
                !Config.wallpaperThemeOriented
            ) {
                root.resetRotation()
            }
        }

        function onWallpaperIntervalMinutesChanged() {
            if (rotationTimer.running)
                rotationTimer.restart()
        }
    }
}
