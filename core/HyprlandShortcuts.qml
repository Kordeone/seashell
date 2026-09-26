import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import qs.core

Scope {
    id: root
    property var operations: []
    property bool resyncRequested: false
    property string issues: ""
    property bool failed: false
    readonly property bool luaMode: Hyprland.usingLua
    onLuaModeChanged: syncTimer.restart()

    GlobalShortcut {
        appid: "seashell"
        name: "launcher.toggle"
        description: "Open Seashell Launcher"
        onPressed: Keybinds.run("launcher.toggle")
    }
    GlobalShortcut {
        appid: "seashell"
        name: "settings.toggle"
        description: "Open Seashell Settings"
        onPressed: Keybinds.run("settings.toggle")
    }

    function parts(binding) {
        const tokens = binding.split("+")
        const key = tokens.pop()
        let mask = 0
        const mods = []
        for (const token of tokens) {
            if (token === "SUPER") { mask |= 64; mods.push("SUPER") }
            if (token === "CTRL") { mask |= 4; mods.push("CTRL") }
            if (token === "ALT") { mask |= 8; mods.push("ALT") }
            if (token === "SHIFT") { mask |= 1; mods.push("SHIFT") }
        }
        return {
            mask: mask,
            key: key === "COMMA" ? "comma" : key === "SPACE" ? "space" : key,
            mods: mods.join("_")
        }
    }

    function sameCombo(bind, parts) {
        const submap = String(bind.submap || "")
        return (submap === "" || submap === "reset" || submap === "default")
            && Number(bind.modmask) === parts.mask
            && String(bind.key).toLowerCase() === parts.key.toLowerCase()
    }

    function modsFromMask(mask) {
        const mods = []
        if (mask & 64) mods.push("SUPER")
        if (mask & 4) mods.push("CTRL")
        if (mask & 8) mods.push("ALT")
        if (mask & 1) mods.push("SHIFT")
        return mods.join("_")
    }

    function ownedAction(bind) {
        if (String(bind.description || "").startsWith("Seashell: "))
            return String(bind.description).slice("Seashell: ".length)
        if (bind.dispatcher === "global" && String(bind.arg).startsWith("seashell:"))
            return String(bind.arg).slice("seashell:".length)
        return ""
    }

    function luaKeys(parts) {
        return (parts.mods ? parts.mods.split("_").join(" + ") + " + " : "")
            + parts.key
    }

    function scheduleSync() {
        if (query.running || change.running) {
            resyncRequested = true
            return
        }
        query.exec(["hyprctl", "-j", "binds"])
    }

    function reconcile(binds) {
        const steps = []
        const conflicts = []
        for (const action of Keybinds.actions) {
            const target = "seashell:" + action.id
            const desired = parts(Keybinds.binding(action.id))
            const owned = binds.filter(bind => ownedAction(bind) === action.id)
            const otherOnDesired = binds.find(bind =>
                sameCombo(bind, desired) && ownedAction(bind) !== action.id)

            if (otherOnDesired) {
                conflicts.push(action.name + " conflicts with an existing Hyprland bind")
                continue
            }

            let blocked = false
            for (const old of owned) {
                if (sameCombo(old, desired))
                    continue
                const oldParts = { mask: Number(old.modmask), key: String(old.key) }
                const shared = binds.some(bind => bind !== old && sameCombo(bind, oldParts))
                if (shared) {
                    conflicts.push("Cannot remove shared binding for " + action.name)
                    blocked = true
                    continue
                }
                const oldMods = modsFromMask(Number(old.modmask))
                steps.push(luaMode
                    ? { command: ["hyprctl", "eval", "hl.unbind(\""
                        + luaKeys({ mods: oldMods, key: old.key }) + "\")"] }
                    : { command: ["hyprctl", "keyword", "unbind",
                        oldMods + "," + old.key] })
            }
            if (!blocked && !owned.some(bind => sameCombo(bind, desired))) {
                steps.push(luaMode
                    ? { command: ["hyprctl", "eval", "hl.bind(\""
                        + luaKeys(desired) + "\", hl.dsp.global(\"" + target
                        + "\"), { description = \"Seashell: " + action.id + "\" })"] }
                    : { command: ["hyprctl", "keyword", "bind",
                        desired.mods + "," + desired.key + ",global," + target] })
            }
        }
        issues = conflicts.join("; ")
        failed = false
        Keybinds.backendStatus = steps.length ? "Applying Hyprland shortcuts…"
            : issues || "Hyprland global shortcuts active ("
                + (luaMode ? "Lua" : "classic") + ")"
        operations = steps
        nextOperation()
    }

    function nextOperation() {
        if (!operations.length) {
            Keybinds.backendStatus = failed ? "Hyprland rejected a shortcut change"
                : issues || "Hyprland global shortcuts active ("
                    + (luaMode ? "Lua" : "classic") + ")"
            if (resyncRequested) {
                resyncRequested = false
                scheduleSync()
            }
            return
        }
        const operation = operations.shift()
        change.exec(operation.command)
    }

    Timer {
        id: syncTimer
        interval: 120
        onTriggered: root.scheduleSync()
    }
    Connections {
        target: Config
        function onKeybindsChanged() { syncTimer.restart() }
    }
    Process {
        id: query
        stdout: StdioCollector {}
        onExited: (code) => {
            if (code !== 0) {
                Keybinds.backendStatus = "Hyprland binding query failed"
                return
            }
            try {
                root.reconcile(JSON.parse(stdout.text))
            } catch (error) {
                Keybinds.backendStatus = "Cannot read Hyprland bindings: " + error
            }
        }
    }
    Process {
        id: change
        onExited: (code) => {
            if (code !== 0) {
                root.failed = true
                root.operations = []
            }
            root.nextOperation()
        }
    }

    Component.onCompleted: syncTimer.start()
}
