import QtQuick
import Quickshell

import qs.core
import qs.palettes

Item {
    id: root

    property alias opened:
        popup.visible

    implicitHeight: 58
    height: implicitHeight

    readonly property var activePalette:
        Palettes.byId(
            Config.paletteId
        )

    function description(key) {
        switch (key) {
        case "gel":
            return "Warm Persian earth and tile tones"

        case "the-dome":
            return "Deep cobalt and turquoise"

        case "andarouni":
            return "Courtyard blues, earth and turquoise"

        case "shaal":
            return "Textile red, turquoise and blue"

        case "mamluk":
            return "Smoky glass, cobalt and gilded accents"

        case "iznik":
            return "Ottoman cobalt, turquoise and bole red"

        case "tokyo-night":
            return "Cool nocturnal blue"

        case "gruvbox-dark":
            return "Warm retro dark"

        case "rose-pine":
            return "Muted rose and violet"

        default:
            return ""
        }
    }

    Rectangle {
        id: trigger

        anchors.fill: parent

        radius:
            Theme.radiusMedium

        color:
            triggerMouse.containsMouse
                ? Theme.surfaceRaised
                : Theme.surface

        border {
            width:
                root.opened
                    ? 2
                    : Theme.borderWidth

            color:
                root.opened
                    ? Theme.accent
                    : Theme.border
        }

        Row {
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter:
                    parent.verticalCenter
            }

            spacing: 5

            Repeater {
                model: [
                    root.activePalette.background,
                    root.activePalette.surfaceRaised,
                    root.activePalette.accent,
                    root.activePalette.focus,
                    root.activePalette.danger
                ]

                delegate: Rectangle {
                    required property var modelData

                    width: 12
                    height: 28
                    radius: 2

                    color: modelData
                }
            }
        }

        Column {
            anchors {
                left: parent.left
                leftMargin: 88
                right: arrow.left
                rightMargin: 10
                verticalCenter:
                    parent.verticalCenter
            }

            spacing: 2

            Text {
                width: parent.width

                text:
                    root.activePalette.name

                color:
                    Theme.foreground

                elide:
                    Text.ElideRight

                font {
                    family:
                        Theme.fontUI

                    pixelSize: 9
                    bold: true
                }
            }

            Text {
                width: parent.width

                text:
                    root.description(
                        root.activePalette.key
                    )

                color:
                    Theme.foregroundMuted

                elide:
                    Text.ElideRight

                font {
                    family:
                        Theme.fontUI

                    pixelSize: 7
                }
            }
        }

        Text {
            id: arrow

            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter:
                    parent.verticalCenter
            }

            text:
                root.opened
                    ? "▲"
                    : "▼"

            color:
                Theme.foregroundMuted

            font {
                family:
                    Theme.fontMono

                pixelSize: 7
            }
        }

        MouseArea {
            id: triggerMouse

            anchors.fill: parent

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                popup.visible =
                    !popup.visible
        }
    }

    PopupWindow {
        id: popup

        visible: false

        grabFocus: true

        implicitWidth:
            root.width

        implicitHeight:
            Math.min(
                320,
                Palettes.all.length
                * 50
                + 8
            )

        color: "transparent"
        surfaceFormat.opaque: false

        anchor {
            item: trigger

            edges:
                Edges.Bottom
                | Edges.Left

            gravity:
                Edges.Bottom
                | Edges.Right

            adjustment:
                PopupAdjustment.All
        }

        Rectangle {
            anchors.fill: parent

            radius:
                Theme.radiusMedium

            color:
                Theme.surfaceRaised

            border {
                width: 1
                color: Theme.border
            }

            ListView {
                anchors {
                    fill: parent
                    margins: 4
                }

                clip: true

                model:
                    Palettes.all

                spacing: 2

                delegate: Rectangle {
                    required property var modelData

                    width:
                        ListView.view.width

                    height: 46

                    radius:
                        Theme.radiusSmall

                    readonly property bool active:
                        modelData.key
                        === Config.paletteId

                    color:
                        active
                            ? Theme.surface
                            : itemMouse.containsMouse
                                ? Theme.surface
                                : "transparent"

                    Row {
                        anchors {
                            left: parent.left
                            leftMargin: 8
                            verticalCenter:
                                parent.verticalCenter
                        }

                        spacing: 3

                        Repeater {
                            model: [
                                modelData.background,
                                modelData.surfaceRaised,
                                modelData.accent,
                                modelData.focus
                            ]

                            delegate: Rectangle {
                                required property var modelData

                                width: 8
                                height: 25
                                radius: 2

                                color:
                                    modelData
                            }
                        }
                    }

                    Column {
                        anchors {
                            left: parent.left
                            leftMargin: 52
                            right: parent.right
                            rightMargin: 34
                            verticalCenter:
                                parent.verticalCenter
                        }

                        spacing: 1

                        Text {
                            width: parent.width

                            text:
                                modelData.name

                            color:
                                parent.parent.active
                                    ? Theme.accent
                                    : Theme.foreground

                            font {
                                family:
                                    Theme.fontUI

                                pixelSize: 8
                                bold: true
                            }
                        }

                        Text {
                            width: parent.width

                            text:
                                root.description(
                                    modelData.key
                                )

                            color:
                                Theme.foregroundMuted

                            elide:
                                Text.ElideRight

                            font {
                                family:
                                    Theme.fontUI

                                pixelSize: 7
                            }
                        }
                    }

                    Text {
                        visible:
                            parent.active

                        anchors {
                            right: parent.right
                            rightMargin: 9
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text: "✓"

                        color:
                            Theme.accent

                        font {
                            family:
                                Theme.fontUI

                            pixelSize: 11
                            bold: true
                        }
                    }

                    MouseArea {
                        id: itemMouse

                        anchors.fill:
                            parent

                        hoverEnabled: true

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            Config.paletteId =
                                modelData.key

                            popup.visible =
                                false
                        }
                    }
                }
            }
        }
    }
}
