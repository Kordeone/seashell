pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var categories: [
        { id: "bar", name: "Bar", ready: true },
        { id: "notifications", name: "Notifications", ready: false },
        { id: "wallpaper", name: "Wallpaper", ready: false },
        { id: "lock", name: "Lock / Idle", ready: false },
        { id: "osd", name: "OSD", ready: false },
        { id: "control-center", name: "Control Center", ready: false },
        { id: "dock", name: "Dock", ready: false }
    ]

    readonly property var barProviders: [
        {
            id: "seashell", category: "bar", name: "Seashell Bar",
            description: "Built-in Seashell bar", builtIn: true,
            packageName: "", supportsThemeSync: true, supportsSettings: true
        },
        {
            id: "waybar", category: "bar", name: "Waybar",
            description: "External Wayland bar", builtIn: false,
            packageName: "waybar", supportsThemeSync: true, supportsSettings: false
        }
    ]

    property bool waybarInstalled: false
    property bool pkexecInstalled: false
    property bool pacmanInstalled: false
    property bool installationRunning: false
    property bool activationPending: false
    property bool waybarAllowed: false
    property string statusMessage: ""

    function activeProvider(category) {
        const values = Config.activeModules || {}
        if (category === "bar" && values.bar === "waybar"
                && waybarInstalled && waybarAllowed)
            return "waybar"
        return "seashell"
    }

    function isActive(category, provider) {
        return activeProvider(category) === provider
    }

    function installed(provider) {
        return provider === "seashell" || (provider === "waybar" && waybarInstalled)
    }

    function activate(category, provider) {
        if (category !== "bar" || (provider !== "seashell" && provider !== "waybar"))
            return false
        if (!installed(provider)) {
            statusMessage = "Install Waybar before using it."
            return false
        }
        if (provider === "waybar") {
            if (activationPending)
                return false
            activationPending = true
            statusMessage = "Checking for an existing Waybar process…"
            waybarConflictProbe.running = true
            return true
        }
        activationPending = false
        waybarAllowed = false
        Config.activeModules = Object.assign({}, Config.activeModules || {}, { bar: "seashell" })
        statusMessage = "Seashell Bar active"
        return true
    }

    function refreshAvailability() {
        waybarProbe.running = true
        pkexecProbe.running = true
        pacmanProbe.running = true
    }

    function installWaybar() {
        if (waybarInstalled || installationRunning || !pkexecInstalled || !pacmanInstalled)
            return false
        installationRunning = true
        statusMessage = "Requesting system authorization for pacman -S --needed waybar"
        installProcess.exec(["pkexec", "pacman", "-S", "--needed", "waybar"])
        return true
    }

    Process {
        id: waybarProbe
        command: ["which", "waybar"]
        onExited: (code) => {
            root.waybarInstalled = code === 0
            if (root.waybarInstalled && (Config.activeModules || {}).bar === "waybar"
                    && !root.waybarAllowed && !root.activationPending) {
                root.activationPending = true
                waybarConflictProbe.running = true
            }
        }
    }
    Process {
        id: pkexecProbe
        command: ["which", "pkexec"]
        onExited: (code) => root.pkexecInstalled = code === 0
    }
    Process {
        id: pacmanProbe
        command: ["which", "pacman"]
        onExited: (code) => root.pacmanInstalled = code === 0
    }
    Process {
        id: waybarConflictProbe
        command: ["pgrep", "-x", "waybar"]
        onExited: (code) => {
            if (!root.activationPending)
                return
            root.activationPending = false
            if (code === 0) {
                root.statusMessage = "Waybar is already running outside Seashell; stop it before switching."
            } else if (code === 1) {
                root.waybarAllowed = true
                Config.activeModules = Object.assign({}, Config.activeModules || {}, { bar: "waybar" })
                root.statusMessage = "Starting Seashell-managed Waybar"
            } else {
                root.statusMessage = "Could not check for an existing Waybar process"
            }
        }
    }
    Process {
        id: installProcess
        onExited: (code) => {
            root.installationRunning = false
            root.statusMessage = code === 0
                ? "Waybar installed. Select Use to activate it."
                : "Installation was cancelled or failed."
            root.refreshAvailability()
        }
    }

    Component.onCompleted: refreshAvailability()
}
