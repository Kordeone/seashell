import QtQuick
import Quickshell

import qs.core
import qs.styles

PanelWindow {
    id: window

    visible: ShellState.settingsOpen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    focusable: true

    color: "transparent"
    surfaceFormat.opaque: false

    property string currentSection: "appearance"
    property string currentSubSection: "general"

    property bool fontBrowserOpen: false
    property string fontSearch: ""
    property string fontBrowserTarget: "general"

    readonly property var styleDefault:
        Styles.byId(Config.styleId)

    readonly property var sections: [
        { key: "appearance", name: "Appearance" },
        { key: "general", name: "General" },
        { key: "bar", name: "Bar" },
        { key: "workspaces", name: "Workspaces" },
        { key: "launcher", name: "Launcher" },
        { key: "notifications", name: "Notifications" },
        { key: "wallpaper", name: "Wallpaper" },
        { key: "desktop", name: "Desktop" },
        { key: "control-center", name: "Control Center" },
        { key: "osd", name: "OSD" },
        { key: "dock", name: "Dock" },
        { key: "lock-power", name: "Lock & Power" },
        { key: "services", name: "Services" },
        { key: "keybinds", name: "Keybinds" },
        { key: "modules", name: "Modules" },
        { key: "plugins", name: "Plugins" },
        { key: "about", name: "About" }
    ]

    function fontTargetName(key) {
        switch (key) {
        case "bar.clock":
            return "Bar · Clock"

        case "bar.calendar":
            return "Bar · Calendar"

        case "bar.workspaces":
            return "Bar · Workspaces"

        case "bar.active-window":
            return "Bar · Active Window"

        case "bar.media":
            return "Bar · Media"

        default:
            return sectionName(key)
        }
    }

    function sectionName(key) {
        for (let i = 0; i < sections.length; ++i) {
            if (sections[i].key === key)
                return sections[i].name
        }

        return "Settings"
    }

    function tabsForSection(key) {
        if (key === "appearance") {
            return [
                { key: "general", name: "GENERAL" },
                { key: "component-style", name: "COMPONENT STYLE" },
                { key: "palette", name: "PALETTE" },
                { key: "typography", name: "TYPOGRAPHY" }
            ]
        }

        if (key === "bar") {
            return [
                { key: "general", name: "GENERAL" },
                { key: "clock", name: "CLOCK" },
                { key: "items", name: "ITEMS" }
            ]
        }

        if (key === "wallpaper") {
            return [
                { key: "general", name: "GENERAL" },
                { key: "wallpapers", name: "WALLPAPERS" }
            ]
        }

        return [
            { key: "general", name: "GENERAL" }
        ]
    }

    function roadmapForSection(key) {
        switch (key) {
        case "appearance":
            return [
                "Custom component-style editor",
                "Random palette mode and configurable interval",
                "Per-module typography overrides",
                "Theme-linked wallpaper collections",
                "Icon and cursor theme synchronization"
            ]

        case "general":
            return [
                "Startup and shell behavior",
                "Animation and motion preferences",
                "Locale and regional formatting",
                "Accessibility options",
                "Reload and update behavior"
            ]

        case "bar":
            return [
                "Bar position, size and margins",
                "Visibility and autohide",
                "Per-item ordering and positioning",
                "Multi-monitor bar behavior",
                "Ready-made external bar/module adapters"
            ]

        case "workspaces":
            return [
                "Workspace indicators and labels",
                "Icons and numbering",
                "Monitor-specific workspace behavior",
                "Urgent and active states",
                "Mouse and scroll actions"
            ]

        case "launcher":
            return [
                "Application search",
                "Commands and shell actions",
                "Favorites and recent applications",
                "Calculator and quick actions",
                "Search provider extensions"
            ]

        case "notifications":
            return [
                "Notification popups",
                "Notification center and history",
                "Do Not Disturb",
                "Per-application rules",
                "Notification actions"
            ]

        case "wallpaper":
            return [
                "Per-monitor wallpapers",
                "Palette-specific wallpapers",
                "Fit, crop and positioning",
                "Wallpaper collections",
                "Timed slideshow"
            ]

        case "desktop":
            return [
                "Desktop widgets",
                "Desktop information surfaces",
                "Interactive desktop regions",
                "Per-monitor desktop configuration"
            ]

        case "control-center":
            return [
                "Quick settings",
                "Audio controls",
                "Brightness controls",
                "Network and Bluetooth",
                "Power and session actions"
            ]

        case "osd":
            return [
                "Volume OSD",
                "Brightness OSD",
                "Microphone state",
                "Media feedback",
                "Position and timeout controls"
            ]

        case "dock":
            return [
                "Pinned applications",
                "Running applications",
                "Autohide",
                "Position and sizing",
                "Multi-monitor behavior"
            ]

        case "lock-power":
            return [
                "Lock screen",
                "Idle behavior",
                "Suspend and sleep",
                "Power menu",
                "Shutdown, reboot and logout"
            ]

        case "services":
            return [
                "Audio service",
                "Network service",
                "Bluetooth service",
                "Battery and power state",
                "Media session service"
            ]

        case "keybinds":
            return [
                "Seashell action shortcuts",
                "Launcher shortcut",
                "Settings shortcut",
                "Module shortcuts",
                "Conflict detection"
            ]

        case "modules":
            return [
                "Curated ready-to-use module catalog",
                "Best-in-class external module integrations",
                "Compatibility adapters",
                "Enable, disable and update modules",
                "Native fallback modules"
            ]

        case "plugins":
            return [
                "Plugin discovery and installation",
                "Enable and disable plugins",
                "Plugin updates",
                "Permissions and capabilities",
                "Plugin settings and developer API"
            ]

        case "about":
            return [
                "Seashell version and build information",
                "Licenses and acknowledgements",
                "Diagnostics",
                "Configuration paths",
                "System information"
            ]

        default:
            return []
        }
    }

    onCurrentSectionChanged: {
        currentSubSection = "general"
        fontBrowserOpen = false
    }

    onVisibleChanged: {
        if (visible)
            keyboardFocus.forceActiveFocus()

        if (!visible) {
            fontBrowserOpen = false
            fontSearch = ""
        }
    }

    Item {
        id: keyboardFocus

        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                if (window.fontBrowserOpen)
                    window.fontBrowserOpen = false
                else
                    ShellState.settingsOpen = false

                event.accepted = true
            }
        }
    }

    // ========================================================
    // BACKDROP
    // ========================================================

    Rectangle {
        anchors.fill: parent

        color: Qt.rgba(
            Theme.background.r,
            Theme.background.g,
            Theme.background.b,
            Theme.settingsBackdropOpacity
        )

        MouseArea {
            anchors.fill: parent

            onClicked:
                ShellState.settingsOpen = false
        }
    }

    // ========================================================
    // PANEL
    // ========================================================

    Rectangle {
        id: panel

        anchors.centerIn: parent

        width:
            Math.min(
                940,
                window.width - 54
            )

        height:
            Math.min(
                620,
                window.height - 54
            )

        radius: Theme.radiusLarge

        color: Qt.rgba(
            Theme.surface.r,
            Theme.surface.g,
            Theme.surface.b,
            Theme.settingsPanelOpacity
        )

        border {
            width: Theme.borderWidth
            color: Theme.border
        }

        MouseArea {
            anchors.fill: parent
        }

        // ----------------------------------------------------
        // HEADER
        // ----------------------------------------------------

        Text {
            anchors {
                left: parent.left
                leftMargin: 22
                top: parent.top
                topMargin: 19
            }

            text: "Settings"

            color: Theme.foreground

            font {
                family: Theme.fontUI
                pixelSize: 18
                bold: true
            }
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: 109
                top: parent.top
                topMargin: 24
            }

            text:
                "/ "
                + window.sectionName(
                    window.currentSection
                )

            color: Theme.foregroundMuted

            font {
                family: Theme.fontUI
                pixelSize: 10
            }
        }

        Rectangle {
            anchors {
                right: parent.right
                rightMargin: 17
                top: parent.top
                topMargin: 14
            }

            width: 30
            height: 30

            radius: Theme.radiusSmall

            color:
                closeMouse.containsMouse
                    ? Theme.surfaceRaised
                    : "transparent"

            Text {
                anchors.centerIn: parent

                text: "×"

                color: Theme.foregroundMuted

                font {
                    family: Theme.fontUI
                    pixelSize: 18
                }
            }

            MouseArea {
                id: closeMouse

                anchors.fill: parent
                hoverEnabled: true

                cursorShape:
                    Qt.PointingHandCursor

                onClicked:
                    ShellState.settingsOpen = false
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: 56
            }

            height: 1

            color: Theme.border
            opacity: 0.7
        }

        // ----------------------------------------------------
        // SIDEBAR
        // ----------------------------------------------------

        Rectangle {
            id: sidebar

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom

                leftMargin: 12
                topMargin: 69
                bottomMargin: 13
            }

            width: 176

            radius: Theme.radiusMedium

            color: Qt.rgba(
                Theme.background.r,
                Theme.background.g,
                Theme.background.b,
                0.24
            )

            border {
                width: Theme.borderWidth
                color: Theme.border
            }

            ListView {
                anchors {
                    fill: parent
                    margins: 7
                }

                clip: true
                spacing: 1

                model: window.sections

                delegate: Rectangle {
                    required property var modelData

                    width: ListView.view.width
                    height: 29

                    readonly property bool active:
                        window.currentSection
                        === modelData.key

                    radius: Theme.radiusSmall

                    color:
                        active
                            ? Theme.surfaceRaised
                            : navMouse.containsMouse
                                ? Qt.rgba(
                                    Theme.foreground.r,
                                    Theme.foreground.g,
                                    Theme.foreground.b,
                                    0.04
                                )
                                : "transparent"

                    Rectangle {
                        visible: parent.active

                        anchors {
                            left: parent.left
                            verticalCenter:
                                parent.verticalCenter
                        }

                        width: 3
                        height: 15
                        radius: 2

                        color: Theme.accent
                    }

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 12
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text: modelData.name

                        color:
                            parent.active
                                ? Theme.foreground
                                : Theme.foregroundMuted

                        font {
                            family: Theme.fontUI
                            pixelSize: 9
                            bold: parent.active
                        }
                    }

                    MouseArea {
                        id: navMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            window.currentSection =
                                modelData.key
                    }
                }
            }
        }

        Rectangle {
            anchors {
                left: sidebar.right
                leftMargin: 12
                top: sidebar.top
                bottom: sidebar.bottom
            }

            width: 1

            color: Theme.border
            opacity: 0.65
        }

        // ----------------------------------------------------
        // PAGE AREA
        // ----------------------------------------------------

        Item {
            id: pageArea

            anchors {
                left: sidebar.right
                right: parent.right
                top: parent.top
                bottom: parent.bottom

                leftMargin: 28
                rightMargin: 26
                topMargin: 72
                bottomMargin: 20
            }

            SectionTabs {
                id: sectionTabs

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                tabs:
                    window.tabsForSection(
                        window.currentSection
                    )

                currentKey:
                    window.currentSubSection

                onSelected: key => {
                    window.currentSubSection = key
                    window.fontBrowserOpen = false
                }
            }

            Item {
                id: pageContent

                anchors {
                    left: parent.left
                    right: parent.right
                    top: sectionTabs.bottom
                    bottom: parent.bottom

                    topMargin: 17
                }

                // ---------------------------------------------
                // GENERAL / ROADMAP
                // ---------------------------------------------

                RoadmapPage {
                    anchors.fill: parent

                    visible:
                        window.currentSubSection
                        === "general"

                    sectionName:
                        window.sectionName(
                            window.currentSection
                        )

                    items:
                        window.roadmapForSection(
                            window.currentSection
                        )
                }

                // ---------------------------------------------
                // APPEARANCE SUBPAGES
                // ---------------------------------------------

                AppearancePage {
                    anchors.fill: parent

                    visible:
                        window.currentSection
                        === "appearance"
                        && window.currentSubSection
                        !== "general"

                    tab:
                        window.currentSubSection

                    onMoreFontsRequested: target => {
                        window.fontBrowserTarget = target
                        window.fontBrowserOpen = true
                    }
                }

                // ---------------------------------------------
                // BAR SUBPAGES
                // ---------------------------------------------

                BarPage {
                    anchors.fill: parent

                    visible:
                        window.currentSection
                        === "bar"
                        && window.currentSubSection
                        !== "general"

                    tab:
                        window.currentSubSection

                    onMoreFontsRequested: {
                        window.fontBrowserTarget = "bar.clock"
                        window.fontBrowserOpen = true
                    }
                }

                // ---------------------------------------------
                // WALLPAPER SUBPAGES
                // ---------------------------------------------

                WallpaperPage {
                    anchors.fill: parent

                    visible:
                        window.currentSection
                        === "wallpaper"
                        && window.currentSubSection
                        !== "general"

                    tab:
                        window.currentSubSection
                }
            }
        }

        // ====================================================
        // FONT BROWSER BACKDROP
        // ====================================================

        Rectangle {
            anchors.fill: parent

            visible:
                window.fontBrowserOpen

            z: 1000

            radius: panel.radius

            color: Qt.rgba(
                Theme.background.r,
                Theme.background.g,
                Theme.background.b,
                0.60
            )

            MouseArea {
                anchors.fill: parent

                onClicked:
                    window.fontBrowserOpen = false
            }
        }

        // ====================================================
        // FONT BROWSER
        // ====================================================

        Rectangle {
            visible:
                window.fontBrowserOpen

            z: 1010

            anchors.centerIn: parent

            width: 470
            height: 350

            radius: Theme.radiusLarge

            color: Theme.surfaceRaised

            border {
                width: Theme.borderWidth
                color: Theme.border
            }

            MouseArea {
                anchors.fill: parent
            }

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 18
                    top: parent.top
                    topMargin: 15
                }

                text:
                    window.fontBrowserTarget
                    === "general"
                        ? "Fonts"
                        : window.fontTargetName(
                            window.fontBrowserTarget
                          )
                          + " Font"

                color: Theme.foreground

                font {
                    family: Theme.fontUI
                    pixelSize: 14
                    bold: true
                }
            }

            Rectangle {
                id: searchBox

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top

                    leftMargin: 18
                    rightMargin: 18
                    topMargin: 43
                }

                height: 34

                radius: Theme.radiusSmall
                color: Theme.surface

                border {
                    width: Theme.borderWidth

                    color:
                        searchInput.activeFocus
                            ? Theme.focus
                            : Theme.border
                }

                TextInput {
                    id: searchInput

                    anchors {
                        fill: parent
                        leftMargin: 11
                        rightMargin: 11
                    }

                    verticalAlignment:
                        TextInput.AlignVCenter

                    text: window.fontSearch

                    color: Theme.foreground

                    selectionColor:
                        Theme.accent

                    selectedTextColor:
                        Theme.accentForeground

                    font {
                        family: Theme.fontUI
                        pixelSize: 10
                    }

                    onTextChanged:
                        window.fontSearch = text
                }

                Text {
                    visible:
                        searchInput.text.length
                        === 0

                    anchors {
                        left: parent.left
                        leftMargin: 11
                        verticalCenter:
                            parent.verticalCenter
                    }

                    text:
                        "Search installed fonts…"

                    color:
                        Theme.foregroundDisabled

                    font {
                        family: Theme.fontUI
                        pixelSize: 10
                    }
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: searchBox.bottom

                    leftMargin: 18
                    rightMargin: 18
                    topMargin: 9
                }

                height: 40

                radius: Theme.radiusSmall

                color:
                    (
                        window.fontBrowserTarget
                        === "general"
                            ? Config.fontFamily
                              === Typography.styleDefaultKey
                            : !Typography.moduleHasOverride(
                                  window.fontBrowserTarget
                              )
                    )
                        ? Theme.surface
                        : "transparent"

                border {
                    width: Theme.borderWidth
                    color: Theme.border
                }

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 11
                        verticalCenter:
                            parent.verticalCenter
                    }

                    text:
                        window.fontBrowserTarget
                        === "general"
                            ? "Style Default  ·  "
                              + window.styleDefault.fontUI
                            : "Use General  ·  "
                              + Theme.fontUI

                    color: Theme.foreground

                    font {
                        family:
                            window.fontBrowserTarget
                            === "general"
                                ? window.styleDefault.fontUI
                                : Theme.fontUI

                        pixelSize: 10
                        bold: true
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        if (
                            window.fontBrowserTarget
                            === "general"
                        ) {
                            Config.fontFamily =
                                Typography.styleDefaultKey
                        } else {
                            Typography.clearModuleOverride(
                                window.fontBrowserTarget
                            )
                        }

                        window.fontBrowserOpen = false
                    }
                }
            }

            ListView {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: searchBox.bottom
                    bottom: parent.bottom

                    leftMargin: 18
                    rightMargin: 18
                    topMargin: 56
                    bottomMargin: 12
                }

                clip: true
                spacing: 2

                model:
                    Typography.filterFamilies(
                        window.fontSearch
                    )

                delegate: Rectangle {
                    required property string modelData

                    width: ListView.view.width
                    height: 36

                    radius: Theme.radiusSmall

                    readonly property bool selected:
                        window.fontBrowserTarget
                        === "general"
                            ? Config.fontFamily
                              === modelData
                            : Typography.moduleOverride(
                                  window.fontBrowserTarget
                              ) === modelData

                    color:
                        selected
                            ? Theme.surface
                            : "transparent"

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 11
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text: modelData

                        color:
                            parent.selected
                                ? Theme.accent
                                : Theme.foreground

                        font {
                            family: modelData
                            pixelSize: 10
                            bold: parent.selected
                        }
                    }

                    Text {
                        anchors {
                            right: parent.right
                            rightMargin: 11
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text: "Aa"

                        color:
                            Theme.foregroundMuted

                        font {
                            family: modelData
                            pixelSize: 11
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            if (
                                window.fontBrowserTarget
                                === "general"
                            ) {
                                Config.fontFamily =
                                    modelData
                            } else {
                                Typography.setModuleOverride(
                                    window.fontBrowserTarget,
                                    modelData
                                )
                            }

                            window.fontBrowserOpen = false
                        }
                    }
                }
            }
        }
    }
}
