import QtQuick

import qs.core

Item {
    id: root

    Flickable {
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: catalog.implicitHeight

        Column {
            id: catalog
            width: parent.width
            spacing: 12

            Text {
                text: "MODULE PROVIDERS"
                color: Theme.foreground
                font.family: Theme.fontUI
                font.pixelSize: 14
                font.bold: true
            }
            Text {
                width: parent.width
                wrapMode: Text.Wrap
                text: "Browse native and external providers. Installation, selection, and process state are separate; actions appear only where Seashell has a working route."
                color: Theme.foregroundMuted
                font.family: Theme.fontUI
                font.pixelSize: 10
            }

            Repeater {
                model: ModuleRegistry.categories

                delegate: Column {
                    required property var modelData
                    width: catalog.width
                    spacing: 5

                    Text {
                        topPadding: 7
                        text: modelData.name.toUpperCase()
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Text {
                        width: parent.width
                        text: {
                            const selected = ModuleManager.activeProvider(modelData.id)
                            const current = ModuleRegistry.provider(selected)
                            const state = current ? ModuleManager.state(current.id) : null
                            const health = ModuleManager.transitionTarget ? "switching"
                                : (current && !current.builtIn && current.supportsLifecycle && !state.running
                                    ? "failed · not running" : "ready")
                            return "ACTIVE: " + (current ? current.name : "none")
                                + " · HEALTH: " + health
                        }
                        color: Theme.foregroundMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 7
                    }

                    Repeater {
                        model: ModuleManager.providersFor(modelData.id)

                        delegate: Rectangle {
                            id: providerCard
                            required property var modelData
                            width: parent.width
                            height: providerInfo.implicitHeight + 20
                            radius: Theme.radiusSmall
                            color: Theme.surface
                            border.width: Theme.borderWidth
                            border.color: providerState.active ? Theme.accent : Theme.border

                            readonly property var provider: modelData
                            readonly property var providerState: ModuleManager.state(provider.id)

                            Column {
                                id: providerInfo
                                anchors.left: parent.left
                                anchors.leftMargin: 11
                                anchors.right: removeAction.left
                                anchors.rightMargin: 7
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 3

                                Text {
                                    width: parent.width
                                    text: providerCard.provider.name
                                    elide: Text.ElideRight
                                    color: Theme.foreground
                                    font.family: Theme.fontUI
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                                Text {
                                    width: parent.width
                                    text: providerCard.provider.description
                                    elide: Text.ElideRight
                                    color: Theme.foregroundMuted
                                    font.family: Theme.fontUI
                                    font.pixelSize: 8
                                }
                                Text {
                                    width: parent.width
                                    text: providerCard.providerState.status
                                        + (providerCard.provider.packages.length
                                            ? " · " + providerCard.providerState.source : "")
                                        + " · RUNNING " + (providerCard.providerState.running ? "yes" : "no")
                                    elide: Text.ElideRight
                                    color: providerCard.providerState.active
                                        ? Theme.accent : Theme.foregroundMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 8
                                    font.bold: providerCard.providerState.active
                                }
                                Text {
                                    width: parent.width
                                    text: "Theme sync "
                                        + (providerCard.provider.supportsThemeSync ? "yes" : "no")
                                        + " · Settings "
                                        + (providerCard.provider.supportsSettings ? "yes" : "no")
                                        + " · Activation "
                                        + (providerCard.provider.supportsActivation ? "supported" : "planned")
                                        + " · Config " + providerCard.provider.configOwnership
                                    elide: Text.ElideRight
                                    color: Theme.foregroundMuted
                                    font.family: Theme.fontMono
                                    font.pixelSize: 7
                                }
                            }

                            Rectangle {
                                id: providerAction
                                anchors.right: parent.right
                                anchors.rightMargin: 9
                                anchors.verticalCenter: parent.verticalCenter
                                width: 80
                                height: 28
                                radius: Theme.radiusSmall
                                color: Theme.surfaceRaised
                                border.width: Theme.borderWidth
                                border.color: activeFocus ? Theme.focus : Theme.border
                                activeFocusOnTab: providerCard.providerState.canInstall
                                    || providerCard.providerState.canUse

                                readonly property bool active:
                                    providerCard.providerState.active
                                readonly property bool enabledAction:
                                    providerCard.providerState.canInstall
                                    || providerCard.providerState.canUse
                                    || (active && ProviderProcessManager.managedSoftware(providerCard.provider.id)
                                        && providerCard.providerState.running)
                                    || (active && ProviderProcessManager.managedSoftware(providerCard.provider.id)
                                        && providerCard.provider.supportsLifecycle)
                                    || (active && providerCard.provider.builtIn
                                        && providerCard.provider.supportsSettings)
                                readonly property string label:
                                    active && ProviderProcessManager.managedSoftware(providerCard.provider.id)
                                        && providerCard.providerState.running ? "STOP"
                                    : active ? (providerCard.provider.builtIn
                                        && providerCard.provider.supportsSettings ? "SETTINGS" : "ACTIVE")
                                    : providerCard.provider.planned ? "PLANNED"
                                    : providerCard.providerState.canInstall ? "INSTALL"
                                    : providerCard.providerState.canUse ? "USE"
                                    : providerCard.providerState.installed ? "INFO"
                                    : providerCard.providerState.available ? "AVAILABLE"
                                    : providerCard.providerState.checked ? "UNAVAILABLE" : "CHECKING"

                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                            || event.key === Qt.Key_Space) {
                                        providerAction.choose()
                                        event.accepted = true
                                    }
                                }
                                function choose() {
                                    if (active && providerCard.provider.builtIn
                                            && providerCard.provider.supportsSettings)
                                        ShellState.showSettings(providerCard.provider.category, "general")
                                    else if (active && ProviderProcessManager.managedSoftware(providerCard.provider.id)
                                            && providerCard.providerState.running)
                                        ProviderProcessManager.deactivate(providerCard.provider.id)
                                    else if (providerCard.providerState.canInstall)
                                        ModuleManager.requestInstall(providerCard.provider.id)
                                    else if (providerCard.providerState.canUse
                                            || (active && providerCard.provider.supportsLifecycle))
                                        ModuleManager.use(providerCard.provider.id)
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: providerAction.label
                                    color: providerAction.active ? Theme.accent
                                        : providerAction.enabledAction ? Theme.foreground
                                        : Theme.foregroundDisabled
                                    font.family: Theme.fontMono
                                    font.pixelSize: 7
                                    font.bold: true
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    enabled: providerAction.enabledAction
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: providerAction.choose()
                                }
                            }

                            Rectangle {
                                id: removeAction
                                anchors.right: providerAction.left
                                anchors.rightMargin: 5
                                anchors.verticalCenter: parent.verticalCenter
                                width: 58
                                height: 28
                                radius: Theme.radiusSmall
                                visible: providerCard.providerState.canUninstall
                                color: Theme.background
                                border.width: Theme.borderWidth
                                border.color: activeFocus ? Theme.focus : Theme.danger
                                activeFocusOnTab: visible
                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                            || event.key === Qt.Key_Space) {
                                        PackageManager.requestUninstall(providerCard.provider.id)
                                        event.accepted = true
                                    }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: "REMOVE"
                                    color: Theme.danger
                                    font.family: Theme.fontMono
                                    font.pixelSize: 7
                                    font.bold: true
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: PackageManager.requestUninstall(providerCard.provider.id)
                                }
                            }
                        }
                    }
                }
            }

            Text {
                width: parent.width
                wrapMode: Text.Wrap
                visible: ModuleManager.statusMessage.length > 0
                    || ProviderProcessManager.transitionMessage.length > 0
                text: ProviderProcessManager.transitionMessage.length > 0
                    ? ProviderProcessManager.transitionMessage : ModuleManager.statusMessage
                color: Theme.accent
                font.family: Theme.fontUI
                font.pixelSize: 9
            }

            Text {
                width: parent.width
                wrapMode: Text.Wrap
                visible: PackageManager.probing
                text: "Checking pacman, installed packages, configured repositories, AUR helper, and Polkit agent…"
                color: Theme.foregroundMuted
                font.family: Theme.fontMono
                font.pixelSize: 8
            }
            Text {
                width: parent.width
                wrapMode: Text.Wrap
                visible: PackageManager.hasProbed && !PackageManager.pacmanAvailable
                text: "pacman was not found. Package discovery and installation are unavailable on this system."
                color: Theme.warning
                font.family: Theme.fontUI
                font.pixelSize: 9
            }
            Text {
                width: parent.width
                wrapMode: Text.Wrap
                visible: PackageManager.hasProbed && PackageManager.pacmanAvailable
                    && (!PackageManager.pkexecAvailable || !PackageManager.polkitAgentAvailable)
                text: !PackageManager.pkexecAvailable
                    ? "pkexec is unavailable. Official repository installation needs a system privilege tool."
                    : "No supported graphical Polkit authentication agent is running. Start the session agent before installing official repository packages."
                color: Theme.warning
                font.family: Theme.fontUI
                font.pixelSize: 9
            }
            Text {
                width: parent.width
                wrapMode: Text.Wrap
                visible: PackageManager.installState === "failed"
                text: PackageManager.errorMessage
                color: Theme.warning
                font.family: Theme.fontUI
                font.pixelSize: 9
            }
            Rectangle {
                activeFocusOnTab: true
                width: 96
                height: 27
                radius: Theme.radiusSmall
                color: Theme.surface
                border.width: Theme.borderWidth
                border.color: activeFocus ? Theme.focus : Theme.border
                Text {
                    anchors.centerIn: parent
                    text: "REFRESH STATUS"
                    color: Theme.foregroundMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 7
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PackageManager.refresh()
                }
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                            || event.key === Qt.Key_Space) {
                        PackageManager.refresh()
                        event.accepted = true
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.Wrap
                text: PackageManager.aurHelper
                    ? "AUR helper detected: " + PackageManager.aurHelper
                        + (PackageManager.terminal ? " · terminal: " + PackageManager.terminal : " · no supported terminal found; AUR installs unavailable")
                    : "No AUR helper detected. AUR packages are shown unavailable; Seashell will not install an AUR helper."
                color: Theme.foregroundMuted
                font.family: Theme.fontMono
                font.pixelSize: 8
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: PackageManager.installState === "waiting-confirmation"
            || PackageManager.installState === "authenticating"
                    || PackageManager.installState === "installing"
                    || PackageManager.installState === "verifying"
            || PackageManager.installState === "success"
            || PackageManager.installState === "failed"
        z: 100
        color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.76)

        MouseArea { anchors.fill: parent }

        Rectangle {
            id: confirmation
            anchors.centerIn: parent
            width: Math.min(370, parent.width - 24)
            height: installDetails.implicitHeight + 100
            radius: Theme.radiusMedium
            color: Theme.surfaceRaised
            border.width: Theme.borderWidth
            border.color: Theme.border

            readonly property var provider: ModuleRegistry.provider(PackageManager.installProviderId)
            readonly property var providerState: ModuleManager.state(PackageManager.installProviderId)
            readonly property bool awaitingConfirmation:
                PackageManager.installState === "waiting-confirmation"
            readonly property bool finished:
                PackageManager.installState === "success"
                || PackageManager.installState === "failed"

            Column {
                id: installDetails
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                spacing: 8

                Text {
                    text: PackageManager.installState === "success" ? "Installation complete"
                        : PackageManager.installState === "failed" ? "Installation needs attention"
                        : confirmation.awaitingConfirmation
                            ? (PackageManager.installOperation === "uninstall" ? "Remove " : "Install ")
                                + (confirmation.provider ? confirmation.provider.name : "provider") + "?"
                            : PackageManager.installState === "authenticating"
                                ? "Waiting for system authorization…"
                                : PackageManager.installState === "verifying"
                                    ? "Verifying package installation…" : "Installing…"
                    color: Theme.foreground
                    font.family: Theme.fontUI
                    font.pixelSize: 13
                    font.bold: true
                }
                Text {
                    width: parent.width
                    wrapMode: Text.Wrap
                    text: "Packages: " + PackageManager.packageLabels(PackageManager.installProviderId)
                    color: Theme.foregroundMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                }
                Text {
                    width: parent.width
                    wrapMode: Text.Wrap
                    text: "Source: " + PackageManager.installPlan(PackageManager.installProviderId).source
                    color: Theme.foregroundMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                }
                Text {
                    width: parent.width
                    wrapMode: Text.Wrap
                    visible: confirmation.awaitingConfirmation
                    text: PackageManager.installOperation === "uninstall"
                        ? "The selected application will be removed. Dependencies will be kept; Seashell-generated configuration will remain. System authentication is handled by the terminal and Polkit agent."
                        : PackageManager.installPlan(PackageManager.installProviderId).aur.length
                            ? "The detected AUR helper will run in a terminal. Review any build prompts there."
                            : "Administrator authentication will be requested by the system. Seashell never receives or stores your password."
                    color: Theme.foreground
                    font.family: Theme.fontUI
                    font.pixelSize: 9
                }
                Text {
                    width: parent.width
                    wrapMode: Text.Wrap
                    visible: PackageManager.errorMessage.length > 0
                    text: PackageManager.errorMessage
                    color: Theme.warning
                    font.family: Theme.fontUI
                    font.pixelSize: 9
                }
            }

            Row {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 14
                spacing: 7

                Rectangle {
                    width: 72
                    height: 29
                    radius: Theme.radiusSmall
                    color: Theme.background
                    border.width: Theme.borderWidth
                    border.color: Theme.border
                    visible: confirmation.awaitingConfirmation || confirmation.finished
                    Text {
                        anchors.centerIn: parent
                        text: confirmation.finished ? "CLOSE" : "CANCEL"
                        color: Theme.foregroundMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 8
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (confirmation.finished) {
                                PackageManager.installState = "idle"
                                PackageManager.installProviderId = ""
                            } else {
                                PackageManager.cancelInstall()
                            }
                        }
                    }
                }

                Rectangle {
                    width: 76
                    height: 29
                    radius: Theme.radiusSmall
                    color: Theme.surface
                    border.width: Theme.borderWidth
                    border.color: Theme.accent
                    visible: confirmation.awaitingConfirmation
                    Text {
                        anchors.centerIn: parent
                        text: PackageManager.installOperation === "uninstall" ? "REMOVE" : "INSTALL"
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: 8
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PackageManager.confirmInstall()
                    }
                }
            }
        }
    }
}
