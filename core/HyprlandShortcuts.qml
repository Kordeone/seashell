import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import qs.core

Scope {
    id: root

    property var bindings: []
    property var conflicts: ({})
    property var pendingConflicts: []
    property var pendingApply: null
    property string issue: ""
    property string generatedStatus: "Preparing generated Hyprland bindings…"
    readonly property bool luaMode: Hyprland.usingLua
    readonly property string hyprConfigDir: {
        const configHome = Quickshell.env("XDG_CONFIG_HOME")
        const home = Quickshell.env("HOME")
        return (configHome ? configHome : home + "/.config") + "/hypr"
    }
    readonly property string globalShortcutList: Keybinds.actions.map(item =>
        "seashell:" + item.globalName).join("\n")
    readonly property string generatedFilePath: hyprConfigDir + (luaMode
        ? "/seashell.lua" : "/seashell.conf")

    function normalizeKey(key) {
        const name = String(key || "").toLowerCase()
        const names = { " ": "space", ",": "comma", "enter": "return",
            "esc": "escape", "printscreen": "print" }
        return names[name] || name
    }

    function keyParts(binding) {
        const tokens = Keybinds.normalized(binding).split("+")
        const key = tokens.pop()
        const modifiers = tokens.map(token => token === "SUPER" ? "SUPER"
            : token === "CTRL" ? "CTRL" : token === "ALT" ? "ALT" : "SHIFT")
        return { mask: modifierMask(modifiers), key: normalizeKey(key), modifiers: modifiers }
    }

    function hyprlandKey(key) {
        const normalized = normalizeKey(key)
        const names = { " ": "SPACE", ",": "COMMA", space: "SPACE", comma: "COMMA",
            "return": "Return", enter: "Return",
            escape: "Escape", tab: "Tab", print: "Print", left: "Left", right: "Right",
            up: "Up", down: "Down" }
        if (names[normalized]) return names[normalized]
        if (/^f([1-9]|1[0-2])$/i.test(normalized)) return normalized.toUpperCase()
        return normalized.length === 1 ? normalized.toUpperCase() : normalized
    }

    function modifierMask(modifiers) {
        let mask = 0
        for (const token of modifiers) {
            if (token === "SUPER") mask |= 64
            if (token === "CTRL") mask |= 4
            if (token === "ALT") mask |= 8
            if (token === "SHIFT") mask |= 1
        }
        return mask
    }

    function sameCombo(bind, desired) {
        const submap = String(bind.submap || "")
        return (submap === "" || submap === "reset" || submap === "default")
            && Number(bind.modmask) === desired.mask
            && normalizeKey(bind.key) === desired.key
    }

    function globalNameForAction(id) {
        const item = Keybinds.action(id)
        return item ? item.globalName : ""
    }

    function actionForBind(bind) {
        if (String(bind.dispatcher || "") !== "global") return ""
        const arg = String(bind.arg || "")
        if (!arg.startsWith("seashell:")) return ""
        const name = arg.slice("seashell:".length)
        const item = Keybinds.actions.find(action => action.globalName === name)
        return item ? item.id : ""
    }

    function displayOwner(bind) {
        const description = String(bind.description || "").trim()
        if (description) return description
        return String(bind.dispatcher || "Hyprland action") + " · " + String(bind.arg || "")
    }

    function conflictsFor(id, candidate) {
        const binding = candidate || Keybinds.binding(id)
        if (!binding) return []
        const desired = keyParts(binding)
        return bindings.filter(bind => sameCombo(bind, desired) && actionForBind(bind) !== id)
    }

    function refresh() {
        bindQueryOutput.text = ""
        bindQuery.exec(["hyprctl", "-j", "binds"])
    }

    function reconcile(value) {
        bindings = value
        const next = ({})
        for (const action of Keybinds.actions) {
            const candidate = Keybinds.binding(action.id)
            const occupied = conflictsFor(action.id, candidate)
            next[action.id] = occupied.map(bind => ({ owner: displayOwner(bind),
                source: "Active Hyprland binding; file path is not reported by hyprctl" }))
        }
        conflicts = next
        generatedStatus = "Active config mode: " + (luaMode ? "Lua" : "Hyprlang")
            + " · generated file saved; include it once in your Hyprland config"
        syncGeneratedFiles()
    }

    function requestApply(id, candidate, reset) {
        const normalized = Keybinds.normalized(candidate)
        if (!Keybinds.action(id) || !normalized) {
            issue = "Choose a supported key combination with at least one modifier."
            return false
        }
        const duplicate = Keybinds.duplicate(id, normalized)
        if (duplicate) {
            issue = "Already assigned to " + duplicate.name + "."
            return false
        }
        const occupied = conflictsFor(id, normalized)
        if (occupied.length) {
            pendingApply = { id: id, binding: normalized, reset: !!reset }
            pendingConflicts = occupied.map(bind => ({ owner: displayOwner(bind),
                source: "Active Hyprland binding; file path is not reported by hyprctl" }))
            issue = "This key is already bound. Review the owner before replacing it."
            return false
        }
        return saveBinding(id, normalized, reset, false)
    }

    function confirmReplace() {
        if (!pendingApply) return false
        const request = pendingApply
        const owned = conflictsFor(request.id, request.binding)
        const approvals = Object.assign({}, Config.keybindApprovals || {})
        approvals[request.id] = { binding: request.binding,
            displaced: owned.map(bind => ({ dispatcher: bind.dispatcher, arg: bind.arg,
                description: bind.description || "", modmask: bind.modmask, key: bind.key })) }
        Config.keybindApprovals = approvals
        pendingApply = null
        pendingConflicts = []
        return saveBinding(request.id, request.binding, request.reset, true)
    }

    function cancelPending() {
        pendingApply = null
        pendingConflicts = []
        issue = ""
    }

    function requestClear(id) {
        if (!Keybinds.action(id)) return false
        Keybinds.clear(id)
        const approvals = Object.assign({}, Config.keybindApprovals || {})
        delete approvals[id]
        Config.keybindApprovals = approvals
        issue = ""
        syncGeneratedFiles()
        return true
    }

    function saveBinding(id, normalized, reset, replaced) {
        const savedApproval = (Config.keybindApprovals || {})[id]
        if (reset) Keybinds.reset(id)
        else Keybinds.setBinding(id, normalized)
        if (replaced && savedApproval) {
            Config.keybindApprovals = Object.assign({}, Config.keybindApprovals || {}, {
                [id]: savedApproval
            })
        } else {
            const approvals = Object.assign({}, Config.keybindApprovals || {})
            delete approvals[id]
            Config.keybindApprovals = approvals
        }
        issue = ""
        syncGeneratedFiles()
        generatedStatus = "Binding saved to Seashell's generated Hyprland config. Reload Hyprland after including the file."
        return true
    }

    function formatHyprlang(binding, action) {
        const parts = keyParts(binding)
        const key = hyprlandKey(parts.key)
        return parts.modifiers.join(" ") + ", " + key + ", global, seashell:"
            + action.globalName
    }

    function formatLua(binding, action) {
        const parts = keyParts(binding)
        const chord = parts.modifiers.join(" + ") + " + " + hyprlandKey(parts.key)
        return 'hl.bind("' + chord + '", hl.dsp.global("seashell:'
            + action.globalName + '"), { description = "Seashell: '
            + action.id + '" })'
    }

    function generatedText(lua) {
        const lines = [lua ? "-- Generated by Seashell. Do not edit this file."
            : "# Generated by Seashell. Do not edit this file."]
        for (const action of Keybinds.actions) {
            const binding = Keybinds.binding(action.id)
            if (!binding) continue
            const approval = (Config.keybindApprovals || {})[action.id]
            const approvedBinding = typeof approval === "string" ? approval
                : (approval ? approval.binding : "")
            const replace = approvedBinding === binding
            if (replace) {
                const parts = keyParts(binding)
                if (lua) {
                    const chord = parts.modifiers.join(" + ") + " + " + hyprlandKey(parts.key)
                    lines.push('hl.unbind("' + chord + '")')
                } else {
                    lines.push("unbind = " + parts.modifiers.join(" ") + ", " + hyprlandKey(parts.key))
                }
            }
            lines.push(lua ? formatLua(binding, action)
                : "bind = " + formatHyprlang(binding, action))
        }
        return lines.join("\n") + "\n"
    }

    function syncGeneratedFiles() {
        if (!hyprConfigDir || hyprConfigDir === "/hypr") {
            generatedStatus = "HOME is unavailable; could not determine the Hyprland config folder."
            return
        }
        const existingLua = luaConfig.text()
        const existingLang = langConfig.text()
        if ((existingLua.length && !existingLua.startsWith("-- Generated by Seashell."))
                || (existingLang.length && !existingLang.startsWith("# Generated by Seashell."))) {
            generatedStatus = "A non-Seashell file already uses the generated config path; it was left untouched."
            return
        }
        const lua = generatedText(true)
        const lang = generatedText(false)
        luaConfig.setText(lua)
        langConfig.setText(lang)
    }

    function handleGlobalAction(id) {
        LauncherActions.activateId(id)
    }

    Instantiator {
        model: Keybinds.actions
        delegate: GlobalShortcut {
            required property var modelData
            appid: "seashell"
            name: modelData.globalName
            description: "Seashell · " + modelData.name
            onPressed: root.handleGlobalAction(modelData.id)
        }
    }

    Connections {
        target: Config
        function onKeybindsChanged() { root.syncGeneratedFiles() }
        function onKeybindApprovalsChanged() { root.syncGeneratedFiles() }
    }
    Connections {
        target: Hyprland
        function onUsingLuaChanged() { root.syncGeneratedFiles() }
        function onRawEvent(event) {
            if (event.name === "configreloaded") root.refresh()
        }
    }

    Process {
        id: bindQuery
        stdout: StdioCollector { id: bindQueryOutput }
        onExited: code => {
            if (code !== 0) {
                Keybinds.backendStatus = "Could not inspect active Hyprland bindings."
                return
            }
            try {
                root.reconcile(JSON.parse(bindQueryOutput.text))
                Keybinds.backendStatus = "Global shortcuts registered; physical binds belong to Hyprland."
            } catch (error) {
                Keybinds.backendStatus = "Could not parse active Hyprland bindings: " + error
            }
        }
    }
    FileView {
        id: luaConfig
        path: root.hyprConfigDir + "/seashell.lua"
        blockLoading: true
        onSaved: if (root.luaMode)
            root.generatedStatus = "Saved " + root.generatedFilePath + "; add require(\"seashell\") to hyprland.lua."
        onSaveFailed: root.generatedStatus = "Could not write the generated Lua binding file."
    }
    FileView {
        id: langConfig
        path: root.hyprConfigDir + "/seashell.conf"
        blockLoading: true
        onSaved: if (!root.luaMode)
            root.generatedStatus = "Saved " + root.generatedFilePath + "; source it once from hyprland.conf."
        onSaveFailed: root.generatedStatus = "Could not write the generated Hyprlang binding file."
    }

    Component.onCompleted: {
        syncGeneratedFiles()
        refresh()
    }
}
