pragma Singleton

import QtQuick
import Quickshell

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
        if (hidden)
            next.push(id)
        Config.hiddenApplications = next
    }

    function sourceEnabled(source) {
        const sources = Config.launcherSources || {}
        return sources[source] !== false
    }

    function setSourceEnabled(source, enabled) {
        if (source !== "applications" && source !== "actions")
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
        return result
    }

    function rank(item, query) {
        if (!query)
            return item.type === "action" ? 1 : 0

        const name = item.name.toLowerCase()
        if (name === query)
            return 600
        if (name.startsWith(query))
            return 500
        if (name.includes(query))
            return 400
        if ((item.keywords || []).some(word => String(word).toLowerCase().includes(query)))
            return 300
        if ((item.description || "").toLowerCase().includes(query))
            return 200
        if (item.id.toLowerCase().includes(query))
            return 100
        return -1
    }

    function search(rawQuery) {
        const query = (rawQuery || "").trim().toLowerCase()
        return items.filter(item => rank(item, query) >= 0).sort((a, b) => {
            const difference = rank(b, query) - rank(a, query)
            if (difference)
                return difference
            const byName = a.name.localeCompare(b.name)
            return byName || a.id.localeCompare(b.id)
        })
    }

    function activate(item) {
        if (!item)
            return
        if (item.source === "applications")
            LauncherApplications.activate(item)
        else if (item.source === "actions")
            LauncherActions.activate(item)
    }
}
