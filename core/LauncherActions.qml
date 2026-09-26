pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property var definitions: [
        {
            id: "settings.open",
            globalName: "settings-open",
            name: "Open Settings",
            description: "Configure Seashell",
            icon: "preferences-system",
            keywords: ["preferences", "configure"],
            keybindAction: true
        },
        {
            id: "launcher.toggle",
            globalName: "launcher",
            name: "Toggle Launcher",
            description: "Open or close unified search",
            icon: "system-search",
            keywords: ["search", "applications"],
            defaultBinding: "SUPER+SPACE"
        },
        {
            id: "settings.toggle",
            globalName: "settings",
            name: "Toggle Settings",
            description: "Open or close Seashell Settings",
            icon: "preferences-system",
            keywords: ["preferences", "configure"],
            defaultBinding: "SUPER+COMMA"
        },
        {
            id: "wallpaper.next",
            globalName: "wallpaper-next",
            name: "Next Wallpaper",
            description: "Choose the next wallpaper",
            icon: "image-x-generic",
            keywords: ["background", "wallpaper"],
            keybindAction: true
        },
        {
            id: "appearance.open",
            globalName: "appearance",
            name: "Appearance Settings",
            description: "Choose style, palette and typography",
            icon: "preferences-desktop-theme",
            keywords: ["theme", "palette", "font"],
            keybindAction: true
        },
        {
            id: "shell.reload",
            globalName: "reload",
            name: "Reload Seashell",
            description: "Reload the shell configuration",
            icon: "view-refresh",
            keywords: ["restart", "refresh"],
            keybindAction: true
        },
        {
            id: "system.lock",
            globalName: "lock",
            name: "Lock Screen",
            description: "Invoke the selected lock screen provider",
            icon: "system-lock-screen",
            keywords: ["lock", "screen"],
            keybindAction: true
        },
        {
            id: "power.menu",
            globalName: "power",
            name: "Power Menu",
            description: "Open the selected power menu provider",
            icon: "system-shutdown",
            keywords: ["logout", "shutdown", "reboot"],
            keybindAction: true
        },
        {
            id: "screenshot.capture",
            globalName: "screenshot",
            name: "Capture Screenshot",
            description: "Capture a region with the selected screenshot provider",
            icon: "camera-photo",
            keywords: ["screen", "capture", "grim", "hyprshot"],
            keybindAction: true
        }
    ]

    function items() {
        return definitions.filter(action => action.id !== "launcher.toggle"
                && action.id !== "settings.toggle" && isAvailable(action.id)).map(action => ({
            type: "action",
            id: "action:" + action.id,
            name: action.name,
            description: action.description,
            icon: action.icon,
            keywords: action.keywords,
            source: "actions",
            actionId: action.id
        }))
    }

    function activate(item) {
        activateId(item.actionId)
    }

    function activateId(id) {
        switch (id) {
        case "launcher.toggle":
            ModuleManager.openLauncher()
            break
        case "settings.toggle":
            ShellState.toggleSettings()
            break
        case "settings.open":
            ShellState.showSettings("appearance", "general")
            break
        case "appearance.open":
            ShellState.showSettings("appearance", "component-style")
            break
        case "shell.reload":
            Quickshell.reload()
            break
        case "wallpaper.next":
            WallpaperState.nextWallpaper()
            break
        case "system.lock":
            ModuleManager.invokeSelected("lock")
            break
        case "power.menu":
            ModuleManager.invokeSelected("power")
            break
        case "screenshot.capture":
            ModuleManager.invokeSelected("screenshot")
            break
        }
    }

    function isAvailable(id) {
        if (id === "system.lock")
            return ModuleManager.activeProvider("lock") !== ""
                && PackageManager.stateFor(ModuleManager.activeProvider("lock")).installed
        if (id === "power.menu")
            return ModuleManager.activeProvider("power") !== ""
                && PackageManager.stateFor(ModuleManager.activeProvider("power")).installed
        if (id === "screenshot.capture")
            return ModuleManager.activeProvider("screenshot") !== ""
                && PackageManager.stateFor(ModuleManager.activeProvider("screenshot")).installed
        return definitions.some(action => action.id === id)
    }
}
