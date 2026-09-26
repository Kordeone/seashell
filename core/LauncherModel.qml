pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var items: buildItems(
        DesktopEntries.applications.values,
        Config.hiddenApplications,
        Config.launcherSources
    )

    function isHidden(id) {
        return (Config.hiddenApplications || []).indexOf(id) !== -1
    }

    function setHidden(id, hidden) {
        const next = (Config.hiddenApplications || []).filter(value => value !== id)
        if (hidden) next.push(id)
        Config.hiddenApplications = next
    }

    function sourceEnabled(source) {
        return (Config.launcherSources || {})[source] !== false
    }

    function setSourceEnabled(source, enabled) {
        if (["applications", "actions", "webApps", "shortcuts"].indexOf(source) === -1)
            return
        Config.launcherSources = Object.assign({}, Config.launcherSources || {}, {
            [source]: enabled
        })
    }

    function buildItems(applications, hidden, sources) {
        const result = []
        const enabled = sources || {}
        if (enabled.applications !== false)
            result.push(...LauncherApplications.items(applications, hidden))
        if (enabled.actions !== false)
            result.push(...LauncherActions.items())
        if (enabled.webApps !== false)
            result.push(...webAppItems(Config.webApps || []))
        if (enabled.shortcuts !== false)
            result.push(...shortcutItems(Config.launcherShortcuts || []))
        return result
    }

    function webAppItems(values) {
        return values.filter(item => item && item.name && /^https?:\/\//i.test(item.url || ""))
            .map(item => ({
                type: "web-app", id: "web-app:" + item.id, name: item.name,
                description: item.url, icon: item.icon || "web-browser",
                keywords: String(item.keywords || "").split(/[,\s]+/).filter(Boolean),
                source: "web-apps", recordId: item.id, record: item
            }))
    }

    function shortcutItems(values) {
        return values.filter(item => item && item.name && item.target).map(item => ({
            type: "shortcut", id: "shortcut:" + item.id, name: item.name,
            description: item.description || item.type + " · " + item.target,
            icon: item.icon || (item.type === "url" ? "web-browser" : "system-run"),
            keywords: String(item.keywords || "").split(/[,\s]+/).filter(Boolean),
            source: "shortcuts", recordId: item.id, record: item
        }))
    }

    function rank(item, rawQuery) {
        const query = String(rawQuery || "").trim().toLowerCase()
        if (!query) {
            const order = { application: 0, action: 1, "web-app": 2, shortcut: 3 }
            return 100 - (order[item.type] || 0)
        }
        const name = String(item.name || "").toLowerCase()
        if (name === query) return 800
        if (name.startsWith(query)) return 700
        if (name.split(/\s+/).some(word => word.startsWith(query))) return 600
        if (name.includes(query)) return 500
        const keywords = (item.keywords || []).map(value => String(value).toLowerCase())
        if (keywords.some(value => value === query)) return 400
        if (keywords.some(value => value.startsWith(query))) return 350
        if (keywords.some(value => value.includes(query))) return 300
        if (String(item.description || "").toLowerCase().includes(query)) return 200
        if (String(item.id || "").toLowerCase().includes(query)) return 100
        return -1
    }

    function search(rawQuery) {
        return items.filter(item => rank(item, rawQuery) >= 0).sort((a, b) => {
            const difference = rank(b, rawQuery) - rank(a, rawQuery)
            if (difference) return difference
            return String(a.name).localeCompare(String(b.name)) || String(a.id).localeCompare(String(b.id))
        })
    }

    function activate(item) {
        if (!item) return
        if (item.source === "applications")
            LauncherApplications.activate(item)
        else if (item.source === "actions")
            LauncherActions.activate(item)
        else if (item.source === "web-apps")
            launchWebApp(item.record)
        else if (item.source === "shortcuts")
            launchShortcut(item.record)
    }

    function launchWebApp(item) {
        if (!item || !/^https?:\/\//i.test(item.url || "")) return false
        const browsers = {
            firefox: "firefox", chromium: "chromium", googleChrome: "google-chrome-stable",
            brave: "brave", system: "xdg-open"
        }
        const executable = browsers[item.browser] || "xdg-open"
        if (webProcess.running) return false
        webProcess.command = executable === "xdg-open"
            ? [executable, item.url] : [executable, "--app=" + item.url]
        webProcess.running = true
        return true
    }

    function launchShortcut(item) {
        if (!item || !item.target || shortcutProcess.running) return false
        let command = []
        if (item.type === "url" || item.type === "folder") {
            command = ["xdg-open", item.target]
        } else if (item.type === "command") {
            try {
                const parsed = JSON.parse(item.target)
                if (!Array.isArray(parsed) || !parsed.length
                        || parsed.some(part => typeof part !== "string")) return false
                command = parsed
            } catch (error) {
                return false
            }
        } else {
            return false
        }
        shortcutProcess.command = command
        shortcutProcess.running = true
        return true
    }

    Process { id: webProcess }
    Process { id: shortcutProcess }
}
