pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property bool launcherOpen: false

    property bool settingsOpen: false

    function showSettings(section, page) {
        launcherOpen = false
        settingsSection = section || "appearance"
        settingsPage = page || "general"
        settingsOpen = true
    }

    function toggleSettings() {
        if (settingsOpen)
            settingsOpen = false
        else
            showSettings("appearance", "general")
    }

    property string settingsSection: "appearance"
    property string settingsPage: "general"

    function showLauncher() {
        settingsOpen = false
        launcherOpen = true
    }

    function hideLauncher() {
        launcherOpen = false
    }

    function toggleLauncher() {
        if (launcherOpen)
            hideLauncher()
        else
            showLauncher()
    }

}
