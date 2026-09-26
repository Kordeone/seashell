import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland

import qs.core

Scope {
    id: root

    // --------------------------------------------------------
    // IPC
    //
    // qs -c seashell ipc call launcher toggle
    // --------------------------------------------------------

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            ShellState.toggleLauncher()
        }

        function show(): void {
            ShellState.showLauncher()
        }

        function hide(): void {
            ShellState.hideLauncher()
        }
    }

    Variants {
        model:
            Quickshell.screens

        PanelWindow {
            id: window

            required property var modelData

            screen:
                modelData

            readonly property bool focusedScreen: {
                const monitor =
                    Hyprland.monitorFor(
                        modelData
                    )

                return (
                    !Hyprland.focusedMonitor
                    || monitor
                       === Hyprland.focusedMonitor
                )
            }

            visible:
                ShellState.launcherOpen
                && focusedScreen

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusionMode:
                ExclusionMode.Ignore

            exclusiveZone: 0

            focusable: true

            color: "transparent"
            surfaceFormat.opaque: false

            WlrLayershell.layer:
                WlrLayer.Overlay

            property int selectedIndex: 0

            function moveSelection(delta) {
                const count =
                    resultModel.values.length

                if (count === 0) {
                    selectedIndex = 0
                    return
                }

                selectedIndex =
                    (
                        selectedIndex
                        + delta
                        + count
                    )
                    % count

                results.positionViewAtIndex(
                    selectedIndex,
                    ListView.Contain
                )
            }

            function launchSelected() {
                const items =
                    resultModel.values

                if (
                    items.length === 0
                ) {
                    return
                }

                const index =
                    Math.min(
                        selectedIndex,
                        items.length - 1
                    )

                const item = items[index]

                ShellState.hideLauncher()

                LauncherModel.activate(item)
            }

            onVisibleChanged: {
                if (!visible)
                    return

                selectedIndex = 0
                search.text = ""

                Qt.callLater(
                    function() {
                        search.forceActiveFocus()
                    }
                )
            }

            // ------------------------------------------------
            // DIMMED DESKTOP
            // ------------------------------------------------

            Rectangle {
                anchors.fill: parent

                color:
                    Qt.rgba(
                        Theme.background.r,
                        Theme.background.g,
                        Theme.background.b,
                        0.68
                    )

                MouseArea {
                    anchors.fill: parent

                    onClicked:
                        ShellState.hideLauncher()
                }
            }

            // ------------------------------------------------
            // LAUNCHER CARD
            // ------------------------------------------------

            Rectangle {
                id: card

                anchors {
                    horizontalCenter:
                        parent.horizontalCenter

                    top:
                        parent.top

                    topMargin:
                        Math.max(
                            72,
                            parent.height * 0.12
                        )
                }

                width:
                    Math.min(
                        720,
                        parent.width - 80
                    )

                height:
                    Math.min(
                        610,
                        parent.height - 130
                    )

                radius:
                    Theme.radiusLarge

                color:
                    Theme.surface

                border {
                    width:
                        Theme.borderWidth

                    color:
                        Theme.border
                }

                MouseArea {
                    anchors.fill: parent

                    // Prevent backdrop click-through.
                    onClicked: {
                    }
                }

                // --------------------------------------------
                // HEADER
                // --------------------------------------------

                Text {
                    id: title

                    anchors {
                        left: parent.left
                        top: parent.top

                        leftMargin: 18
                        topMargin: 16
                    }

                    text: "LAUNCHER"

                    color:
                        Theme.foregroundMuted

                    font {
                        family:
                            Theme.fontMono

                        pixelSize: 8
                        bold: true
                        letterSpacing: 1
                    }
                }

                // --------------------------------------------
                // SEARCH
                // --------------------------------------------

                Rectangle {
                    id: searchBox

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: title.bottom

                        leftMargin: 16
                        rightMargin: 16
                        topMargin: 10
                    }

                    height: 48

                    radius:
                        Theme.radiusMedium

                    color:
                        Theme.background

                    border {
                        width:
                            search.activeFocus
                                ? 2
                                : Theme.borderWidth

                        color:
                            search.activeFocus
                                ? Theme.accent
                                : Theme.border
                    }

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 14
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text: "›"

                        color:
                            Theme.accent

                        font {
                            family:
                                Theme.fontMono

                            pixelSize: 16
                            bold: true
                        }
                    }

                    TextInput {
                        id: search

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom

                            leftMargin: 36
                            rightMargin: 12
                        }

                        verticalAlignment:
                            TextInput.AlignVCenter

                        color:
                            Theme.foreground

                        selectionColor:
                            Theme.accent

                        selectedTextColor:
                            Theme.accentForeground

                        clip: true

                        focus: true

                        font {
                            family:
                                Theme.fontUI

                            pixelSize: 13
                        }

                        onTextChanged:
                            window.selectedIndex = 0

                        Keys.onPressed:
                            function(event) {
                                if (
                                    event.key
                                    === Qt.Key_Down
                                ) {
                                    window.moveSelection(1)
                                    event.accepted = true

                                } else if (
                                    event.key
                                    === Qt.Key_Up
                                ) {
                                    window.moveSelection(-1)
                                    event.accepted = true

                                } else if (
                                    event.key
                                    === Qt.Key_Return
                                    || event.key
                                       === Qt.Key_Enter
                                ) {
                                    window.launchSelected()
                                    event.accepted = true

                                } else if (
                                    event.key
                                    === Qt.Key_Escape
                                ) {
                                    ShellState.hideLauncher()
                                    event.accepted = true
                                }
                            }
                    }

                    Text {
                        visible:
                            search.text.length === 0

                        anchors {
                            left: search.left
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text:
                            "Search apps and actions…"

                        color:
                            Theme.foregroundDisabled

                        font {
                            family:
                                Theme.fontUI

                            pixelSize: 13
                        }
                    }
                }

                // --------------------------------------------
                // MODEL
                // --------------------------------------------

                ScriptModel {
                    id: resultModel

                    objectProp: "id"

                    values:
                        LauncherModel.search(search.text)
                }

                // --------------------------------------------
                // RESULTS
                // --------------------------------------------

                ListView {
                    id: results

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: searchBox.bottom
                        bottom: footer.top

                        leftMargin: 12
                        rightMargin: 12
                        topMargin: 10
                        bottomMargin: 8
                    }

                    clip: true

                    spacing: 3

                    model:
                        resultModel

                    currentIndex:
                        window.selectedIndex

                    boundsBehavior:
                        Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        policy:
                            ScrollBar.AsNeeded
                    }

                    delegate: Rectangle {
                        required property int index
                        required property var modelData

                        width:
                            ListView.view.width

                        height: 54

                        radius:
                            Theme.radiusSmall

                        readonly property bool selected:
                            index
                            === window.selectedIndex

                        color:
                            selected
                                ? Theme.surfaceRaised
                                : itemMouse.containsMouse
                                    ? Qt.rgba(
                                        Theme.foreground.r,
                                        Theme.foreground.g,
                                        Theme.foreground.b,
                                        0.04
                                      )
                                    : "transparent"

                        border {
                            width:
                                selected
                                    ? 1
                                    : 0

                            color:
                                selected
                                    ? Theme.accent
                                    : "transparent"
                        }

                        IconImage {
                            id: appIcon

                            anchors {
                                left: parent.left
                                leftMargin: 10
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            width: 34
                            height: 34

                            source:
                                Quickshell.iconPath(
                                    modelData.icon,
                                    "application-x-executable"
                                )

                            asynchronous: true
                        }

                        Column {
                            anchors {
                                left: appIcon.right
                                leftMargin: 11
                                right: parent.right
                                rightMargin: 50
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            spacing: 2

                            Text {
                                width: parent.width

                                text:
                                    modelData.name

                                elide:
                                    Text.ElideRight

                                color:
                                    parent.parent.selected
                                        ? Theme.accent
                                        : Theme.foreground

                                font {
                                    family:
                                        Theme.fontUI

                                    pixelSize: 10
                                    bold: true
                                }
                            }

                            Text {
                                visible:
                                    (
                                    modelData.description
                                    || ""
                                    ).length > 0

                                width: parent.width

                                text:
                                    (modelData.type === "action"
                                        ? "SEASHELL ACTION · "
                                        : "APPLICATION · ")
                                    + modelData.description

                                elide:
                                    Text.ElideRight

                                color:
                                    Theme.foregroundMuted

                                font {
                                    family:
                                        Theme.fontUI

                                    pixelSize: 7
                                }
                            }
                        }

                        Text {
                            visible:
                                parent.selected

                            anchors {
                                right: parent.right
                                rightMargin: 12
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            text: "ENTER"

                            color:
                                Theme.foregroundMuted

                            font {
                                family:
                                    Theme.fontMono

                                pixelSize: 6
                                bold: true
                            }
                        }

                        MouseArea {
                            id: itemMouse

                            anchors.fill: parent
                            hoverEnabled: true

                            cursorShape:
                                Qt.PointingHandCursor

                            onEntered:
                                window.selectedIndex =
                                    index

                            onClicked: {
                                ShellState.hideLauncher()

                                LauncherModel.activate(modelData)
                            }
                        }
                    }
                }

                // --------------------------------------------
                // EMPTY RESULT
                // --------------------------------------------

                Text {
                    visible:
                        resultModel.values.length
                        === 0

                    anchors.centerIn:
                        results

                    text:
                        "No results found"

                    color:
                        Theme.foregroundDisabled

                    font {
                        family:
                            Theme.fontUI

                        pixelSize: 10
                    }
                }

                // --------------------------------------------
                // FOOTER
                // --------------------------------------------

                Rectangle {
                    id: footer

                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    height: 38

                    color: "transparent"

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 18
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text:
                            resultModel.values.length
                            + " RESULTS"

                        color:
                            Theme.foregroundDisabled

                        font {
                            family:
                                Theme.fontMono

                            pixelSize: 6
                            bold: true
                        }
                    }

                    Text {
                        anchors {
                            right: parent.right
                            rightMargin: 18
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text:
                            "↑ ↓ SELECT   ENTER OPEN   ESC CLOSE"

                        color:
                            Theme.foregroundDisabled

                        font {
                            family:
                                Theme.fontMono

                            pixelSize: 6
                            bold: true
                            letterSpacing: 0.4
                        }
                    }
                }
            }
        }
    }
}
