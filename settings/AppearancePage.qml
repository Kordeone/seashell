import QtQuick

import qs.core
import qs.styles

Item {
    id: root

    property string tab: "component-style"

    signal moreFontsRequested(string target)

    property string typographyView: "general"

    readonly property var styleDefault:
        Styles.byId(Config.styleId)

    readonly property string featuredFontOne:
        Typography.featuredFamilies.length > 0
            ? Typography.featuredFamilies[0]
            : styleDefault.fontUI

    readonly property string featuredFontTwo:
        Typography.featuredFamilies.length > 1
            ? Typography.featuredFamilies[1]
            : (
                Typography.featuredFamilies.length > 0
                    ? Typography.featuredFamilies[0]
                    : styleDefault.fontUI
            )

    // ========================================================
    // COMPONENT STYLE
    // ========================================================

    Item {
        anchors.fill: parent

        visible:
            root.tab === "component-style"

        Text {
            id: styleTitle

            anchors {
                left: parent.left
                top: parent.top
            }

            text: "COMPONENT STYLE"

            color: Theme.foreground

            font {
                family: Theme.fontUI
                pixelSize: 15
                bold: true
            }
        }

        Text {
            anchors {
                left: parent.left
                right: parent.right
                top: styleTitle.bottom
                topMargin: 5
            }

            text:
                "Choose the base component language used throughout Seashell."

            color: Theme.foregroundMuted

            font {
                family: Theme.fontUI
                pixelSize: 9
            }
        }

        Row {
            id: styles

            anchors {
                left: parent.left
                right: parent.right
                top: styleTitle.bottom
                topMargin: 34
            }

            spacing: 10

            StylePreviewOption {
                width:
                    (parent.width - parent.spacing)
                    / 2

                styleData: Styles.all[0]
            }

            StylePreviewOption {
                width:
                    (parent.width - parent.spacing)
                    / 2

                styleData: Styles.all[1]
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: styles.bottom
                topMargin: 12
            }

            height: 54

            radius: Theme.radiusMedium

            color: Theme.surface
            opacity: 0.5

            border {
                width: Theme.borderWidth
                color: Theme.border
            }

            Column {
                anchors {
                    left: parent.left
                    leftMargin: 14
                    verticalCenter: parent.verticalCenter
                }

                spacing: 3

                Text {
                    text: "CUSTOM"

                    color: Theme.foregroundMuted

                    font {
                        family: Theme.fontMono
                        pixelSize: 9
                        bold: true
                        letterSpacing: 1
                    }
                }

                Text {
                    text:
                        "Define component geometry, opacity, borders, spacing and motion yourself."

                    color:
                        Theme.foregroundDisabled

                    font {
                        family: Theme.fontUI
                        pixelSize: 8
                    }
                }
            }

            Text {
                anchors {
                    right: parent.right
                    rightMargin: 14
                    verticalCenter: parent.verticalCenter
                }

                text: "SOON"

                color:
                    Theme.foregroundDisabled

                font {
                    family: Theme.fontMono
                    pixelSize: 7
                    bold: true
                    letterSpacing: 1
                }
            }
        }
    }

    // ========================================================
    // PALETTE
    // ========================================================

    Item {
        anchors.fill: parent

        z: 50

        visible:
            root.tab === "palette"

        Text {
            id: paletteTitle

            anchors {
                left: parent.left
                top: parent.top
            }

            text: "COLOR PALETTE"

            color: Theme.foreground

            font {
                family: Theme.fontUI
                pixelSize: 15
                bold: true
            }
        }

        Text {
            anchors {
                left: parent.left
                right: parent.right
                top: paletteTitle.bottom
                topMargin: 5
            }

            text:
                "Choose a coordinated Seashell palette or use automatic color randomization."

            color: Theme.foregroundMuted

            font {
                family: Theme.fontUI
                pixelSize: 9
            }
        }

        Row {
            anchors {
                left: parent.left
                right: parent.right
                top: paletteTitle.bottom
                topMargin: 34
            }

            spacing: 10

            PaletteDropdown {
                width:
                    parent.width - 128

                z: 500
            }

            Rectangle {
                width: 118
                height: 58

                radius: Theme.radiusMedium

                color: Theme.surface
                opacity: 0.42

                border {
                    width: Theme.borderWidth
                    color: Theme.border
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 3

                    Text {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text: "RANDOM"

                        color: Theme.foreground

                        font {
                            family: Theme.fontMono
                            pixelSize: 9
                            bold: true
                            letterSpacing: 1
                        }
                    }

                    Text {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text: "SOON"

                        color:
                            Theme.foregroundMuted

                        font {
                            family: Theme.fontMono
                            pixelSize: 7
                            letterSpacing: 1
                        }
                    }
                }
            }
        }

        Row {
            anchors {
                right: parent.right
                top: paletteTitle.bottom
                topMargin: 103
            }

            spacing: 8
            opacity: 0.38

            Text {
                anchors.verticalCenter:
                    parent.verticalCenter

                text: "Random interval"

                color: Theme.foregroundMuted

                font {
                    family: Theme.fontUI
                    pixelSize: 8
                }
            }

            Rectangle {
                width: 74
                height: 25

                radius: Theme.radiusSmall
                color: Theme.surface

                border {
                    width: Theme.borderWidth
                    color: Theme.border
                }

                Text {
                    anchors.centerIn: parent

                    text: "30 min"

                    color:
                        Theme.foregroundMuted

                    font {
                        family: Theme.fontMono
                        pixelSize: 8
                    }
                }
            }
        }
    }

    // ========================================================
    // TYPOGRAPHY
    // ========================================================

    Item {
        anchors.fill: parent

        visible:
            root.tab === "typography"

        Text {
            id: typographyTitle

            anchors {
                left: parent.left
                top: parent.top
            }

            text: "TYPOGRAPHY"

            color: Theme.foreground

            font {
                family: Theme.fontUI
                pixelSize: 15
                bold: true
            }
        }

        Text {
            anchors {
                left: parent.left
                right: parent.right
                top: typographyTitle.bottom
                topMargin: 5
            }

            text:
                "This is the default font for Seashell. Modules inherit it unless they define their own override."

            wrapMode:
                Text.WordWrap

            color: Theme.foregroundMuted

            font {
                family: Theme.fontUI
                pixelSize: 9
            }
        }

        Text {
            anchors {
                left: parent.left
                top: typographyTitle.bottom
                topMargin: 42
            }

            text: "DEFAULT"

            color: Theme.foregroundMuted

            font {
                family: Theme.fontMono
                pixelSize: 8
                bold: true
                letterSpacing: 1
            }
        }

        Row {
            id: fontCards

            anchors {
                left: parent.left
                right: parent.right
                top: typographyTitle.bottom
                topMargin: 62
            }

            spacing: 10

            FontOption {
                width:
                    (parent.width - 20)
                    / 3

                labelText:
                    "Style Default"

                familyValue:
                    root.styleDefault.fontUI

                styleDefault: true
            }

            FontOption {
                width:
                    (parent.width - 20)
                    / 3

                labelText:
                    root.featuredFontOne

                familyValue:
                    root.featuredFontOne
            }

            FontOption {
                width:
                    (parent.width - 20)
                    / 3

                labelText:
                    root.featuredFontTwo

                familyValue:
                    root.featuredFontTwo
            }
        }

        Rectangle {
            id: moreFontsButton

            anchors {
                left: parent.left
                top: fontCards.bottom
                topMargin: 9
            }

            width: 116
            height: 28

            radius: Theme.radiusSmall

            color:
                moreFontsMouse.containsMouse
                    ? Theme.surfaceRaised
                    : Theme.surface

            border {
                width: Theme.borderWidth
                color: Theme.border
            }

            Text {
                anchors.centerIn: parent

                text: "MORE FONTS…"

                color:
                    Theme.foregroundMuted

                font {
                    family: Theme.fontMono
                    pixelSize: 8
                    bold: true
                    letterSpacing: 0.7
                }
            }

            MouseArea {
                id: moreFontsMouse

                anchors.fill: parent
                hoverEnabled: true

                cursorShape:
                    Qt.PointingHandCursor

                onClicked:
                    root.moreFontsRequested(
                        "general"
                    )
            }
        }

        Text {
            anchors {
                left: parent.left
                top: moreFontsButton.bottom
                topMargin: 28
            }

            text: "MODULE OVERRIDES"

            color: Theme.foregroundMuted

            font {
                family: Theme.fontMono
                pixelSize: 8
                bold: true
                letterSpacing: 1
            }
        }

        Text {
            id: barModuleLabel

            anchors {
                left: parent.left
                top: moreFontsButton.bottom
                topMargin: 51
            }

            text: "Bar · Clock"

            color: Theme.foreground

            font {
                family: Theme.fontUI
                pixelSize: 9
                bold: true
            }
        }

        ModuleFontDropdown {
            anchors {
                left: parent.left
                right: parent.right
                top: barModuleLabel.bottom
                topMargin: 7
            }

            moduleKey: "bar.clock"

            onMoreFontsRequested: key =>
                root.moreFontsRequested(key)
        }
    }

}