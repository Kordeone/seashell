import QtQuick
import Quickshell
import Quickshell.Io

import qs.core

Scope {
    id: root

    readonly property bool wantsWaybar: ModuleManager.activeProvider("bar") === "bar.waybar"
        || ModuleManager.transitionTarget === "bar.waybar"
    readonly property string css: makeCss(
        Theme.background, Theme.surface, Theme.surfaceRaised, Theme.foreground,
        Theme.foregroundMuted, Theme.accent, Theme.border, Theme.focus,
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

    function makeCss(background, surface, raised, foreground, muted, accent, border, focus, font, radius) {
        const family = font.replace(/["\\]/g, "")
        return "* { font-family: \"" + family + "\"; }\n"
            + "window#waybar { background: " + hex(background) + "; color: "
            + hex(foreground) + "; border-bottom: 1px solid " + hex(border) + "; }\n"
            + "#workspaces button { color: " + hex(muted) + "; background: "
            + hex(surface) + "; border-radius: " + radius + "px; }\n"
            + "#workspaces button.active { color: " + hex(accent) + "; }\n"
            + "#workspaces button:hover { background: " + hex(raised)
            + "; border-color: " + hex(focus) + "; }\n"
            + "#clock { color: " + hex(foreground) + "; background: " + hex(surface)
            + "; border: 1px solid " + hex(border) + "; border-radius: "
            + radius + "px; padding: 0 12px; }\n"
    }

    function updateRunning() {
        if (!wantsWaybar) {
            pendingRestart = false
            if (waybar.running)
                waybar.running = false
            else if (ModuleManager.transitionTarget === "bar.seashell")
                ModuleManager.adapterStopped("bar.waybar", true, "")
        } else if (configReady && styleReady && !waybar.running) {
            waybar.running = true
        }
    }

    function prepareToStart() {
        if (!configReady || !styleReady) {
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
            return
        }
        updateRunning()
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
            ModuleManager.adapterStarted("bar.waybar", false,
                "Could not write the Seashell-owned Waybar config.")
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
            if (ModuleManager.waybarRunning)
                ModuleManager.adapterStopped("bar.waybar", false,
                    "Could not write the Seashell-owned Waybar stylesheet; Seashell Bar restored.")
            else
                ModuleManager.adapterStarted("bar.waybar", false,
                    "Could not write the Seashell-owned Waybar stylesheet.")
        }
    }

    Process {
        id: waybar
        command: [
            "waybar", "-c", Quickshell.statePath("seashell-waybar.jsonc"),
            "-s", Quickshell.statePath("seashell-waybar.css")
        ]
        onRunningChanged: {
            if (running && ModuleManager.transitionTarget === "bar.waybar")
                ModuleManager.adapterStarted("bar.waybar", true, "")
        }
        onExited: (code) => {
            if (root.shuttingDown) {
                return
            } else if (root.pendingRestart) {
                root.pendingRestart = false
                root.updateRunning()
            } else if (ModuleManager.transitionTarget === "bar.seashell") {
                ModuleManager.adapterStopped("bar.waybar", true, "")
            } else if (ModuleManager.transitionTarget === "bar.waybar") {
                ModuleManager.adapterStarted("bar.waybar", false,
                    "Waybar exited during startup (code " + code + ").")
            } else if (root.wantsWaybar && !root.shuttingDown) {
                ModuleManager.adapterStopped("bar.waybar", false,
                    "Waybar exited unexpectedly (code " + code + "); Seashell Bar restored.")
            }
        }
    }

    Connections {
        target: ModuleManager
        function onStartWaybarRequested() { root.prepareToStart() }
        function onStopWaybarRequested() {
            root.pendingRestart = false
            waybar.running = false
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
