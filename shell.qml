import QtQuick
import Quickshell

import qs.core
import qs.modules.bar
import qs.settings
import qs.modules.wallpaper
import qs.modules.launcher

ShellRoot {
    Wallpaper {}
    Bar {}
    Loader {
        active: Quickshell.env("SEASHELL_VALIDATE") !== "1"
        sourceComponent: WaybarAdapter {}
    }
    Loader {
        active: Quickshell.env("SEASHELL_VALIDATE") !== "1"
        sourceComponent: HyprlandShortcuts {}
    }
    SettingsWindow {}

    Launcher {
    }

}
