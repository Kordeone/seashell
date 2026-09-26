pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property var definitions: [
        {
            id: "settings.open",
            name: "Open Settings",
            description: "Configure Seashell",
            icon: "preferences-system",
            keywords: ["preferences", "configure"]
        },
        {
            id: "appearance.open",
            name: "Appearance Settings",
            description: "Choose style, palette and typography",
            icon: "preferences-desktop-theme",
            keywords: ["theme", "palette", "font"]
        },
        {
            id: "shell.reload",
            name: "Reload Seashell",
            description: "Reload the shell configuration",
            icon: "view-refresh",
            keywords: ["restart", "refresh"]
        }
    ]

    function items() {
        return definitions.map(action => ({
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
        switch (item.actionId) {
        case "settings.open":
            ShellState.showSettings("appearance", "general")
            break
        case "appearance.open":
            ShellState.showSettings("appearance", "component-style")
            break
        case "shell.reload":
            Quickshell.reload()
            break
        }
    }
}
