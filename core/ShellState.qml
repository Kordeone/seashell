pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property bool launcherOpen: false

    property bool settingsOpen: false

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
