import QtQuick
import Quickshell
import Quickshell.Widgets

import qs.core

Item {
    id: root
    required property string tab
    property string applicationQuery: ""
    property string editingWebAppId: ""
    property string editingShortcutId: ""

    readonly property var sourceRows: [
        { id: "applications", name: "Applications", description: "Installed desktop applications", available: true },
        { id: "actions", name: "Seashell Actions", description: "Settings and shell commands", available: true },
        { id: "webApps", name: "Web Apps", description: "User-defined web links and browser apps", available: true },
        { id: "shortcuts", name: "Shortcuts", description: "URLs, folders, and trusted argument-list commands", available: true },
        { id: "calculator", name: "Calculator", description: "Coming later", available: false },
        { id: "clipboard", name: "Clipboard", description: "Coming later", available: false },
        { id: "files", name: "Files", description: "Coming later", available: false }
    ]

    function visibleApplications(entries, query) {
        const needle = query.trim().toLowerCase()
        return [...entries].filter(entry =>
            !needle || (entry.name || "").toLowerCase().includes(needle)
                || (entry.id || "").toLowerCase().includes(needle)
        ).sort((a, b) =>
            (a.name || "").localeCompare(b.name || "") || a.id.localeCompare(b.id)
        )
    }

    function saveWebApp() {
        const name = webName.text.trim()
        const url = webUrl.text.trim()
        if (!name || !/^https?:\/\//i.test(url)) return
        const next = [...(Config.webApps || [])]
        const entry = { id: editingWebAppId || "web-" + Date.now(), name: name,
            url: url, icon: webIcon.text.trim() || "web-browser",
            browser: webBrowser.text.trim() || "system", keywords: webKeywords.text.trim() }
        const index = next.findIndex(item => item.id === editingWebAppId)
        if (index >= 0) next[index] = entry
        else next.push(entry)
        Config.webApps = next
        editingWebAppId = ""
        webName.text = ""; webUrl.text = ""; webIcon.text = ""; webKeywords.text = ""; webBrowser.text = "system"
    }

    function editWebApp(item) {
        editingWebAppId = item.id
        webName.text = item.name; webUrl.text = item.url; webIcon.text = item.icon || ""
        webKeywords.text = item.keywords || ""; webBrowser.text = item.browser || "system"
    }

    function saveShortcut() {
        const name = shortcutName.text.trim()
        const type = shortcutType.text.trim().toLowerCase()
        const target = shortcutTarget.text.trim()
        if (!name || !target || ["url", "folder", "command"].indexOf(type) === -1) return
        if (type === "url" && !/^https?:\/\//i.test(target)) return
        if (type === "command") {
            try {
                const command = JSON.parse(target)
                if (!Array.isArray(command) || !command.length
                        || command.some(part => typeof part !== "string")) return
            } catch (error) { return }
        }
        const next = [...(Config.launcherShortcuts || [])]
        const entry = { id: editingShortcutId || "shortcut-" + Date.now(), name: name,
            description: shortcutDescription.text.trim(), type: type, target: target,
            icon: "system-run", keywords: shortcutKeywords.text.trim() }
        const index = next.findIndex(item => item.id === editingShortcutId)
        if (index >= 0) next[index] = entry
        else next.push(entry)
        Config.launcherShortcuts = next
        editingShortcutId = ""
        shortcutName.text = ""; shortcutType.text = "url"; shortcutTarget.text = ""
        shortcutDescription.text = ""; shortcutKeywords.text = ""
    }

    function editShortcut(item) {
        editingShortcutId = item.id
        shortcutName.text = item.name; shortcutType.text = item.type; shortcutTarget.text = item.target
        shortcutDescription.text = item.description || ""; shortcutKeywords.text = item.keywords || ""
    }


    Flickable {
        anchors.fill: parent
        visible: root.tab === "sources"
        clip: true
        contentWidth: width
        contentHeight: sourceContent.implicitHeight

        Column {
            id: sourceContent
            width: parent.width
            spacing: 8

        Text {
            text: "LAUNCHER SOURCES"
            color: Theme.foreground
            font.family: Theme.fontUI
            font.pixelSize: 14
            font.bold: true
        }

        Text {
            text: "Choose which sources appear in the unified search."
            color: Theme.foregroundMuted
            font.family: Theme.fontUI
            font.pixelSize: 10
        }

            Repeater {
            model: root.sourceRows
            delegate: Rectangle {
                required property var modelData
                activeFocusOnTab: modelData.available
                width: parent.width
                height: 49
                radius: Theme.radiusSmall
                color: Theme.surface
                border.width: Theme.borderWidth
                border.color: activeFocus ? Theme.focus : Theme.border
                opacity: modelData.available ? 1 : 0.55

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                            || event.key === Qt.Key_Space) {
                        LauncherModel.setSourceEnabled(modelData.id,
                            !LauncherModel.sourceEnabled(modelData.id))
                        event.accepted = true
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    Text {
                        text: modelData.name
                        color: Theme.foreground
                        font.family: Theme.fontUI
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Text {
                        text: modelData.description
                        color: Theme.foregroundMuted
                        font.family: Theme.fontUI
                        font.pixelSize: 8
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.available
                        ? (LauncherModel.sourceEnabled(modelData.id) ? "ON" : "OFF")
                        : "LATER"
                    color: modelData.available && LauncherModel.sourceEnabled(modelData.id)
                        ? Theme.accent : Theme.foregroundMuted
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: modelData.available
                    cursorShape: Qt.PointingHandCursor
                    onClicked: LauncherModel.setSourceEnabled(
                        modelData.id, !LauncherModel.sourceEnabled(modelData.id))
                }
            }
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: root.tab === "applications"

        Text {
            id: heading
            text: "APPLICATIONS"
            color: Theme.foreground
            font.family: Theme.fontUI
            font.pixelSize: 14
            font.bold: true
        }

        Text {
            id: help
            anchors.top: heading.bottom
            anchors.topMargin: 5
            text: "Hide apps from Seashell without changing their desktop entries."
            color: Theme.foregroundMuted
            font.family: Theme.fontUI
            font.pixelSize: 10
        }

        Rectangle {
            id: searchBox
            anchors.top: help.bottom
            anchors.topMargin: 14
            width: parent.width
            height: 38
            radius: Theme.radiusSmall
            color: Theme.surface
            border.width: Theme.borderWidth
            border.color: appSearch.activeFocus ? Theme.focus : Theme.border

            TextInput {
                id: appSearch
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.foreground
                selectionColor: Theme.accent
                selectedTextColor: Theme.accentForeground
                font.family: Theme.fontUI
                font.pixelSize: 11
                onTextChanged: root.applicationQuery = text
            }
            Text {
                visible: appSearch.text.length === 0
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "Search applications…"
                color: Theme.foregroundDisabled
                font.family: Theme.fontUI
                font.pixelSize: 11
            }
        }

        ListView {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: searchBox.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: 10
            clip: true
            spacing: 4
            model: root.visibleApplications(
                DesktopEntries.applications.values, root.applicationQuery)

            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: 50
                radius: Theme.radiusSmall
                color: Theme.surface
                border.width: Theme.borderWidth
                border.color: Theme.border

                readonly property bool hidden: LauncherModel.isHidden(modelData.id)

                IconImage {
                    id: icon
                    anchors.left: parent.left
                    anchors.leftMargin: 9
                    anchors.verticalCenter: parent.verticalCenter
                    width: 30
                    height: 30
                    source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                    asynchronous: true
                }
                Column {
                    anchors.left: icon.right
                    anchors.leftMargin: 10
                    anchors.right: action.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    Text {
                        width: parent.width
                        text: modelData.name
                        elide: Text.ElideRight
                        color: Theme.foreground
                        font.family: Theme.fontUI
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Text {
                        width: parent.width
                        text: hidden ? "HIDDEN · " + modelData.id : modelData.id
                        elide: Text.ElideRight
                        color: hidden ? Theme.warning : Theme.foregroundMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 8
                    }
                }
                Rectangle {
                    id: action
                    activeFocusOnTab: true
                    anchors.right: parent.right
                    anchors.rightMargin: 9
                    anchors.verticalCenter: parent.verticalCenter
                    width: 70
                    height: 28
                    radius: Theme.radiusSmall
                    color: hidden ? Theme.surfaceRaised : Theme.background
                    border.width: Theme.borderWidth
                    border.color: activeFocus ? Theme.focus : Theme.border
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                || event.key === Qt.Key_Space) {
                            LauncherModel.setHidden(modelData.id, !hidden)
                            event.accepted = true
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: hidden ? "SHOW" : "HIDE"
                        color: hidden ? Theme.accent : Theme.foregroundMuted
                        font.family: Theme.fontMono
                        font.pixelSize: 8
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: LauncherModel.setHidden(modelData.id, !hidden)
                    }
                }
            }
        }
    }

    Flickable {
        anchors.fill: parent
        visible: root.tab === "web-apps"
        clip: true
        contentWidth: width
        contentHeight: webContent.implicitHeight
        Column {
            id: webContent
            width: parent.width
            spacing: 7
            Text { text: "WEB APPS"; color: Theme.foreground; font.family: Theme.fontUI; font.pixelSize: 14; font.bold: true }
            Text {
                width: parent.width
                wrapMode: Text.Wrap
                text: "Add HTTPS/HTTP links. Use system to open the default browser, or select Firefox, Chromium, or Brave."
                color: Theme.foregroundMuted; font.family: Theme.fontUI; font.pixelSize: 9
            }
            LauncherTextField { id: webName; width: parent.width; placeholderText: "Name" }
            LauncherTextField { id: webUrl; width: parent.width; placeholderText: "https://example.com" }
            Row {
                width: parent.width; spacing: 6
                LauncherTextField { id: webBrowser; width: (parent.width - 6) * 0.42; placeholderText: "Browser: system / firefox / chromium / brave"; text: "system" }
                LauncherTextField { id: webIcon; width: (parent.width - 6) * 0.58; placeholderText: "Icon name (optional)" }
            }
            LauncherTextField { id: webKeywords; width: parent.width; placeholderText: "Keywords, separated by commas" }
            Row {
                spacing: 6
                LauncherActionButton { label: root.editingWebAppId ? "SAVE CHANGES" : "ADD WEB APP"; emphasized: true; onClicked: root.saveWebApp() }
                LauncherActionButton { label: "CLEAR"; onClicked: { root.editingWebAppId = ""; webName.text = ""; webUrl.text = ""; webIcon.text = ""; webKeywords.text = ""; webBrowser.text = "system" } }
            }
            Repeater {
                model: Config.webApps || []
                delegate: Rectangle {
                    required property var modelData
                    width: webContent.width; height: 54; radius: Theme.radiusSmall
                    color: Theme.surface; border.width: Theme.borderWidth; border.color: Theme.border
                    Text {
                        anchors.left: parent.left; anchors.leftMargin: 10; anchors.right: buttons.left
                        anchors.rightMargin: 7; anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name + " · " + modelData.url + " · " + (modelData.browser || "system")
                        elide: Text.ElideRight; color: Theme.foreground; font.family: Theme.fontUI; font.pixelSize: 8
                    }
                    Row {
                        id: buttons; anchors.right: parent.right; anchors.rightMargin: 7
                        anchors.verticalCenter: parent.verticalCenter; spacing: 4
                        LauncherActionButton { label: "EDIT"; onClicked: root.editWebApp(modelData) }
                        LauncherActionButton {
                            label: "REMOVE"
                            onClicked: Config.webApps = (Config.webApps || []).filter(item => item.id !== modelData.id)
                        }
                    }
                }
            }
        }
    }

    Flickable {
        anchors.fill: parent
        visible: root.tab === "shortcuts"
        clip: true
        contentWidth: width
        contentHeight: shortcutContent.implicitHeight
        Column {
            id: shortcutContent
            width: parent.width
            spacing: 7
            Text { text: "USER SHORTCUTS"; color: Theme.foreground; font.family: Theme.fontUI; font.pixelSize: 14; font.bold: true }
            Text {
                width: parent.width; wrapMode: Text.Wrap
                text: "Types: url, folder, command. Commands are JSON argument arrays, for example [\"code\", \"/path/to/project\"]. They are launched without a shell."
                color: Theme.foregroundMuted; font.family: Theme.fontUI; font.pixelSize: 9
            }
            LauncherTextField { id: shortcutName; width: parent.width; placeholderText: "Shortcut name" }
            Row {
                width: parent.width; spacing: 6
                LauncherTextField { id: shortcutType; width: (parent.width - 6) * 0.28; placeholderText: "Type: url / folder / command"; text: "url" }
                LauncherTextField { id: shortcutTarget; width: (parent.width - 6) * 0.72; placeholderText: "URL, folder path, or JSON argv" }
            }
            LauncherTextField { id: shortcutDescription; width: parent.width; placeholderText: "Description (optional)" }
            LauncherTextField { id: shortcutKeywords; width: parent.width; placeholderText: "Keywords, separated by commas" }
            Row {
                spacing: 6
                LauncherActionButton { label: root.editingShortcutId ? "SAVE CHANGES" : "ADD SHORTCUT"; emphasized: true; onClicked: root.saveShortcut() }
                LauncherActionButton { label: "CLEAR"; onClicked: { root.editingShortcutId = ""; shortcutName.text = ""; shortcutType.text = "url"; shortcutTarget.text = ""; shortcutDescription.text = ""; shortcutKeywords.text = "" } }
            }
            Repeater {
                model: Config.launcherShortcuts || []
                delegate: Rectangle {
                    required property var modelData
                    width: shortcutContent.width; height: 54; radius: Theme.radiusSmall
                    color: Theme.surface; border.width: Theme.borderWidth; border.color: Theme.border
                    Text {
                        anchors.left: parent.left; anchors.leftMargin: 10; anchors.right: buttons.left
                        anchors.rightMargin: 7; anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name + " · " + modelData.type + " · " + modelData.target
                        elide: Text.ElideRight; color: Theme.foreground; font.family: Theme.fontUI; font.pixelSize: 8
                    }
                    Row {
                        id: buttons; anchors.right: parent.right; anchors.rightMargin: 7
                        anchors.verticalCenter: parent.verticalCenter; spacing: 4
                        LauncherActionButton { label: "EDIT"; onClicked: root.editShortcut(modelData) }
                        LauncherActionButton {
                            label: "REMOVE"
                            onClicked: Config.launcherShortcuts = (Config.launcherShortcuts || []).filter(item => item.id !== modelData.id)
                        }
                    }
                }
            }
        }
    }
}
