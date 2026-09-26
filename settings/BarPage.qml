import QtQuick

import qs.core

Item {
    id: root

    property string tab: "clock"

    signal moreFontsRequested()

    readonly property string effectiveFontFamily:
        Typography.moduleFontFamily(
            "bar.clock",
            Theme.fontUI
        )

    // ========================================================
    // CLOCK
    // ========================================================

    Item {
        anchors.fill: parent

        visible:
            root.tab === "clock"

        Text {
            id: clockLabel

            anchors {
                left: parent.left
                top: parent.top
            }

            text: "CLOCK PREVIEW"

            color: Theme.foregroundMuted

            font {
                family: Theme.fontMono
                pixelSize: 9
                bold: true
                letterSpacing: 1
            }
        }

        Rectangle {
            id: clockPreview

            anchors {
                left: parent.left
                right: parent.right
                top: clockLabel.bottom
                topMargin: 8
            }

            height: 60

            radius: Theme.radiusMedium
            color: Theme.surface

            border {
                width: Theme.borderWidth
                color: Theme.border
            }

            Text {
                id: previewText

                anchors.centerIn: parent

                text:
                    Qt.formatDateTime(
                        new Date(),
                        Config.clockFormat
                    )

                color: Theme.foreground

                font {
                    family:
                        root.effectiveFontFamily

                    pixelSize: 20
                    bold: true
                    letterSpacing: 1
                }

                Timer {
                    interval: 1000
                    running: root.visible
                    repeat: true

                    onTriggered:
                        previewText.text =
                            Qt.formatDateTime(
                                new Date(),
                                Config.clockFormat
                            )
                }
            }
        }

        Text {
            anchors {
                left: parent.left
                top: clockPreview.bottom
                topMargin: 16
            }

            text: "CLOCK FONT"

            color: Theme.foregroundMuted

            font {
                family: Theme.fontMono
                pixelSize: 8
                bold: true
                letterSpacing: 1
            }
        }

        ModuleFontDropdown {
            id: fontDropdown

            anchors {
                left: parent.left
                right: parent.right
                top: clockPreview.bottom
                topMargin: 34
            }

            moduleKey: "bar.clock"

            onMoreFontsRequested:
                root.moreFontsRequested()
        }

        Text {
            anchors {
                left: parent.left
                top: fontDropdown.bottom
                topMargin: 14
            }

            text: "FORMAT"

            color: Theme.foregroundMuted

            font {
                family: Theme.fontMono
                pixelSize: 8
                bold: true
                letterSpacing: 1
            }
        }

        Rectangle {
            id: formatBox

            anchors {
                left: parent.left
                right: parent.right
                top: fontDropdown.bottom
                topMargin: 32
            }

            height: 36

            radius: Theme.radiusSmall
            color: Theme.surface

            border {
                width: Theme.borderWidth

                color:
                    formatInput.activeFocus
                        ? Theme.focus
                        : Theme.border
            }

            TextInput {
                id: formatInput

                anchors {
                    fill: parent
                    leftMargin: 11
                    rightMargin: 11
                }

                verticalAlignment:
                    TextInput.AlignVCenter

                text: Config.clockFormat

                color: Theme.foreground

                selectionColor:
                    Theme.accent

                selectedTextColor:
                    Theme.accentForeground

                font {
                    family: Theme.fontMono
                    pixelSize: 9
                }

                onAccepted: {
                    if (text.length > 0)
                        Config.clockFormat = text
                }

                onEditingFinished: {
                    if (text.length > 0)
                        Config.clockFormat = text
                }
            }
        }

        Row {
            id: presets

            anchors {
                left: parent.left
                right: parent.right
                top: formatBox.bottom
                topMargin: 12
            }

            spacing: 7

            Repeater {
                model: [
                    {
                        name: "24 HOUR",
                        format: "HH:mm"
                    },
                    {
                        name: "12 HOUR",
                        format: "hh:mm AP"
                    },
                    {
                        name: "DAY + TIME",
                        format: "ddd · HH:mm"
                    },
                    {
                        name: "FULL DATE",
                        format:
                            "dddd · d MMMM · HH:mm"
                    }
                ]

                delegate: Rectangle {
                    required property var modelData

                    width:
                        (
                            presets.width
                            - 21
                        ) / 4

                    height: 30

                    radius: Theme.radiusSmall

                    color:
                        Config.clockFormat
                        === modelData.format
                            ? Theme.surfaceRaised
                            : Theme.surface

                    border {
                        width:
                            Config.clockFormat
                            === modelData.format
                                ? 2
                                : Theme.borderWidth

                        color:
                            Config.clockFormat
                            === modelData.format
                                ? Theme.accent
                                : Theme.border
                    }

                    Text {
                        anchors.centerIn: parent

                        text: modelData.name

                        color:
                            Config.clockFormat
                            === modelData.format
                                ? Theme.accent
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

                        onClicked: {
                            Config.clockFormat =
                                modelData.format

                            formatInput.text =
                                modelData.format
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: presets.bottom
                topMargin: 12
            }

            height:
                tokenText.implicitHeight
                + 22

            radius: Theme.radiusMedium

            color: Qt.rgba(
                Theme.background.r,
                Theme.background.g,
                Theme.background.b,
                0.22
            )

            border {
                width: Theme.borderWidth
                color: Theme.border
            }

            Text {
                id: tokenText

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 11
                }

                text:
                    "FORMAT TOKENS\n"
                    + "d/dd day  ·  ddd/dddd weekday  ·  M/MM month  ·  MMM/MMMM month name\n"
                    + "yy/yyyy year  ·  h/hh 12-hour  ·  H/HH 24-hour\n"
                    + "m/mm minute  ·  s/ss second  ·  AP/ap AM/PM"

                wrapMode: Text.WordWrap

                color: Theme.foregroundMuted

                font {
                    family: Theme.fontMono
                    pixelSize: 8
                }

                lineHeight: 1.25
            }
        }
    }

    // ========================================================
    // ITEMS
    // ========================================================

    Item {
        anchors.fill: parent

        visible:
            root.tab === "items"

        Text {
            id: itemHeading

            anchors {
                left: parent.left
                top: parent.top
            }

            text: "BAR ITEMS"

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
                top: itemHeading.bottom
                topMargin: 5
            }

            text:
                "Visibility, ordering and positioning controls will live here."

            color: Theme.foregroundMuted

            font {
                family: Theme.fontUI
                pixelSize: 9
            }
        }

        Column {
            anchors {
                left: parent.left
                right: parent.right
                top: itemHeading.bottom
                topMargin: 32
            }

            spacing: 5

            Repeater {
                model: [
                    {
                        name: "Sea mark",
                        state: "CURRENT"
                    },
                    {
                        name: "Clock",
                        state: "CURRENT"
                    },
                    {
                        name: "Settings hammer",
                        state: "CURRENT"
                    },
                    {
                        name: "Workspaces",
                        state: "PLANNED"
                    },
                    {
                        name: "Active window",
                        state: "PLANNED"
                    },
                    {
                        name: "System tray / status",
                        state: "PLANNED"
                    },
                    {
                        name: "Media",
                        state: "PLANNED"
                    },
                    {
                        name: "Network",
                        state: "PLANNED"
                    },
                    {
                        name: "Battery / power",
                        state: "PLANNED"
                    }
                ]

                delegate: Rectangle {
                    required property var modelData

                    width: parent.width
                    height: 34

                    radius: Theme.radiusSmall
                    color: Theme.surface

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

                        text: modelData.name

                        color: Theme.foreground

                        font {
                            family: Theme.fontUI
                            pixelSize: 9
                        }
                    }

                    Text {
                        anchors {
                            right: parent.right
                            rightMargin: 12
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text: modelData.state

                        color:
                            modelData.state === "CURRENT"
                                ? Theme.accent
                                : Theme.foregroundDisabled

                        font {
                            family: Theme.fontMono
                            pixelSize: 7
                            bold: true
                            letterSpacing: 0.7
                        }
                    }
                }
            }
        }
    }
}
