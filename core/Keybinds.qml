pragma Singleton

import QtQuick
import Quickshell

import qs.core

Singleton {
    property string backendStatus: "Checking Hyprland bindings…"

    readonly property var actions:
        LauncherActions.definitions.filter(item => (!!item.defaultBinding || item.keybindAction)
            && LauncherActions.isAvailable(item.id))

    function action(id) {
        return actions.find(item => item.id === id)
    }

    function binding(id) {
        const saved = Config.keybinds || {}
        const entry = action(id)
        return Object.prototype.hasOwnProperty.call(saved, id)
            ? (saved[id] || "") : (entry ? (entry.defaultBinding || "") : "")
    }

    function duplicate(id, candidate) {
        return actions.find(item => item.id !== id && binding(item.id) === candidate)
    }

    function setBinding(id, candidate) {
        if (!action(id) || !candidate || duplicate(id, candidate))
            return false
        Config.keybinds = Object.assign({}, Config.keybinds || {}, { [id]: candidate })
        return true
    }

    function setApprovedOverride(id, candidate, approved) {
        const next = Object.assign({}, Config.keybindApprovals || {})
        if (approved)
            next[id] = candidate
        else
            delete next[id]
        Config.keybindApprovals = next
    }

    function reset(id) {
        const entry = action(id)
        if (!entry || (entry.defaultBinding && duplicate(id, entry.defaultBinding)))
            return false
        const next = Object.assign({}, Config.keybinds || {})
        delete next[id]
        Config.keybinds = next
        setApprovedOverride(id, "", false)
        return true
    }

    function clear(id) {
        if (!action(id)) return false
        const next = Object.assign({}, Config.keybinds || {}, { [id]: "" })
        Config.keybinds = next
        setApprovedOverride(id, "", false)
        return true
    }

    function fromEvent(event) {
        let key = ""
        if (event.key === Qt.Key_Space)
            key = "SPACE"
        else if (event.key === Qt.Key_Comma)
            key = "COMMA"
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            key = "RETURN"
        else if (event.key === Qt.Key_Escape)
            key = "ESCAPE"
        else if (event.key === Qt.Key_Tab)
            key = "TAB"
        else if (event.key === Qt.Key_Print)
            key = "PRINT"
        else if (event.key === Qt.Key_Left)
            key = "LEFT"
        else if (event.key === Qt.Key_Right)
            key = "RIGHT"
        else if (event.key === Qt.Key_Up)
            key = "UP"
        else if (event.key === Qt.Key_Down)
            key = "DOWN"
        else if (event.key >= Qt.Key_A && event.key <= Qt.Key_Z)
            key = String.fromCharCode(event.key)
        else if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9)
            key = String.fromCharCode(event.key)
        else if (event.key >= Qt.Key_F1 && event.key <= Qt.Key_F12)
            key = "F" + (event.key - Qt.Key_F1 + 1)
        if (!key)
            return ""

        const modifiers = []
        if (event.modifiers & Qt.MetaModifier)
            modifiers.push("SUPER")
        if (event.modifiers & Qt.ControlModifier)
            modifiers.push("CTRL")
        if (event.modifiers & Qt.AltModifier)
            modifiers.push("ALT")
        if (event.modifiers & Qt.ShiftModifier)
            modifiers.push("SHIFT")
        if (!modifiers.length)
            return ""
        return modifiers.concat([key]).join("+")
    }

    function normalized(candidate) {
        const valid = ["SUPER", "CTRL", "ALT", "SHIFT"]
        const tokens = String(candidate || "").toUpperCase().split("+").filter(Boolean)
        if (tokens.length < 2)
            return ""
        const key = tokens.pop()
        const keyValid = /^[A-Z]$/.test(key) || /^[0-9]$/.test(key)
            || /^F([1-9]|1[0-2])$/.test(key)
            || ["SPACE", "COMMA", "RETURN", "ESCAPE", "TAB", "PRINT",
                "LEFT", "RIGHT", "UP", "DOWN"].indexOf(key) !== -1
        if (!keyValid || tokens.some(token => valid.indexOf(token) === -1))
            return ""
        const modifiers = [...new Set(tokens)].sort((a, b) => valid.indexOf(a) - valid.indexOf(b))
        if (!modifiers.length)
            return ""
        return modifiers.concat([key]).join("+")
    }

    function run(id) {
        LauncherActions.activateId(id)
    }
}
