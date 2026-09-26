pragma Singleton

import QtQuick
import Quickshell

Singleton {
    function items(applications, hidden) {
        const result = []
        const hiddenIds = hidden || []
        for (const entry of applications || []) {
            if (hiddenIds.indexOf(entry.id) !== -1)
                continue
            result.push({
                type: "application",
                id: "application:" + entry.id,
                name: entry.name || entry.id,
                description: entry.genericName || entry.comment || "Application",
                icon: entry.icon || "application-x-executable",
                keywords: [...(entry.keywords || []), entry.genericName || "",
                    entry.comment || ""],
                source: "applications",
                desktopId: entry.id,
                entry: entry
            })
        }
        return result
    }

    function activate(item) {
        item.entry.execute()
    }
}
