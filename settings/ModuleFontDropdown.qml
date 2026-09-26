import QtQuick
import QtQuick.Controls

import qs.core

Item {
    id: root

    required property string moduleKey

    signal moreFontsRequested(string moduleKey)
    signal requestMoreFonts(string moduleKey)
    signal browseMoreFonts(string moduleKey)
    signal openFontBrowser(string moduleKey)

    implicitHeight: 44
    height: implicitHeight

    readonly property string overrideFamily:
        Typography.moduleOverride(
            moduleKey
        )

    readonly property string effectiveFamily:
        Typography.moduleFontFamily(
            moduleKey,
            Theme.fontUI
        )

    readonly property var choices: {
        const result = [
            {
                type: "default",
                family: "",
                label:
                    "Use Default · "
                    + Theme.fontUI
            }
        ]

        const featured =
            Typography.featuredFamilies || []

        if (
            overrideFamily
            && featured.indexOf(
                overrideFamily
            ) < 0
        ) {
            result.push({
                type: "font",
                family:
                    overrideFamily,

                label:
                    overrideFamily
            })
        }

        for (
            let i = 0;
            i < featured.length;
            ++i
        ) {
            result.push({
                type: "font",
                family:
                    featured[i],

                label:
                    featured[i]
            })
        }

        result.push({
            type: "more",
            family: "",
            label: "More Fonts…"
        })

        return result
    }

    function requestBrowser() {
        moreFontsRequested(
            moduleKey
        )

        requestMoreFonts(
            moduleKey
        )

        browseMoreFonts(
            moduleKey
        )

        openFontBrowser(
            moduleKey
        )
    }

    Rectangle {
        id: trigger

        anchors.fill: parent

        radius: Theme.radiusSmall

        color:
            triggerMouse.containsMouse
                ? Theme.surfaceRaised
                : Theme.surface

        border {
            width:
                menu.opened
                    ? 2
                    : Theme.borderWidth

            color:
                menu.opened
                    ? Theme.accent
                    : Theme.border
        }

        Column {
            anchors {
                left: parent.left
                leftMargin: 12
                right: arrow.left
                rightMargin: 10
                verticalCenter:
                    parent.verticalCenter
            }

            spacing: 1

            Text {
                width: parent.width

                text:
                    root.overrideFamily
                        ? root.overrideFamily
                        : "Use Default"

                elide:
                    Text.ElideRight

                color:
                    Theme.foreground

                font {
                    family:
                        root.effectiveFamily

                    pixelSize: 9
                    bold: true
                }
            }

            Text {
                width: parent.width

                text:
                    root.overrideFamily
                        ? "Component override"
                        : "Inherits global typography"

                elide:
                    Text.ElideRight

                color:
                    Theme.foregroundMuted

                font {
                    family: Theme.fontUI
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
                menu.opened
                    ? "▲"
                    : "▼"

            color:
                Theme.foregroundMuted

            font {
                family: Theme.fontMono
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
                menu.opened
                    ? menu.close()
                    : menu.open()
        }
    }

    Popup {
        id: menu

        parent:
            Overlay.overlay

        width: root.width

        height:
            Math.min(
                300,
                root.choices.length
                * 42
                + 8
            )

        padding: 4
        modal: false
        focus: true

        closePolicy:
            Popup.CloseOnEscape
            | Popup.CloseOnPressOutside

        onAboutToShow: {
            const below =
                root.mapToItem(
                    menu.parent,
                    0,
                    root.height + 4
                )

            const above =
                root.mapToItem(
                    menu.parent,
                    0,
                    -menu.height - 4
                )

            menu.x =
                Math.max(
                    6,
                    Math.min(
                        below.x,
                        menu.parent.width
                        - menu.width
                        - 6
                    )
                )

            menu.y =
                below.y
                + menu.height
                <= menu.parent.height - 6
                    ? below.y
                    : Math.max(
                        6,
                        above.y
                      )
        }

        background: Rectangle {
            radius: Theme.radiusMedium

            color: Theme.surfaceRaised

            border {
                width: 1
                color: Theme.border
            }
        }

        contentItem: ListView {
            clip: true

            model:
                root.choices

            spacing: 2

            delegate: Rectangle {
                required property var modelData

                width:
                    ListView.view.width

                height: 40

                radius:
                    Theme.radiusSmall

                readonly property bool selected:
                    modelData.type === "default"
                        ? !root.overrideFamily
                        : (
                            modelData.type
                            === "font"
                            && modelData.family
                               === root.overrideFamily
                          )

                color:
                    selected
                        ? Theme.surface
                        : fontMouse.containsMouse
                            ? Theme.surface
                            : "transparent"

                Text {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 10
                        rightMargin: 10
                        verticalCenter:
                            parent.verticalCenter
                    }

                    text:
                        modelData.label

                    elide:
                        Text.ElideRight

                    color:
                        modelData.type === "more"
                            ? Theme.accent
                            : parent.selected
                                ? Theme.accent
                                : Theme.foreground

                    font {
                        family:
                            modelData.type === "font"
                                ? modelData.family
                                : Theme.fontUI

                        pixelSize: 8
                        bold:
                            parent.selected
                            || modelData.type
                               === "more"
                    }
                }

                MouseArea {
                    id: fontMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        if (
                            modelData.type
                            === "default"
                        ) {
                            Typography
                                .clearModuleOverride(
                                    root.moduleKey
                                )
                        } else if (
                            modelData.type
                            === "font"
                        ) {
                            Typography
                                .setModuleOverride(
                                    root.moduleKey,
                                    modelData.family
                                )
                        } else {
                            root.requestBrowser()
                        }

                        menu.close()
                    }
                }
            }
        }
    }
}
