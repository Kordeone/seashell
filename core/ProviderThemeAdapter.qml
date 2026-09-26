pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.core

Singleton {
    id: root
    readonly property string fuzzelPath: Quickshell.statePath("provider-fuzzel.ini")
    readonly property string rofiPath: Quickshell.statePath("provider-rofi.rasi")
    readonly property string wofiPath: Quickshell.statePath("provider-wofi.css")

    function hex(color, includeAlpha) {
        function byte(value) { return Math.round(value * 255).toString(16).padStart(2, "0") }
        return "#" + byte(color.r) + byte(color.g) + byte(color.b)
            + (includeAlpha ? byte(color.a) : "")
    }

    function safeFont() {
        return String(Theme.fontUI || "sans-serif").replace(/["\\;]/g, "")
    }

    function fuzzelConfig() {
        return "[main]\nfont=" + safeFont() + ":size=12\nwidth=48\nlines=12\nborder-width="
            + Theme.borderWidth + "\nborder-radius=" + Theme.radiusMedium + "\n"
            + "[colors]\nbackground=" + hex(Theme.background, true) + "\ntext="
            + hex(Theme.foreground, true) + "\nmatch=" + hex(Theme.accent, true)
            + "\nselection=" + hex(Theme.surfaceRaised, true) + "\nselection-text="
            + hex(Theme.foreground, true) + "\nborder=" + hex(Theme.border, true)
            + "\nplaceholder=" + hex(Theme.foregroundMuted, true) + "\n"
    }

    function rofiTheme() {
        return "* {\n  background: " + hex(Theme.background, false) + ";\n  foreground: "
            + hex(Theme.foreground, false) + ";\n  surface: " + hex(Theme.surface, false)
            + ";\n  selected: " + hex(Theme.accent, false) + ";\n  muted: "
            + hex(Theme.foregroundMuted, false) + ";\n  border: " + hex(Theme.border, false)
            + ";\n  radius: " + Theme.radiusMedium + "px;\n  font: \"" + safeFont() + " 12\";\n}\n"
            + "window { background-color: @background; border: 1px; border-color: @border; border-radius: @radius; padding: 12px; }\n"
            + "mainbox { background-color: transparent; children: [ inputbar, listview ]; spacing: 8px; }\n"
            + "inputbar { background-color: @surface; text-color: @foreground; border-radius: 8px; padding: 8px; }\n"
            + "listview { background-color: transparent; lines: 10; }\n"
            + "element { background-color: transparent; text-color: @foreground; padding: 7px; border-radius: 6px; }\n"
            + "element selected { background-color: @selected; text-color: @background; }\n"
    }

    function wofiCss() {
        return "window { background: " + hex(Theme.background, false) + "; color: "
            + hex(Theme.foreground, false) + "; border: " + Theme.borderWidth + "px solid "
            + hex(Theme.border, false) + "; border-radius: " + Theme.radiusMedium + "px; font-family: \""
            + safeFont() + "\"; }\n#input { background: " + hex(Theme.surface, false)
            + "; color: " + hex(Theme.foreground, false) + "; border: 1px solid "
            + hex(Theme.border, false) + "; border-radius: " + Theme.radiusSmall + "px; padding: 8px; }\n"
            + "#entry:selected { background: " + hex(Theme.accent, false) + "; color: "
            + hex(Theme.accentForeground, false) + "; }\n#text { color: "
            + hex(Theme.foregroundMuted, false) + "; }\n"
    }

    function pathFor(providerId) {
        if (providerId === "launcher.fuzzel") return fuzzelPath
        if (providerId === "launcher.rofi") return rofiPath
        if (providerId === "launcher.wofi") return wofiPath
        return ""
    }

    function regenerate() {
        fuzzelFile.setText(fuzzelConfig())
        rofiFile.setText(rofiTheme())
        wofiFile.setText(wofiCss())
    }

    FileView { id: fuzzelFile; path: root.fuzzelPath }
    FileView { id: rofiFile; path: root.rofiPath }
    FileView { id: wofiFile; path: root.wofiPath }

    Connections {
        target: Config
        function onPaletteIdChanged() { root.regenerate() }
        function onStyleIdChanged() { root.regenerate() }
        function onFontFamilyChanged() { root.regenerate() }
    }
    Component.onCompleted: Qt.callLater(regenerate)
}
