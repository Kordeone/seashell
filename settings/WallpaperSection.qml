import QtQuick

import qs.core

Item {
    id: root

    property string title: ""
    property string subtitle: ""

    property var wallpapers: []
    property var selectedPaths: []

    property bool expanded: true
    property bool selectable: false
    property bool disabled: false

    signal toggleRequested(string path)

    function pathSelected(path) {
        return (
            selectedPaths || []
        ).indexOf(path) >= 0
    }

    readonly property int columns:
        Math.max(
            1,
            Math.floor(
                width / 160
            )
        )

    readonly property int rows:
        wallpapers.length === 0
            ? 0
            : Math.ceil(
                wallpapers.length
                / columns
            )

    readonly property int bodyHeight:
        wallpapers.length === 0
            ? 42
            : rows * 118

    height:
        43
        + (
            expanded
                ? bodyHeight + 8
                : 0
        )

    Rectangle {
        id: header

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: 43

        radius: Theme.radiusSmall
        color: Theme.surface

        opacity:
            root.disabled
                ? 0.5
                : 1.0

        border {
            width: Theme.borderWidth
            color: Theme.border
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter:
                    parent.verticalCenter
            }

            text:
                root.expanded
                    ? "▼"
                    : "▶"

            color:
                Theme.foregroundMuted

            font {
                family: Theme.fontMono
                pixelSize: 8
            }
        }

        Column {
            anchors {
                left: parent.left
                leftMargin: 31
                verticalCenter:
                    parent.verticalCenter
            }

            spacing: 1

            Text {
                text: root.title

                color:
                    root.disabled
                        ? Theme.foregroundDisabled
                        : Theme.foreground

                font {
                    family: Theme.fontUI
                    pixelSize: 9
                    bold: true
                }
            }

            Text {
                visible:
                    root.subtitle.length > 0

                text: root.subtitle

                color:
                    Theme.foregroundMuted

                font {
                    family: Theme.fontUI
                    pixelSize: 7
                }
            }
        }

        Text {
            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter:
                    parent.verticalCenter
            }

            text:
                root.disabled
                    ? "DISABLED"
                    : root.wallpapers.length
                      + (
                            root.wallpapers.length === 1
                                ? " IMAGE"
                                : " IMAGES"
                        )

            color:
                root.disabled
                    ? Theme.foregroundDisabled
                    : Theme.foregroundMuted

            font {
                family: Theme.fontMono
                pixelSize: 7
                bold: true
            }
        }

        MouseArea {
            anchors.fill: parent

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                root.expanded =
                    !root.expanded
        }
    }

    Item {
        visible:
            root.expanded

        anchors {
            left: parent.left
            right: parent.right
            top: header.bottom
            topMargin: 8
        }

        height:
            root.bodyHeight

        Text {
            visible:
                root.wallpapers.length === 0

            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 10
                topMargin: 10
            }

            text:
                root.disabled
                    ? "This feature is not enabled yet."
                    : "No images found."

            color:
                Theme.foregroundDisabled

            font {
                family: Theme.fontUI
                pixelSize: 8
            }
        }

        Grid {
            visible:
                root.wallpapers.length > 0

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            columns:
                root.columns

            columnSpacing: 10
            rowSpacing: 8

            Repeater {
                model:
                    root.wallpapers

                delegate: WallpaperCard {
                    required property var modelData

                    width:
                        (
                            root.width
                            - (
                                root.columns - 1
                              )
                              * 10
                        )
                        / root.columns

                    wallpaperData:
                        modelData

                    selected:
                        root.pathSelected(
                            modelData.path
                        )

                    active:
                        WallpaperState.activePath
                        === modelData.path

                    selectable:
                        root.selectable

                    disabled:
                        root.disabled

                    onToggled:
                        path =>
                            root.toggleRequested(
                                path
                            )
                }
            }
        }
    }
}
