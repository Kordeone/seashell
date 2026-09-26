pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property string backendStatus: "Checking Hyprland bindings…"
    readonly property var actions: [
        {
            id: "launcher.toggle",
            name: "Open Launcher",
            description: "Open or close unified search",
            defaultBinding: "SUPER+SPACE"
        },
        {
            id: "settings.toggle",
            name: "Open Settings",
            description: "Open or close Seashell Settings",
            defaultBinding: "SUPER+COMMA"
        }
    ]

    function action(id) {
        return actions.find(item => item.id === id)
    }

    function binding(id) {
        const saved = Config.keybinds || {}
        const entry = action(id)
        return saved[id] || (entry ? entry.defaultBinding : "")
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

    function reset(id) {
        const entry = action(id)
        if (!entry || duplicate(id, entry.defaultBinding))
            return false
        const next = Object.assign({}, Config.keybinds || {})
        delete next[id]
        Config.keybinds = next
        return true
    }

    function fromEvent(event) {
        let key = ""
        if (event.key === Qt.Key_Space)
            key = "SPACE"
        else if (event.key === Qt.Key_Comma)
            key = "COMMA"
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

    function run(id) {
        switch (id) {
        case "launcher.toggle":
            ShellState.toggleLauncher()
            break
        case "settings.toggle":
            ShellState.toggleSettings()
            break
        }
    }
}
