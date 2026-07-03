import AppKit
import Combine
import SwiftUI

@MainActor
final class DNSController: ObservableObject {
    static let shared = DNSController()

    @Published var services: [String] = []
    @Published var selectedService: String = "" {
        didSet {
            guard selectedService != oldValue else { return }
            settings.selectedNetworkService = selectedService
            refreshCurrentDNS()
        }
    }

    @Published var currentDNS: [String] = []
    @Published var isLoading = false
    @Published var statusMessage: String?
    @Published var isError = false

    private let settings = AppSettings.shared
    private var cancellables = Set<AnyCancellable>()

    var l10n: L10n { settings.l10n }

    var matchedPreset: DNSPreset? {
        DNSPreset.matchingPreset(
            for: currentDNS,
            customPrimary: settings.customPrimaryDNS,
            customSecondary: settings.customSecondaryDNS
        )
    }

    var matchedProfile: DNSProfile? {
        DNSProfile.matchingProfile(for: currentDNS, in: settings.savedProfiles)
    }

    var dnsStatus: DNSStatus {
        if currentDNS.isEmpty { return .automatic }
        if let matchedPreset { return .matched(matchedPreset) }
        if let matchedProfile { return .matchedProfile(matchedProfile) }
        return .other
    }

    private init() {
        settings.$selection
            .dropFirst()
            .sink { [weak self] _ in
                self?.refreshCurrentDNS()
            }
            .store(in: &cancellables)

        settings.$savedProfiles
            .dropFirst()
            .sink { [weak self] _ in
                self?.refreshCurrentDNS()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.refreshCurrentDNS()
            }
            .store(in: &cancellables)
    }

    func loadServices() {
        services = DNSManager.listNetworkServices()
        if let saved = settings.selectedNetworkService,
           services.contains(saved) {
            selectedService = saved
        } else if let first = services.first {
            selectedService = first
        }
        refreshCurrentDNS()
    }

    func refreshCurrentDNS() {
        guard !selectedService.isEmpty else {
            currentDNS = []
            return
        }
        currentDNS = DNSManager.getCurrentDNS(for: selectedService)
    }

    var canApply: Bool {
        let servers = settings.targetServers()
        guard let primary = servers.first else { return false }
        guard DNSValidator.isValid(primary) else { return false }
        if servers.count > 1 {
            return DNSValidator.isValid(servers[1])
        }
        return true
    }

    func applyCurrentSelection() async {
        switch settings.selection {
        case .preset(let preset):
            if preset == .custom {
                await applyCustomDNS()
            } else {
                await applyPreset(preset)
            }
        case .profile(let id):
            await applyProfile(id: id)
        }
    }

    func applyCurrentPreset() async {
        await applyCurrentSelection()
    }

    func applyPreset(_ preset: DNSPreset) async {
        settings.selection = .preset(preset)
        guard preset != .custom else { return }

        let servers = preset.servers
        guard !servers.isEmpty else { return }

        await performAction {
            try await DNSManager.setDNS(servers: servers, for: selectedService)
        } successMessage: {
            l10n.dnsApplied(servers)
        }
    }

    func applyProfile(id: UUID) async {
        guard let profile = settings.savedProfiles.first(where: { $0.id == id }) else { return }
        settings.selection = .profile(id)

        let servers = profile.servers
        guard let primary = servers.first, DNSValidator.isValid(primary) else {
            isError = true
            statusMessage = l10n.invalidPrimary
            return
        }
        if servers.count > 1, !DNSValidator.isValid(servers[1]) {
            isError = true
            statusMessage = l10n.invalidSecondary
            return
        }

        await performAction {
            try await DNSManager.setDNS(servers: servers, for: selectedService)
        } successMessage: {
            l10n.dnsApplied(servers)
        }
    }

    func applyCustomDNS() async {
        let servers = settings.targetServers()
        guard let primary = servers.first, DNSValidator.isValid(primary) else {
            isError = true
            statusMessage = l10n.invalidPrimary
            return
        }
        if servers.count > 1, !DNSValidator.isValid(servers[1]) {
            isError = true
            statusMessage = l10n.invalidSecondary
            return
        }

        await performAction {
            try await DNSManager.setDNS(servers: servers, for: selectedService)
        } successMessage: {
            l10n.dnsApplied(servers)
        }
    }

    func resetDNS() async {
        await performAction {
            try await DNSManager.resetToAutomatic(for: selectedService)
        } successMessage: {
            l10n.dnsReset
        }
    }

    private func performAction(
        _ action: () async throws -> Void,
        successMessage: () -> String
    ) async {
        isLoading = true
        isError = false
        statusMessage = nil

        do {
            try await action()
            refreshCurrentDNS()
            statusMessage = successMessage()
        } catch {
            isError = true
            statusMessage = error.localizedDescription
        }

        isLoading = false
    }
}
