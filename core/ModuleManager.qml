pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.core

Singleton {
    id: root

    readonly property var categories: ModuleRegistry.categories
    readonly property var providers: ModuleRegistry.providers
    property bool waybarRunning: false
    property string transitionTarget: ""
    property string transitionPrevious: ""
    property string statusMessage: ""
    property bool startupCheckDone: false
    property string launcherProcessProvider: ""
    property string oneShotProvider: ""
    property string screenshotOutputPath: ""

    signal startWaybarRequested()
    signal stopWaybarRequested()

    function providersFor(category) {
        return ModuleRegistry.providersFor(category)
    }

    function provider(id) {
        return ModuleRegistry.provider(id)
    }

    function activeProvider(category) {
        const saved = Config.activeModules || {}
        if (category === "bar")
            return waybarRunning ? "bar.waybar"
                : (saved.bar === "waybar" ? "bar.seashell"
                    : saved.bar === "seashell" ? "bar.seashell" : saved.bar || "bar.seashell")
        if (category === "launcher")
            return saved.launcher || "launcher.seashell"
        if (category === "wallpaper")
            return saved.wallpaper || "wallpaper.seashell"
        if (category === "notifications" && saved["control-center"] === "control-center.swaync")
            return "notifications.swaync"
        if (category === "control-center" && saved.notifications === "notifications.swaync")
            return "control-center.swaync"
        return saved[category] || ""
    }

    function isActive(providerId) {
        const item = provider(providerId)
        if (item && item.category === "bar") {
            if (providerId === "bar.waybar")
                return waybarRunning || PackageManager.isRunning(providerId)
            if (providerId === "bar.seashell")
                return !waybarRunning && !PackageManager.isRunning("bar.waybar")
        }
        return !!item && activeProvider(item.category) === providerId
    }

    function state(providerId) {
        const item = provider(providerId)
        const packageState = PackageManager.stateFor(providerId)
        return Object.assign({}, packageState, {
            active: isActive(providerId),
            managedActive: activeProvider(item ? item.category : "") === providerId
                || ProviderProcessManager.managedSoftware(providerId),
            integrated: !!(item && item.supportsActivation),
            supportsActivation: !!(item && item.supportsActivation),
            supportsLifecycle: !!(item && item.supportsLifecycle),
            planned: !!(item && item.planned),
            canInstall: PackageManager.canInstall(providerId),
            canUninstall: PackageManager.canUninstall(providerId),
            canUse: !!(item && item.supportsActivation && packageState.installed),
            status: !item ? "Unavailable"
                : item.planned ? "Planned"
                : item.builtIn ? (isActive(providerId) ? "Active · built in" : "Built in")
                : isActive(providerId) ? (packageState.running && !packageState.managedActive
                    ? "Active · running externally"
                    : packageState.running ? "Active · running"
                    : "Active · selected")
                : packageState.installed ? "Installed"
                : packageState.available ? "Available · not installed"
                : packageState.checked ? "Unavailable" : "Checking availability…"
        })
    }

    function requestInstall(providerId) {
        return PackageManager.requestInstall(providerId)
    }

    function use(providerId) {
        const item = provider(providerId)
        if (!item || !item.supportsActivation) {
            statusMessage = "This provider is catalogued; Seashell does not manage its activation yet."
            return false
        }
        if (!PackageManager.stateFor(providerId).installed) {
            statusMessage = "Install this provider before using it."
            return false
        }
        if (item.category === "launcher" || item.category === "lock"
                || item.category === "power" || item.category === "screenshot") {
            Config.activeModules = Object.assign({}, Config.activeModules || {}, {
                [item.category]: providerId
            })
            statusMessage = item.name + " selected"
            return true
        }
        if (ProviderProcessManager.supports(providerId))
            return ProviderProcessManager.activate(providerId)
        if (item.category !== "bar") {
            statusMessage = "This provider has no activation adapter yet."
            return false
        }
        if (isActive(providerId) && PackageManager.isRunning(providerId))
            return true
        if (transitionTarget) {
            statusMessage = "A provider change is already in progress."
            return false
        }

        transitionPrevious = activeProvider("bar")
        transitionTarget = providerId
        if (providerId === "bar.waybar") {
            statusMessage = "Checking for another Waybar process…"
            waybarConflictProbe.running = true
        } else if (waybarRunning) {
            statusMessage = "Stopping Waybar and restoring the Seashell Bar…"
            stopWaybarRequested()
        } else if (PackageManager.isRunning("bar.waybar")) {
            transitionTarget = ""
            statusMessage = "Waybar is running outside Seashell. Stop it and refresh before switching bars."
        } else {
            finishNativeSwitch()
        }
        return true
    }

    function openLauncher() {
        const id = activeProvider("launcher") || "launcher.seashell"
        if (id === "launcher.seashell") {
            ShellState.toggleLauncher()
            return true
        }
        const provider = ModuleRegistry.provider(id)
        if (!provider || !PackageManager.stateFor(id).installed) {
            Config.activeModules = Object.assign({}, Config.activeModules || {}, {
                launcher: "launcher.seashell"
            })
            statusMessage = "Selected launcher is unavailable; restored Seashell Launcher."
            ShellState.toggleLauncher()
            return false
        }
        if (externalLauncher.running) {
            externalLauncher.running = false
            return true
        }
        launcherProcessProvider = id
        externalLauncher.command = launcherCommand(id)
        externalLauncher.running = true
        return true
    }

    function launcherCommand(id) {
        switch (id) {
        case "launcher.hyprlauncher": return ["hyprlauncher"]
        case "launcher.fuzzel": return ["fuzzel", "--config", ProviderThemeAdapter.pathFor(id)]
        case "launcher.rofi": return ["rofi", "-show", "drun", "-theme", ProviderThemeAdapter.pathFor(id)]
        case "launcher.wofi": return ["wofi", "--show", "drun", "--style", ProviderThemeAdapter.pathFor(id)]
        default: return []
        }
    }

    function invokeSelected(category) {
        const id = activeProvider(category)
        const commands = {
            "lock.hyprlock": ["hyprlock"],
            "lock.swaylock": ["swaylock"],
            "lock.gtklock": ["gtklock"],
            "power.wlogout": ["wlogout"]
        }
        if (category === "lock" && commands[id])
            return runOneShot(id, commands[id])
        if (category === "power" && commands[id])
            return runOneShot(id, commands[id])
        if (category === "screenshot" && id === "screenshot.hyprshot")
            return runOneShot(id, ["hyprshot", "-m", "region"])
        if (category === "screenshot" && id === "screenshot.grim")
            return captureGrimRegion()
        statusMessage = "No configured provider is available for " + category + "."
        return false
    }

    function runOneShot(providerId, command) {
        if (!PackageManager.stateFor(providerId).installed) {
            statusMessage = "Install " + ModuleRegistry.provider(providerId).name + " first."
            return false
        }
        if (oneShotProcess.running)
            return false
        oneShotProvider = providerId
        oneShotProcess.command = command
        oneShotProcess.running = true
        return true
    }

    function captureGrimRegion() {
        if (!PackageManager.stateFor("screenshot.grim").installed) {
            statusMessage = "Install grim and slurp first."
            return false
        }
        if (slurpProcess.running || mkdirProcess.running || grimProcess.running)
            return false
        const pictures = Quickshell.env("XDG_PICTURES_DIR")
            || (Quickshell.env("HOME") + "/Pictures")
        const stamp = new Date().toISOString().replace(/[T:.Z]/g, "-")
        screenshotOutputPath = pictures + "/Seashell-" + stamp + ".png"
        mkdirProcess.command = ["mkdir", "-p", pictures]
        mkdirProcess.running = true
        return true
    }

    function finishNativeSwitch() {
        waybarRunning = false
        Config.activeModules = Object.assign({}, Config.activeModules || {}, { bar: "bar.seashell" })
        statusMessage = "Seashell Bar active"
        transitionTarget = ""
        transitionPrevious = ""
    }

    function adapterStarted(providerId, success, message) {
        if (providerId !== "bar.waybar" || transitionTarget !== providerId)
            return
        if (!success) {
            waybarRunning = false
            PackageManager.setManagedRunning(providerId, false)
            transitionTarget = ""
            Config.activeModules = Object.assign({}, Config.activeModules || {}, { bar: "bar.seashell" })
            statusMessage = message || "Waybar did not start; Seashell Bar restored."
            return
        }
        waybarRunning = true
        PackageManager.setManagedRunning(providerId, true)
        Config.activeModules = Object.assign({}, Config.activeModules || {}, { bar: "bar.waybar" })
        statusMessage = "Waybar is running; Seashell Bar is stopped."
        transitionTarget = ""
        transitionPrevious = ""
    }

    function adapterStopped(providerId, success, message) {
        if (providerId !== "bar.waybar")
            return
        waybarRunning = false
        PackageManager.setManagedRunning(providerId, false)
        if (transitionTarget === "bar.seashell") {
            if (success)
                finishNativeSwitch()
            else {
                transitionTarget = ""
                statusMessage = message || "Could not stop Waybar; it remains selected."
            }
            return
        }
        if (!success || Config.activeModules.bar === "waybar"
                || Config.activeModules.bar === "bar.waybar") {
            Config.activeModules = Object.assign({}, Config.activeModules || {}, { bar: "bar.seashell" })
            statusMessage = message || "Waybar stopped unexpectedly; Seashell Bar restored."
        }
    }

    function checkSavedProvider() {
        if (startupCheckDone || PackageManager.probing || !PackageManager.hasProbed)
            return
        startupCheckDone = true
        const saved = Config.activeModules || {}
        if (saved.bar === "waybar" || saved.bar === "bar.waybar") {
            if (!PackageManager.stateFor("bar.waybar").installed) {
                Config.activeModules = Object.assign({}, saved, { bar: "bar.seashell" })
                statusMessage = "Saved Waybar provider is not installed; using Seashell Bar."
            } else use("bar.waybar")
        }
        const launcher = saved.launcher
        if (launcher && launcher !== "launcher.seashell"
                && !PackageManager.stateFor(launcher).installed) {
            Config.activeModules = Object.assign({}, Config.activeModules || {}, {
                launcher: "launcher.seashell"
            })
            statusMessage = "Saved launcher is unavailable; using Seashell Launcher."
        }
    }

    Process {
        id: waybarConflictProbe
        command: ["pgrep", "-x", "waybar"]
        onExited: (code) => {
            if (root.transitionTarget !== "bar.waybar")
                return
            if (code === 0) {
                root.transitionTarget = ""
                root.statusMessage = "Waybar is already running outside Seashell. Stop it before switching."
            } else if (code === 1) {
                root.statusMessage = "Starting Seashell-managed Waybar…"
                root.startWaybarRequested()
            } else {
                root.transitionTarget = ""
                root.statusMessage = "Could not check whether Waybar is already running."
            }
        }
    }

    Process {
        id: externalLauncher
        onExited: (code) => {
            if (code !== 0) {
                Config.activeModules = Object.assign({}, Config.activeModules || {}, {
                    launcher: "launcher.seashell"
                })
                root.statusMessage = "External launcher failed (code " + code
                    + "); Seashell Launcher restored."
                ShellState.toggleLauncher()
            }
        }
    }

    Process {
        id: oneShotProcess
        onExited: (code) => {
            if (code !== 0)
                root.statusMessage = ModuleRegistry.provider(root.oneShotProvider).name
                    + " exited with code " + code + "."
        }
    }

    Process {
        id: mkdirProcess
        onExited: code => {
            if (code !== 0) {
                root.statusMessage = "Could not prepare the Pictures folder for a screenshot."
                return
            }
            slurpProcess.command = ["slurp"]
            slurpProcess.running = true
        }
    }
    Process {
        id: slurpProcess
        stdout: StdioCollector { id: slurpOutput }
        onExited: code => {
            if (code !== 0 || !slurpOutput.text.trim()) {
                root.statusMessage = code === 130 ? "Screenshot selection cancelled."
                    : "Could not select a screenshot region."
                return
            }
            grimProcess.command = ["grim", "-g", slurpOutput.text.trim(), root.screenshotOutputPath]
            grimProcess.running = true
        }
    }
    Process {
        id: grimProcess
        onExited: code => root.statusMessage = code === 0
            ? "Screenshot saved to " + root.screenshotOutputPath
            : "grim failed to save the selected screenshot."
    }

    Connections {
        target: PackageManager
        function onProbingChanged() {
            if (!PackageManager.probing)
                root.checkSavedProvider()
        }
        function onHasProbedChanged() { root.checkSavedProvider() }
    }

    Component.onCompleted: checkSavedProvider()
}
