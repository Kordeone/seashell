pragma Singleton

import QtQuick
import Quickshell

Singleton {
    PixelModern {
        id: pixelModernStyle
    }

    SoftGlass {
        id: softGlassStyle
    }

    readonly property QtObject pixelModern: pixelModernStyle
    readonly property QtObject softGlass: softGlassStyle

    readonly property var all: [
        pixelModernStyle,
        softGlassStyle
    ]

    function byId(id) {
        for (let i = 0; i < all.length; ++i) {
            if (all[i].key === id)
                return all[i]
        }

        return pixelModernStyle
    }
}
