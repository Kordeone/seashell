pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.core

Singleton {
    id: root

    property var packageStates: ({})
    property var probeQueue: []
    property var currentProbe: null
    property bool probing: false
    property bool hasProbed: false
    property bool refreshAgain: false
    property int pendingToolChecks: 0
    property bool pacmanAvailable: false
    property bool pkexecAvailable: false
    property bool polkitAgentAvailable: false
    property bool paruAvailable: false
    property bool yayAvailable: false
    property string aurHelper: ""
    property string terminal: ""

    property string installState: "idle"
    property string installProviderId: ""
    property string installOperation: "install"
    property string installOutput: ""
    property string errorMessage: ""
    property string diagnosticTimestamp: ""
    property int installExitCode: -1
    property bool checkingInstallResult: false
    property var runningProviders: []

    readonly property var errorDetails: ({
        126: "Authentication was cancelled in the system dialog.",
        127: "pkexec could not start the privileged package operation.",
        1: "pacman could not complete the transaction. Check the package database and network.",
        2: "pacman reported a transaction error. Check the reported package details."
    })

    function packageNames(provider) {
        if (!provider)
            return []
        if (provider.packages)
            return provider.packages.map(item => typeof item === "string" ? item : item.name)
                .filter(name => !!name)
        return provider.packageName
            ? provider.packageName.split(/\s+/).filter(name => name.length > 0) : []
    }

    function packageLabels(providerId) {
        return packageNames(ModuleRegistry.provider(providerId)).join(", ")
    }

    function installPlan(providerId) {
        const names = packageNames(ModuleRegistry.provider(providerId))
        const items = names.map(name => Object.assign({ name: name }, packageStates[name] || {}))
        const repo = items.filter(item => item.source === "Arch repository")
        const aur = items.filter(item => String(item.source || "").startsWith("AUR"))
        const unknown = items.filter(item => item.source === "Unavailable" || !item.checked)
        return { items: items, repo: repo, aur: aur, unknown: unknown,
            source: unknown.length ? "Unavailable"
                : aur.length && repo.length ? "Arch repository + AUR · " + aurHelper
                : aur.length ? "AUR · " + aurHelper
                : repo.length ? "Arch repository" : "Unavailable" }
    }

    function allPackageNames() {
        const names = []
        for (const provider of ModuleRegistry.providers) {
            for (const name of packageNames(provider)) {
                if (names.indexOf(name) === -1)
                    names.push(name)
            }
        }
        return names
    }

    function refresh() {
        if (probing) {
            refreshAgain = true
            return
        }
        probing = true
        hasProbed = false
        pendingToolChecks = 0
        probeQueue = []
        packageStates = ({})
        aurHelper = ""
        paruAvailable = false
        yayAvailable = false
        terminal = ""
        polkitAgentAvailable = false
        pacmanTool.command = ["which", "pacman"]
        pkexecTool.command = ["which", "pkexec"]
        paruTool.command = ["which", "paru"]
        yayTool.command = ["which", "yay"]
        psTool.command = ["ps", "-eo", "args="]
        pendingToolChecks = 11
        pacmanTool.running = true
        pkexecTool.running = true
        paruTool.running = true
        yayTool.running = true
        psTool.running = true
        for (let i = 0; i < terminalTools.count; ++i) {
            const tool = terminalTools.objectAt(i)
            tool.command = ["which", tool.modelData]
            tool.running = true
        }
    }

    function toolFinished(name, found) {
        if (name === "pacman") pacmanAvailable = found
        if (name === "pkexec") pkexecAvailable = found
        if (name === "paru") paruAvailable = found
        if (name === "yay") yayAvailable = found
        if (name === "ps" && found) {
            polkitAgentAvailable = agentInProcessList(psStdout.text)
            runningProviders = providersInProcessList(psStdout.text)
        }
        if (["foot", "kitty", "alacritty", "wezterm", "konsole", "xterm"].indexOf(name) !== -1
                && found && !terminal)
            terminal = name
        pendingToolChecks--
        if (pendingToolChecks > 0)
            return

        aurHelper = paruAvailable ? "paru" : yayAvailable ? "yay" : ""

        if (!pacmanAvailable) {
            probing = false
            hasProbed = true
            packageStates = ({})
            if (checkingInstallResult)
                finishInstallAfterRefresh()
            return
        }
        const jobs = []
        for (const name of allPackageNames()) {
            jobs.push({ kind: "installed", packageName: name, args: ["pacman", "-Q", name] })
        }
        probeQueue = jobs
        runNextProbe()
    }

    function agentInProcessList(value) {
        const lines = String(value).split(/\r?\n/).map(item => item.trim().toLowerCase())
        const expected = [
            "hyprpolkitagent", "polkit-gnome-authentication-agent-1",
            "polkit-kde-authentication-agent-1", "lxqt-policykit-agent",
            "lxqt-policykit", "mate-polkit", "polkit-mate-authentication-agent-1",
            "xfce-polkit", "polkit-efl-authentication-agent-1"
        ]
        return expected.some(name => lines.some(line => line.includes(name)))
    }

    function providersInProcessList(value) {
        const executables = String(value).split(/\r?\n/).map(line => {
            const first = line.trim().split(/\s+/)[0] || ""
            return first.split("/").pop().toLowerCase()
        })
        return ModuleRegistry.providers.filter(provider => !provider.builtIn
            && (provider.processNames || []).some(name =>
                executables.indexOf(String(name).toLowerCase()) !== -1))
            .map(provider => provider.id)
    }

    function isRunning(providerId) {
        return runningProviders.indexOf(providerId) !== -1
    }

    function setManagedRunning(providerId, running) {
        const next = runningProviders.filter(id => id !== providerId)
        if (running)
            next.push(providerId)
        runningProviders = next
    }

    function runNextProbe() {
        if (!probeQueue.length) {
            currentProbe = null
            probing = false
            hasProbed = true
            if (checkingInstallResult) {
                finishInstallAfterRefresh()
            } else if (refreshAgain) {
                refreshAgain = false
                refresh()
            }
            return
        }
        currentProbe = probeQueue.shift()
        packageProbe.exec(currentProbe.args)
    }

    function setPackageState(packageName, values) {
        const next = Object.assign({}, packageStates)
        next[packageName] = Object.assign({
            installed: false,
            available: false,
            source: "Checking…",
            checked: false
        }, next[packageName] || {}, values)
        packageStates = next
    }

    function onProbeExited(code) {
        const task = currentProbe
        if (!task)
            return
        if (task.kind === "installed") {
            setPackageState(task.packageName, { installed: code === 0, checked: true })
            probeQueue.unshift({ kind: "official", packageName: task.packageName,
                args: ["pacman", "-Si", task.packageName] })
        } else if (task.kind === "official") {
            if (code === 0) {
                setPackageState(task.packageName, { available: true, source: "Arch repository" })
            } else if (aurHelper) {
                probeQueue.unshift({ kind: "aur", packageName: task.packageName,
                    args: [aurHelper, "-Si", task.packageName] })
            } else {
                setPackageState(task.packageName, { source: "Unavailable" })
            }
        } else if (task.kind === "aur") {
            setPackageState(task.packageName, code === 0
                ? { available: true, source: "AUR · " + aurHelper }
                : { source: "Unavailable" })
        }
        runNextProbe()
    }

    function stateFor(providerId) {
        const provider = ModuleRegistry.provider(providerId)
        if (!provider)
            return { installed: false, available: false, source: "Unknown", checked: false }
        if (provider.builtIn)
            return { installed: !provider.planned, available: false,
                source: provider.planned ? "Planned" : "Built in", checked: true,
                running: false }
        if (hasProbed && !pacmanAvailable)
            return { installed: false, available: false, source: "pacman unavailable",
                checked: true, running: isRunning(providerId) }
        const names = packageNames(provider)
        if (!names.length)
            return { installed: false, available: false, source: "Unavailable", checked: true }
        const states = names.map(name => packageStates[name] || ({ checked: false,
            installed: false, available: false, source: "Checking…" }))
        return {
            installed: states.every(item => item.installed),
            available: states.every(item => item.available),
            checked: states.every(item => item.checked),
            running: isRunning(providerId),
            source: states.map(item => item.source).filter((item, index, all) => all.indexOf(item) === index).join(" · ")
        }
    }

    function canInstall(providerId) {
        const provider = ModuleRegistry.provider(providerId)
        const state = stateFor(providerId)
        if (!provider || !provider.supportsInstall || provider.builtIn || provider.planned
                || state.installed || !state.available)
            return false
        const plan = installPlan(providerId)
        if (plan.aur.length)
            return !!aurHelper && !!terminal && !plan.unknown.length
        if (plan.repo.length === packageNames(provider).length)
            return pacmanAvailable && pkexecAvailable && polkitAgentAvailable && !!terminal
        return false
    }

    function requestInstall(providerId) {
        const provider = ModuleRegistry.provider(providerId)
        installProviderId = providerId
        if (!provider || !canInstall(providerId)) {
            const plan = installPlan(providerId)
            errorMessage = !plan.aur.length && pacmanAvailable && !polkitAgentAvailable
                ? "Administrator authentication is unavailable because no Polkit authentication agent is running. Start the session agent, then refresh package status."
                : !terminal ? "No supported terminal is available for a safe interactive package operation."
                : !pkexecAvailable && !plan.aur.length ? "pkexec is unavailable for official repository operations."
                : "This package is unavailable or has no safe installer on this system."
            installState = "failed"
            return false
        }
        installState = "waiting-confirmation"
        installOperation = "install"
        installOutput = ""
        errorMessage = ""
        return true
    }

    function canUninstall(providerId) {
        const provider = ModuleRegistry.provider(providerId)
        if (!provider || !provider.supportsUninstall || !stateFor(providerId).installed
                || ModuleManager.isActive(providerId)) return false
        if (!terminal) return false
        const plan = installPlan(providerId)
        if (!plan.aur.length && (!pkexecAvailable || !polkitAgentAvailable)) return false
        return !ModuleRegistry.softwareProviders(provider.softwareId).some(item =>
            item.id !== providerId && ModuleManager.isActive(item.id))
    }

    function requestUninstall(providerId) {
        const provider = ModuleRegistry.provider(providerId)
        installProviderId = providerId
        installOperation = "uninstall"
        if (!provider || !canUninstall(providerId)) {
            errorMessage = "Switch to a safe provider first. Shared active capabilities keep this package in use."
            installState = "failed"
            return false
        }
        installState = "waiting-confirmation"
        installOutput = ""
        errorMessage = ""
        return true
    }

    function cancelInstall() {
        if (installState === "waiting-confirmation") {
            installState = "idle"
            installProviderId = ""
        }
    }

    function confirmInstall() {
        const provider = ModuleRegistry.provider(installProviderId)
        const installing = installOperation === "install"
        if (!provider || (installing ? !canInstall(installProviderId) : !canUninstall(installProviderId))) {
            installState = "failed"
            errorMessage = "Package availability or system authorization changed. Refresh and try again."
            return false
        }
        installOutput = ""
        errorMessage = ""
        installExitCode = -1
        const packages = packageNames(provider)
        if (!installing) {
            const plan = installPlan(installProviderId)
            const command = plan.aur.length
                ? [aurHelper, "-R", ...packages]
                : ["pkexec", "/usr/bin/pacman", "-R", ...packages]
            installState = "authenticating"
            packageTerminalProcess.exec(terminalCommand(command))
            return true
        }
        const plan = installPlan(installProviderId)
        if (plan.aur.length) {
            installState = "authenticating"
            const command = [aurHelper, "-S", "--needed", ...packages]
            packageTerminalProcess.exec(terminalCommand(command))
        } else if (plan.repo.length === packages.length) {
            // Keep pacman's safety prompts available in a real terminal. pkexec
            // still delegates credentials to the active system Polkit agent.
            installState = "authenticating"
            const command = ["pkexec", "/usr/bin/pacman", "-S", "--needed", ...packages]
            packageTerminalProcess.exec(terminalCommand(command))
        }
        return true
    }

    function terminalCommand(command) {
        switch (terminal) {
        case "foot": return ["foot", "-e", ...command]
        case "kitty": return ["kitty", "--", ...command]
        case "alacritty": return ["alacritty", "-e", ...command]
        case "wezterm": return ["wezterm", "start", "--always-new-process", "--", ...command]
        case "konsole": return ["konsole", "-e", ...command]
        default: return ["xterm", "-e", ...command]
        }
    }

    function consumeOutput(text) {
        const line = String(text).trim()
        if (!line)
            return
        installOutput = (installOutput ? installOutput + "\n" : "") + line
        if (installState === "authenticating")
            installState = "installing"
    }

    function classifyFailure(code, output) {
        diagnosticTimestamp = new Date().toISOString()
        const detail = String(output || "").toLowerCase()
        const aurInstall = installPlan(installProviderId).aur.length > 0
        if (aurInstall && installOperation === "install")
            return code === 0
                ? "The AUR helper finished, but the requested package is not installed. It may have been skipped or cancelled."
                : "AUR helper installation exited with code " + code + ".\n"
                    + String(output || "Check the terminal output for the build or package error.")
        if (code === 126)
            return "Authentication was cancelled in the system dialog."
        if (code === 127)
            if (detail.includes("agent") || !polkitAgentAvailable)
                return "The Polkit authentication agent could not authorize the package operation."
        if (code === 127)
            return polkitAgentAvailable
                ? "pkexec could not start pacman. Check the Polkit and pacman installation."
                : "No graphical Polkit authentication agent is running."
        if (detail.includes("unable to lock database") || detail.includes("could not lock database"))
            return "pacman's database is locked by another package operation."
        if (detail.includes("target not found") || detail.includes("was not found in sync db"))
            return "The package is no longer available in the enabled repositories."
        if (detail.includes("failed retrieving") || detail.includes("could not resolve")
                || detail.includes("failed to synchronize"))
            return "pacman could not reach or synchronize the package repositories."
        if (detail.includes("not authorized") || detail.includes("not authorized to perform"))
            return "The current user is not authorized to install system packages."
        if (code === 0)
            return "pacman exited successfully, but the requested package was not found in the installed database."
        const operation = installOperation === "uninstall" ? "removal" : "installation"
        const base = errorDetails[code] || ("Package " + operation + " exited with code " + code + ".")
        const useful = String(output || "").split(/\r?\n/).map(line => line.trim())
            .filter(line => line.length > 0).slice(-3).join("\n")
        const terminalHint = "Review the package-manager terminal for its full diagnostic output."
        return (useful ? base + "\n" + useful + "\n" : base + "\n") + terminalHint
    }

    function afterInstallProcess(code, output) {
        installExitCode = code
        diagnosticTimestamp = new Date().toISOString()
        installOutput = String(output || "").trim()
        installState = "verifying"
        checkingInstallResult = true
        refresh()
    }

    function finishInstallAfterRefresh() {
        checkingInstallResult = false
        const state = stateFor(installProviderId)
        const operationSucceeded = installOperation === "install" ? state.installed : !state.installed
        if (operationSucceeded) {
            installState = "success"
            errorMessage = ""
        } else {
            installState = "failed"
            errorMessage = classifyFailure(installExitCode, installOutput)
        }
        if (refreshAgain) {
            refreshAgain = false
            refresh()
        }
    }

    Process {
        id: pacmanTool
        onExited: (code) => root.toolFinished("pacman", code === 0)
    }
    Process {
        id: pkexecTool
        onExited: (code) => root.toolFinished("pkexec", code === 0)
    }
    Process {
        id: paruTool
        onExited: (code) => root.toolFinished("paru", code === 0)
    }
    Process {
        id: yayTool
        onExited: (code) => root.toolFinished("yay", code === 0)
    }
    Process {
        id: psTool
        stdout: StdioCollector { id: psStdout }
        onExited: (code) => root.toolFinished("ps", code === 0)
    }
    Instantiator {
        id: terminalTools
        model: ["foot", "kitty", "alacritty", "wezterm", "konsole", "xterm"]
        delegate: Process {
            required property string modelData
            onExited: (code) => root.toolFinished(modelData, code === 0)
        }
    }
    Process {
        id: packageProbe
        stdout: StdioCollector { id: probeStdout }
        onExited: (code) => root.onProbeExited(code)
    }
    Process {
        id: installProcess
        stdout: SplitParser { onRead: data => root.consumeOutput(data) }
        stderr: SplitParser { onRead: data => root.consumeOutput(data) }
        onExited: (code) => root.afterInstallProcess(code, root.installOutput)
    }
    Process {
        id: packageTerminalProcess
        onRunningChanged: {
            if (running && root.installState === "authenticating")
                root.installState = "installing"
        }
        onExited: (code) => root.afterInstallProcess(code,
            code === 0 ? "" : "Package operation terminal exited with code " + code)
    }

    Component.onCompleted: refresh()
}
