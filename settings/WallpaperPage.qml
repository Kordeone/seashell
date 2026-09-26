import QtQuick

import qs.core
import qs.palettes

Item {
    id: root

    // SettingsWindow may still provide this property.
    property string tab: "general"

    property var draftSelection: []
    property bool draftDirty: false

    readonly property var activePalette:
        Palettes.byId(
            Config.paletteId
        )

    readonly property int catalogRevision:
        WallpaperCatalog.revision

    readonly property var themeWallpapers: {
        const dependency =
            catalogRevision

        return WallpaperCatalog
            .themeFiles(
                activePalette.key
            )
    }

    readonly property var rootWallpapers: {
        const dependency =
            catalogRevision

        return WallpaperCatalog
            .rootFiles()
    }

    readonly property var userWallpapers: {
        const dependency =
            catalogRevision

        return WallpaperCatalog
            .userFiles()
    }

    readonly property var allThemeWallpapers: {
        const dependency =
            catalogRevision

        return WallpaperCatalog
            .allThemeFiles()
    }

    function loadAppliedSelection() {
        draftSelection =
            (
                Config.wallpaperManualSelection
                || []
            ).slice()

        draftDirty = false
    }

    function toggleDraft(path) {
        const next =
            draftSelection.slice()

        const index =
            next.indexOf(path)

        if (index >= 0) {
            next.splice(
                index,
                1
            )
        } else {
            next.push(path)
        }

        draftSelection = next
        draftDirty = true
    }

    function applyManualPool() {
        Config.wallpaperManualSelection =
            draftSelection.slice()

        WallpaperState.resetRotation()

        draftDirty = false
    }

    Component.onCompleted:
        loadAppliedSelection()

    Flickable {
        anchors.fill: parent

        clip: true

        contentWidth: width

        contentHeight:
            content.height

        boundsBehavior:
            Flickable.StopAtBounds

        Column {
            id: content

            width: parent.width

            spacing: 12

            // =================================================
            // HEADER
            // =================================================

            Column {
                width: parent.width
                spacing: 4

                Text {
                    text: "WALLPAPER"

                    color:
                        Theme.foreground

                    font {
                        family:
                            Theme.fontUI

                        pixelSize: 15
                        bold: true
                    }
                }

                Text {
                    width: parent.width

                    text:
                        "Theme-owned pools or a custom multi-wallpaper pool."

                    color:
                        Theme.foregroundMuted

                    font {
                        family:
                            Theme.fontUI

                        pixelSize: 9
                    }
                }
            }

            // =================================================
            // THEME ORIENTED CHECKBOX
            // =================================================

            Rectangle {
                width: parent.width
                height: 54

                radius:
                    Theme.radiusMedium

                color:
                    Theme.surface

                border {
                    width:
                        Config.wallpaperThemeOriented
                            ? 2
                            : Theme.borderWidth

                    color:
                        Config.wallpaperThemeOriented
                            ? Theme.accent
                            : Theme.border
                }

                Rectangle {
                    id: themeCheck

                    anchors {
                        left: parent.left
                        leftMargin: 12
                        verticalCenter:
                            parent.verticalCenter
                    }

                    width: 22
                    height: 22

                    radius: 4

                    color:
                        Config.wallpaperThemeOriented
                            ? Theme.accent
                            : Theme.background

                    border {
                        width: 1

                        color:
                            Config.wallpaperThemeOriented
                                ? Theme.accent
                                : Theme.border
                    }

                    Text {
                        visible:
                            Config.wallpaperThemeOriented

                        anchors.centerIn:
                            parent

                        text: "✓"

                        color:
                            Theme.accentForeground

                        font {
                            family:
                                Theme.fontUI

                            pixelSize: 11
                            bold: true
                        }
                    }
                }

                Column {
                    anchors {
                        left: themeCheck.right
                        leftMargin: 10
                        right: parent.right
                        rightMargin: 12
                        verticalCenter:
                            parent.verticalCenter
                    }

                    spacing: 2

                    Text {
                        text:
                            "Theme Oriented"

                        color:
                            Theme.foreground

                        font {
                            family:
                                Theme.fontUI

                            pixelSize: 10
                            bold: true
                        }
                    }

                    Text {
                        width: parent.width

                        text:
                            Config.wallpaperThemeOriented
                                ? (
                                    root.activePalette.name
                                    + " owns the active wallpaper pool."
                                  )
                                : "Use a manually selected wallpaper pool."

                        color:
                            Theme.foregroundMuted

                        font {
                            family:
                                Theme.fontUI

                            pixelSize: 7
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        Config.wallpaperThemeOriented =
                            !Config.wallpaperThemeOriented

                        if (
                            !Config.wallpaperThemeOriented
                        ) {
                            root.loadAppliedSelection()
                        }
                    }
                }
            }

            // =================================================
            // INTERVAL
            // =================================================

            Rectangle {
                width: parent.width
                height: 52

                radius:
                    Theme.radiusMedium

                color:
                    Theme.surface

                border {
                    width:
                        Theme.borderWidth

                    color:
                        Theme.border
                }

                Column {
                    anchors {
                        left: parent.left
                        leftMargin: 12
                        verticalCenter:
                            parent.verticalCenter
                    }

                    spacing: 1

                    Text {
                        text:
                            "Rotation Interval"

                        color:
                            Theme.foreground

                        font {
                            family:
                                Theme.fontUI

                            pixelSize: 9
                            bold: true
                        }
                    }

                    Text {
                        text:
                            "Applies to both theme and manual pools."

                        color:
                            Theme.foregroundMuted

                        font {
                            family:
                                Theme.fontUI

                            pixelSize: 7
                        }
                    }
                }

                Rectangle {
                    anchors {
                        right: minuteLabel.left
                        rightMargin: 7
                        verticalCenter:
                            parent.verticalCenter
                    }

                    width: 68
                    height: 30

                    radius:
                        Theme.radiusSmall

                    color:
                        Theme.background

                    border {
                        width:
                            Theme.borderWidth

                        color:
                            Theme.border
                    }

                    TextInput {
                        anchors {
                            fill: parent
                            margins: 4
                        }

                        text:
                            String(
                                Config.wallpaperIntervalMinutes
                            )

                        horizontalAlignment:
                            TextInput.AlignHCenter

                        verticalAlignment:
                            TextInput.AlignVCenter

                        selectByMouse: true

                        validator:
                            IntValidator {
                                bottom: 1
                                top: 1440
                            }

                        color:
                            Theme.foreground

                        font {
                            family:
                                Theme.fontMono

                            pixelSize: 9
                            bold: true
                        }

                        onEditingFinished: {
                            const value =
                                parseInt(text)

                            if (
                                !isNaN(value)
                                && value >= 1
                            ) {
                                Config.wallpaperIntervalMinutes =
                                    value
                            }

                            text =
                                String(
                                    Config.wallpaperIntervalMinutes
                                )
                        }
                    }
                }

                Text {
                    id: minuteLabel

                    anchors {
                        right: parent.right
                        rightMargin: 12
                        verticalCenter:
                            parent.verticalCenter
                    }

                    text: "MIN"

                    color:
                        Theme.foregroundMuted

                    font {
                        family:
                            Theme.fontMono

                        pixelSize: 7
                        bold: true
                    }
                }
            }

            // =================================================
            // CURRENT STATUS
            // =================================================

            Rectangle {
                width: parent.width
                height: 48

                radius:
                    Theme.radiusMedium

                color:
                    Theme.surface

                border {
                    width:
                        Theme.borderWidth

                    color:
                        Theme.border
                }

                Column {
                    anchors {
                        left: parent.left
                        leftMargin: 12
                        verticalCenter:
                            parent.verticalCenter
                    }

                    spacing: 2

                    Text {
                        text:
                            WallpaperState.hasShellWallpaper
                                ? WallpaperState.activeItem.displayName
                                : "System wallpaper fallback"

                        color:
                            Theme.foreground

                        font {
                            family:
                                Theme.fontUI

                            pixelSize: 8
                            bold: true
                        }
                    }

                    Text {
                        text:
                            WallpaperState.count > 0
                                ? (
                                    WallpaperState.activeNumber
                                    + " / "
                                    + WallpaperState.count
                                    + " · rotating every "
                                    + Config.wallpaperIntervalMinutes
                                    + " min"
                                  )
                                : "No active Seashell wallpaper pool."

                        color:
                            Theme.foregroundMuted

                        font {
                            family:
                                Theme.fontMono

                            pixelSize: 7
                        }
                    }
                }

                Row {
                    visible:
                        WallpaperState.count > 1

                    anchors {
                        right: parent.right
                        rightMargin: 10
                        verticalCenter:
                            parent.verticalCenter
                    }

                    spacing: 6

                    Repeater {
                        model: [
                            {
                                label: "‹",
                                direction: -1
                            },
                            {
                                label: "›",
                                direction: 1
                            }
                        ]

                        delegate: Rectangle {
                            required property var modelData

                            width: 30
                            height: 27

                            radius:
                                Theme.radiusSmall

                            color:
                                navMouse.containsMouse
                                    ? Theme.surfaceRaised
                                    : Theme.background

                            border {
                                width:
                                    Theme.borderWidth

                                color:
                                    Theme.border
                            }

                            Text {
                                anchors.centerIn:
                                    parent

                                text:
                                    modelData.label

                                color:
                                    Theme.foreground

                                font {
                                    family:
                                        Theme.fontUI

                                    pixelSize: 13
                                    bold: true
                                }
                            }

                            MouseArea {
                                id: navMouse

                                anchors.fill:
                                    parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    if (
                                        modelData.direction
                                        < 0
                                    ) {
                                        WallpaperState
                                            .previousWallpaper()
                                    } else {
                                        WallpaperState
                                            .nextWallpaper()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // =================================================
            // APPLY MANUAL WALLPAPER POOL
            // =================================================

            Rectangle {
                visible:
                    !Config.wallpaperThemeOriented

                width: parent.width
                height: 46

                radius:
                    Theme.radiusMedium

                color:
                    root.draftSelection.length > 0
                        ? Theme.accent
                        : Theme.surface

                opacity:
                    root.draftSelection.length > 0
                        ? 1.0
                        : 0.45

                border {
                    width:
                        Theme.borderWidth

                    color:
                        root.draftSelection.length > 0
                            ? Theme.accent
                            : Theme.border
                }

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 12
                        verticalCenter:
                            parent.verticalCenter
                    }

                    text:
                        root.draftSelection.length
                        + (
                            root.draftSelection.length === 1
                                ? " WALLPAPER SELECTED"
                                : " WALLPAPERS SELECTED"
                          )

                    color:
                        root.draftSelection.length > 0
                            ? Theme.accentForeground
                            : Theme.foregroundDisabled

                    font {
                        family:
                            Theme.fontMono

                        pixelSize: 7
                        bold: true
                    }
                }

                Text {
                    anchors {
                        right: parent.right
                        rightMargin: 16
                        verticalCenter:
                            parent.verticalCenter
                    }

                    text: "SET"

                    color:
                        root.draftSelection.length > 0
                            ? Theme.accentForeground
                            : Theme.foregroundDisabled

                    font {
                        family:
                            Theme.fontMono

                        pixelSize: 9
                        bold: true
                        letterSpacing: 1
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    enabled:
                        root.draftSelection.length > 0

                    cursorShape:
                        enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                    onClicked:
                        root.applyManualPool()
                }
            }

            // =================================================
            // THEME ORIENTED POOL
            // =================================================

            WallpaperSection {
                visible:
                    Config.wallpaperThemeOriented

                width: parent.width

                title:
                    root.activePalette.name
                    + " Wallpapers"

                subtitle:
                    "All images owned by the active theme"

                wallpapers:
                    root.themeWallpapers

                selectedPaths: []

                selectable: false
                expanded: true
            }

            // =================================================
            // MANUAL MODE
            // =================================================

            Column {
                visible:
                    !Config.wallpaperThemeOriented

                width: parent.width
                spacing: 8

                WallpaperSection {
                    width: parent.width

                    title:
                        "User Added"

                    subtitle:
                        "Personal wallpaper library"

                    wallpapers:
                        root.userWallpapers

                    selectedPaths:
                        root.draftSelection

                    disabled: true
                    selectable: false
                    expanded: false
                }

                WallpaperSection {
                    width: parent.width

                    title:
                        "Wallpaper Root Folder"

                    subtitle:
                        "General wallpapers outside theme folders"

                    wallpapers:
                        root.rootWallpapers

                    selectedPaths:
                        root.draftSelection

                    selectable: true
                    expanded: true

                    onToggleRequested:
                        path =>
                            root.toggleDraft(path)
                }

                WallpaperSection {
                    width: parent.width

                    title:
                        "Wallpaper Themes"

                    subtitle:
                        "Wallpapers from every theme"

                    wallpapers:
                        root.allThemeWallpapers

                    selectedPaths:
                        root.draftSelection

                    selectable: true
                    expanded: true

                    onToggleRequested:
                        path =>
                            root.toggleDraft(path)
                }

                Rectangle {
                    width: parent.width
                    height: 54

                    radius:
                        Theme.radiusMedium

                    color:
                        Theme.surface

                    border {
                        width:
                            Theme.borderWidth

                        color:
                            Theme.border
                    }

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 12
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text:
                            root.draftSelection.length
                            + (
                                root.draftSelection.length
                                === 1
                                    ? " WALLPAPER SELECTED"
                                    : " WALLPAPERS SELECTED"
                              )

                        color:
                            Theme.foregroundMuted

                        font {
                            family:
                                Theme.fontMono

                            pixelSize: 7
                            bold: true
                        }
                    }

    
                }
            }
        }
    }
}
