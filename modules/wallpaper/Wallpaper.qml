import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.core

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: wallpaperWindow

            required property var modelData

            screen: modelData

            visible:
                WallpaperState
                    .hasShellWallpaper
                && ModuleManager.activeProvider("wallpaper") === "wallpaper.seashell"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusionMode:
                ExclusionMode.Ignore

            focusable: false

            color: "transparent"
            surfaceFormat.opaque: false

            WlrLayershell.layer:
                WlrLayer.Background

            Image {
                anchors.fill: parent

                source:
                    WallpaperState
                        .activeSource

                fillMode:
                    Config.wallpaperFit
                    === "contain"
                        ? Image.PreserveAspectFit
                        : Config.wallpaperFit
                          === "stretch"
                            ? Image.Stretch
                            : Image.PreserveAspectCrop

                horizontalAlignment:
                    Image.AlignHCenter

                verticalAlignment:
                    Image.AlignVCenter

                smooth: true
                mipmap: true
                asynchronous: true
                cache: true
            }
        }
    }
}
