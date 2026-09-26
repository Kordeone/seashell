import QtQuick
import Quickshell
import Quickshell.Io

import qs.core

Scope {
    id: root

    readonly property bool wantsWaybar: ModuleManager.isActive("bar", "waybar")
    readonly property string css: makeCss(
        Theme.background, Theme.surface, Theme.foreground,
        Theme.foregroundMuted, Theme.accent, Theme.border,
        Theme.fontUI, Theme.radiusMedium)
    property bool configReady: false
    property bool styleReady: false
    property bool pendingRestart: false
    property bool initialized: false
    property bool shuttingDown: false

    function hex(color) {
        function byte(value) {
            return Math.round(value * 255).toString(16).padStart(2, "0")
        }
        return "#" + byte(color.r) + byte(color.g) + byte(color.b)
    }

    function makeCss(background, surface, foreground, muted, accent, border, font, radius) {
        const family = font.replace(/["\\]/g, "")
        return "* { font-family: \"" + family + "\"; }\n"
            + "window#waybar { background: " + hex(background) + "; color: "
            + hex(foreground) + "; border-bottom: 1px solid " + hex(border) + "; }\n"
            + "#workspaces button { color: " + hex(muted) + "; background: "
            + hex(surface) + "; border-radius: " + radius + "px; }\n"
            + "#workspaces button.active { color: " + hex(accent) + "; }\n"
            + "#clock { color: " + hex(foreground) + "; background: " + hex(surface)
            + "; border: 1px solid " + hex(border) + "; border-radius: "
            + radius + "px; padding: 0 12px; }\n"
    }

    function updateRunning() {
        if (!wantsWaybar) {
            pendingRestart = false
            waybar.running = false
        } else if (configReady && styleReady && !waybar.running) {
            waybar.running = true
        }
    }

    onCssChanged: {
        if (!initialized)
            return
        styleReady = false
        if (waybar.running) {
            pendingRestart = true
            waybar.running = false
        }
        styleFile.setText(css)
    }
    onWantsWaybarChanged: updateRunning()

    FileView {
        id: configFile
        path: Quickshell.statePath("seashell-waybar.jsonc")
        onSaved: {
            root.configReady = true
            root.updateRunning()
        }
        onSaveFailed: {
            root.configReady = false
            ModuleManager.activate("bar", "seashell")
            ModuleManager.statusMessage = "Could not write Seashell Waybar config"
        }
    }
    FileView {
        id: styleFile
        path: Quickshell.statePath("seashell-waybar.css")
        onSaved: {
            root.styleReady = true
            if (!root.pendingRestart)
                root.updateRunning()
        }
        onSaveFailed: {
            root.styleReady = false
            ModuleManager.activate("bar", "seashell")
            ModuleManager.statusMessage = "Could not write Seashell Waybar style"
        }
    }

    Process {
        id: waybar
        command: [
            "waybar", "-c", Quickshell.statePath("seashell-waybar.jsonc"),
            "-s", Quickshell.statePath("seashell-waybar.css")
        ]
        onExited: (code) => {
            if (root.pendingRestart) {
                root.pendingRestart = false
                root.updateRunning()
            } else if (root.wantsWaybar && !root.shuttingDown) {
                ModuleManager.activate("bar", "seashell")
                ModuleManager.statusMessage = "Waybar exited with code " + code
            }
        }
    }

    Component.onCompleted: {
        initialized = true
        configReady = false
        styleReady = false
        configFile.setText(JSON.stringify({
            layer: "top",
            position: "top",
            height: 32,
            "modules-left": ["hyprland/workspaces"],
            "modules-center": ["clock"],
            clock: { format: "{:%H:%M}" }
        }, null, 2))
        styleFile.setText(css)
    }
    Component.onDestruction: shuttingDown = true
}
