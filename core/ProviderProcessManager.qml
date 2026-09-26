pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.core

Singleton {
    id: root

    readonly property var supportedIds: [
        "notifications.mako", "notifications.swaync", "notifications.dunst",
        "wallpaper.swaybg", "idle.hypridle", "idle.swayidle",
        "osd.swayosd", "dock.nwg-dock-hyprland"
    ]
    property var managedIds: []
    property string pendingTarget: ""
    property string pendingPrevious: ""
    property string rollbackProvider: ""
    property string transitionMessage: ""
    property bool wallpaperRestartPending: false

    function supports(id) { return supportedIds.indexOf(id) !== -1 }

    function managedSoftware(id) {
        const item = ModuleRegistry.provider(id)
        return item && managedIds.some(managedId => {
            const candidate = ModuleRegistry.provider(managedId)
            return candidate && candidate.softwareId === item.softwareId
        })
    }

    function processFor(id) {
        for (let i = 0; i < processes.count; ++i) {
            const item = processes.objectAt(i)
            if (item && item.providerId === id) return item
        }
        return null
    }

    function commandFor(id) {
        switch (id) {
        case "notifications.mako": return ["mako"]
        case "notifications.swaync": return ["swaync"]
        case "notifications.dunst": return ["dunst"]
        case "wallpaper.swaybg": {
            const mode = Config.wallpaperFit === "contain" ? "fit"
                : Config.wallpaperFit === "stretch" ? "stretch" : "fill"
            const item = WallpaperState.activeItem
            const path = item ? (item.path.startsWith("/")
                ? item.path : Quickshell.shellPath(item.path)) : ""
            return path ? ["swaybg", "-i", path, "-m", mode] : []
        }
        case "idle.hypridle": return ["hypridle", "-c", Quickshell.statePath("seashell-hypridle.conf")]
        case "idle.swayidle": return ["swayidle", "-w", "timeout", "300",
            "qs ipc call seashell action system.lock"]
        case "osd.swayosd": return ["swayosd-server"]
        case "dock.nwg-dock-hyprland": return ["nwg-dock-hyprland"]
        default: return []
        }
    }

    function categoryRunningElsewhere(providerId) {
        const target = ModuleRegistry.provider(providerId)
        if (!target) return ""
        const candidates = ModuleRegistry.providers.filter(item => item.category === target.category
            && item.id !== providerId && PackageManager.isRunning(item.id))
        return candidates.length ? candidates[0].id : ""
    }

    function activate(providerId) {
        if (!supports(providerId)) return false
        const target = ModuleRegistry.provider(providerId)
        const process = processFor(providerId)
        if (!target || !process || !PackageManager.stateFor(providerId).installed) {
            ModuleManager.statusMessage = "Install this provider before using it."
            return false
        }
        if (pendingTarget || transitionMessage) {
            ModuleManager.statusMessage = "A provider change is already in progress."
            return false
        }
        const command = commandFor(providerId)
        if (!command.length) {
            ModuleManager.statusMessage = "The selected wallpaper pool is empty, so swaybg was not started."
            return false
        }
        if (target.category === "idle") {
            const lockId = ModuleManager.activeProvider("lock")
            if (!lockId || !PackageManager.stateFor(lockId).installed) {
                ModuleManager.statusMessage = "Select and install a lock provider before enabling idle locking."
                return false
            }
        }
        if (managedSoftware(providerId)) {
            Config.activeModules = Object.assign({}, Config.activeModules || {}, {
                [target.category]: providerId
            })
            ModuleManager.statusMessage = target.name + " shares an already-running managed service."
            return true
        }
        if (PackageManager.isRunning(providerId) && managedIds.indexOf(providerId) === -1) {
            ModuleManager.statusMessage = "This provider is already running outside Seashell; it was not duplicated or stopped."
            return false
        }
        const occupied = categoryRunningElsewhere(providerId)
        if (occupied && managedIds.indexOf(occupied) === -1) {
            ModuleManager.statusMessage = "Stop the already-running provider before switching; Seashell will not kill an unmanaged process."
            return false
        }
        pendingTarget = providerId
        pendingPrevious = occupied || ""
        rollbackProvider = occupied || ""
        if (occupied) {
            transitionMessage = "Stopping " + ModuleRegistry.provider(occupied).name + "…"
            processFor(occupied).running = false
        } else {
            startPending()
        }
        return true
    }

    function startPending() {
        const id = pendingTarget
        if (!id) return
        const process = processFor(id)
        if (!process) { failPending("No process adapter exists for this provider."); return }
        transitionMessage = "Starting " + ModuleRegistry.provider(id).name + "…"
        if (id === "idle.hypridle")
            hypridleConfig.setText("general {\n  lock_cmd = qs ipc call seashell action system.lock\n}\n\nlistener {\n  timeout = 300\n  on-timeout = qs ipc call seashell action system.lock\n}\n")
        else {
            process.command = commandFor(id)
            process.running = true
        }
    }

    function failPending(message) {
        const target = pendingTarget
        const rollback = rollbackProvider
        pendingTarget = ""
        pendingPrevious = ""
        transitionMessage = ""
        rollbackProvider = ""
        if (rollback && rollback !== target && PackageManager.stateFor(rollback).installed) {
            pendingTarget = rollback
            transitionMessage = "Restoring " + ModuleRegistry.provider(rollback).name + "…"
            ModuleManager.statusMessage = message + " Restoring the previous provider."
            startPending()
            return
        }
        ModuleManager.statusMessage = message || (ModuleRegistry.provider(target).name + " failed to start; the previous provider remains selected where possible.")
    }

    function started(id) {
        if (id !== pendingTarget) {
            if (managedIds.indexOf(id) !== -1)
                PackageManager.setManagedRunning(id, true)
            return
        }
        const provider = ModuleRegistry.provider(id)
        PackageManager.setManagedRunning(id, true)
        managedIds = managedIds.indexOf(id) === -1 ? managedIds.concat([id]) : managedIds
        Config.activeModules = Object.assign({}, Config.activeModules || {}, { [provider.category]: id })
        ModuleManager.statusMessage = provider.name + " is running."
        pendingTarget = ""
        pendingPrevious = ""
        rollbackProvider = ""
        transitionMessage = ""
    }

    function stopped(id, code) {
        PackageManager.setManagedRunning(id, false)
        if (id === "wallpaper.swaybg" && wallpaperRestartPending) {
            wallpaperRestartPending = false
            const process = processFor(id)
            if (process) {
                process.command = commandFor(id)
                process.running = process.command.length > 0
            }
            return
        }
        managedIds = managedIds.filter(item => item !== id)
        if (pendingTarget && pendingPrevious === id) {
            pendingPrevious = ""
            startPending()
            return
        }
        if (pendingTarget === id) {
            failPending(ModuleRegistry.provider(id).name + " exited during startup (code " + code + ").")
            return
        }
        const provider = ModuleRegistry.provider(id)
        if (provider && Object.keys(Config.activeModules || {}).some(category => {
            const selected = ModuleRegistry.provider(Config.activeModules[category])
            return selected && selected.softwareId === provider.softwareId
        })) {
            const next = Object.assign({}, Config.activeModules || {})
            for (const category of Object.keys(next)) {
                const selected = ModuleRegistry.provider(next[category])
                if (selected && selected.softwareId === provider.softwareId)
                    delete next[category]
            }
            Config.activeModules = next
            ModuleManager.statusMessage = provider.name + " stopped (code " + code + ")."
        }
        transitionMessage = ""
    }

    function deactivate(providerId) {
        const provider = ModuleRegistry.provider(providerId)
        const managedId = managedIds.find(id => {
            const item = ModuleRegistry.provider(id)
            return provider && item && item.softwareId === provider.softwareId
        })
        const process = managedId ? processFor(managedId) : null
        if (!process) return false
        if (pendingTarget) return false
        const saved = Config.activeModules || {}
        const stillNeeded = Object.keys(saved).some(category => {
            if (category === provider.category) return false
            const selected = ModuleRegistry.provider(saved[category])
            return selected && selected.softwareId === provider.softwareId
        })
        if (stillNeeded) {
            const next = Object.assign({}, saved)
            delete next[provider.category]
            Config.activeModules = next
            ModuleManager.statusMessage = provider.name + " remains running for its other selected capability."
            return true
        }
        pendingTarget = ""
        transitionMessage = "Stopping " + ModuleRegistry.provider(providerId).name + "…"
        process.running = false
        return true
    }

    Instantiator {
        id: processes
        model: root.supportedIds
        delegate: Process {
            required property string modelData
            readonly property string providerId: modelData
            onRunningChanged: if (running) root.started(providerId)
            onExited: code => root.stopped(providerId, code)
        }
    }

    Connections {
        target: WallpaperState
        function onActiveSourceChanged() {
            const process = root.processFor("wallpaper.swaybg")
            if (process && process.running && root.managedIds.indexOf("wallpaper.swaybg") !== -1) {
                root.wallpaperRestartPending = true
                process.running = false
            }
        }
    }

    Connections {
        target: Config
        function onWallpaperFitChanged() {
            const process = root.processFor("wallpaper.swaybg")
            if (process && process.running && root.managedIds.indexOf("wallpaper.swaybg") !== -1) {
                root.wallpaperRestartPending = true
                process.running = false
            }
        }
    }

    FileView {
        id: hypridleConfig
        path: Quickshell.statePath("seashell-hypridle.conf")
        onSaved: {
            const process = root.processFor("idle.hypridle")
            if (root.pendingTarget === "idle.hypridle" && process) {
                process.command = root.commandFor("idle.hypridle")
                process.running = true
            }
        }
        onSaveFailed: root.failPending("Could not write Seashell's hypridle configuration.")
    }
}
