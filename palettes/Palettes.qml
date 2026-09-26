pragma Singleton

import QtQuick
import Quickshell

Singleton {
    Gel {
        id: gelPalette
    }

    TheDome {
        id: theDomePalette
    }

    Andarouni {
        id: andarouniPalette
    }

    Shaal {
        id: shaalPalette
    }

    Mamluk {
        id: mamlukPalette
    }

    Iznik {
        id: iznikPalette
    }

    TokyoNight {
        id: tokyoNightPalette
    }

    GruvboxDark {
        id: gruvboxDarkPalette
    }

    RosePine {
        id: rosePinePalette
    }

    readonly property var all: [
        gelPalette,
        theDomePalette,
        andarouniPalette,
        shaalPalette,
        mamlukPalette,
        iznikPalette,
        tokyoNightPalette,
        gruvboxDarkPalette,
        rosePinePalette
    ]

    function byId(key) {
        for (
            let i = 0;
            i < all.length;
            ++i
        ) {
            if (all[i].key === key)
                return all[i]
        }

        return andarouniPalette
    }
}
