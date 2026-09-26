import QtQuick
import QtQuick.Effects
import Quickshell

import qs.core

PanelWindow {
    id: bar

    visible: ModuleManager.isActive("bar", "seashell")

    anchors {
        top: true
        left: true
        right: true
    }

    color: "transparent"
    surfaceFormat.opaque: false

    implicitHeight:
        Theme.barHeight
        + (Theme.barMarginVertical * 2)

    exclusiveZone: implicitHeight

    readonly property string effectiveFontFamily:
        Typography.moduleFontFamily(
            "bar.clock",
            Theme.fontUI
        )

    function clockNeedsSeconds(format) {
        return format.indexOf("s") !== -1
    }

    SystemClock {
        id: systemClock

        precision:
            bar.clockNeedsSeconds(Config.clockFormat)
                ? SystemClock.Seconds
                : SystemClock.Minutes
    }

    // --------------------------------------------------------
    // Full-width rail
    // --------------------------------------------------------

    Rectangle {
        anchors.fill: parent

        visible:
            ShellState.settingsOpen
            && Theme.barBackdropOpacity > 0

        color: Qt.rgba(
            Theme.background.r,
            Theme.background.g,
            Theme.background.b,
            Theme.barBackdropOpacity
        )

        antialiasing: false
    }

    // --------------------------------------------------------
    // Main surface
    // --------------------------------------------------------

    Rectangle {
        id: surface

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom

            leftMargin: Theme.barMarginHorizontal
            rightMargin: Theme.barMarginHorizontal
            topMargin: Theme.barMarginVertical
            bottomMargin: Theme.barMarginVertical
        }

        color: Qt.rgba(
            Theme.background.r,
            Theme.background.g,
            Theme.background.b,
            Theme.panelOpacity
        )

        radius: Theme.barRadius

        border {
            width: Theme.barFrameWidth
            color: Theme.border
        }

        // Stable Pixel Modern bottom separator.
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            visible:
                Theme.barBottomBorderWidth > 0

            height:
                Theme.barBottomBorderWidth

            color:
                Theme.border

            antialiasing: false
        }

        // ----------------------------------------------------
        // LEFT — Seashell icon
        // ----------------------------------------------------

        Item {
            id: shellIcon

            anchors {
                left: parent.left
                leftMargin: Theme.spacingLarge
                verticalCenter: parent.verticalCenter
            }

            width: 20
            height: 20

            Image {
                id: shellIconSource

                anchors.fill: parent

                source:
                    Qt.resolvedUrl(
                        "../../assets/icons/sea.svg"
                    )

                sourceSize.width: 24
                sourceSize.height: 24

                smooth: true
                visible: false
            }

            MultiEffect {
                anchors.fill: parent

                source: shellIconSource

                colorization: 1.0
                colorizationColor: Theme.accent
            }
        }

        // ----------------------------------------------------
        // CENTER — Clock
        // This is geometrically anchored to the bar itself,
        // not positioned between left/right content.
        // ----------------------------------------------------

        Text {
            anchors.centerIn: parent

            text:
                Qt.formatDateTime(
                    systemClock.date,
                    Config.clockFormat
                )

            color: Theme.foreground

            font {
                family: bar.effectiveFontFamily
                pixelSize: Theme.fontMedium
                bold: true
                letterSpacing: 1
            }
        }

        // ----------------------------------------------------
        // RIGHT — Palette + Settings hammer
        // ----------------------------------------------------

        Row {
            anchors {
                right: parent.right
                rightMargin: Theme.spacingLarge
                verticalCenter: parent.verticalCenter
            }

            spacing: Theme.spacingMedium

            Rectangle {
                id: settingsButton

                width: 30
                height: 26

                radius: Theme.radiusSmall

                color: Theme.surface

                border {
                    width: Theme.borderWidth
                    color: Theme.border
                }

                Item {
                    anchors.centerIn: parent

                    width: 17
                    height: 17

                    Image {
                        id: hammerIconSource

                        anchors.fill: parent

                        source:
                            Qt.resolvedUrl(
                                "../../assets/icons/hammer.svg"
                            )

                        sourceSize.width: 24
                        sourceSize.height: 24

                        smooth: true
                        visible: false
                    }

                    MultiEffect {
                        anchors.fill: parent

                        source: hammerIconSource

                        colorization: 1.0
                        colorizationColor:
                            Theme.foreground
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        ShellState.settingsOpen =
                            !ShellState.settingsOpen
                    }
                }
            }
        }
    }
}
