import SwiftUI

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private enum Keys {
        static let language = "app.language"
        static let selection = "dns.selection"
        static let selectedPreset = "dns.selectedPreset"
        static let customPrimary = "dns.customPrimary"
        static let customSecondary = "dns.customSecondary"
        static let savedProfiles = "dns.savedProfiles"
        static let selectedNetworkService = "dns.selectedNetworkService"
        static let hasCompletedOnboarding = "app.hasCompletedOnboarding"
    }

    @Published var language: AppLanguage {
        didSet {
            guard !isLoadingSettings else { return }
            UserDefaults.standard.set(language.rawValue, forKey: Keys.language)
        }
    }

    @Published var selection: DNSSelection {
        didSet {
            guard !isLoadingSettings else { return }
            persistSelection()
        }
    }

    @Published var savedProfiles: [DNSProfile] {
        didSet {
            guard !isLoadingSettings else { return }
            persistProfiles()
        }
    }

    var selectedPreset: DNSPreset {
        get {
            if case .preset(let preset) = selection { return preset }
            return .custom
        }
        set { selection = .preset(newValue) }
    }

    var selectedProfile: DNSProfile? {
        guard case .profile(let id) = selection else { return nil }
        return savedProfiles.first { $0.id == id }
    }

    @Published var customPrimaryDNS: String {
        didSet {
            guard !isLoadingSettings else { return }
            UserDefaults.standard.set(customPrimaryDNS, forKey: Keys.customPrimary)
        }
    }

    @Published var customSecondaryDNS: String {
        didSet {
            guard !isLoadingSettings else { return }
            UserDefaults.standard.set(customSecondaryDNS, forKey: Keys.customSecondary)
        }
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet {
            guard !isLoadingSettings else { return }
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
        }
    }

    var selectedNetworkService: String? {
        get { UserDefaults.standard.string(forKey: Keys.selectedNetworkService) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.selectedNetworkService) }
    }

    var l10n: L10n { L10n(language: language) }

    private var isLoadingSettings = false

    private init() {
        isLoadingSettings = true

        let langRaw = UserDefaults.standard.string(forKey: Keys.language)
        let onboardingKeyExists = UserDefaults.standard.object(forKey: Keys.hasCompletedOnboarding) != nil

        if let langRaw, let lang = AppLanguage(rawValue: langRaw) {
            language = lang
        } else {
            language = .english
        }

        if let selectionRaw = UserDefaults.standard.string(forKey: Keys.selection) {
            selection = Self.decodeSelection(selectionRaw) ?? .preset(.defaultServers)
        } else {
            let presetRaw = UserDefaults.standard.string(forKey: Keys.selectedPreset) ?? DNSPreset.defaultServers.rawValue
            let preset = DNSPreset(rawValue: presetRaw) ?? .defaultServers
            selection = .preset(preset)
        }

        customPrimaryDNS = UserDefaults.standard.string(forKey: Keys.customPrimary) ?? ""
        customSecondaryDNS = UserDefaults.standard.string(forKey: Keys.customSecondary) ?? ""

        if let data = UserDefaults.standard.data(forKey: Keys.savedProfiles),
           let profiles = try? JSONDecoder().decode([DNSProfile].self, from: data) {
            savedProfiles = profiles
        } else {
            savedProfiles = []
        }

        if onboardingKeyExists {
            hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        } else if langRaw != nil {
            hasCompletedOnboarding = true
            UserDefaults.standard.set(true, forKey: Keys.hasCompletedOnboarding)
        } else {
            hasCompletedOnboarding = false
            UserDefaults.standard.set(false, forKey: Keys.hasCompletedOnboarding)
        }

        isLoadingSettings = false
    }

    func targetServers() -> [String] {
        if case .profile(let id) = selection,
           let profile = savedProfiles.first(where: { $0.id == id }) {
            return profile.servers
        }
        if selectedPreset == .custom {
            var servers = [customPrimaryDNS.trimmingCharacters(in: .whitespaces)]
            let secondary = customSecondaryDNS.trimmingCharacters(in: .whitespaces)
            if !secondary.isEmpty { servers.append(secondary) }
            return servers
        }
        return selectedPreset.servers
    }

    func addProfile(_ profile: DNSProfile) {
        savedProfiles.append(profile)
    }

    func updateProfile(_ profile: DNSProfile) {
        guard let index = savedProfiles.firstIndex(where: { $0.id == profile.id }) else { return }
        savedProfiles[index] = profile
    }

    func deleteProfile(id: UUID) {
        savedProfiles.removeAll { $0.id == id }
        if case .profile(let selectedID) = selection, selectedID == id {
            selection = .preset(.custom)
        }
    }

    private func persistSelection() {
        UserDefaults.standard.set(Self.encodeSelection(selection), forKey: Keys.selection)
        if case .preset(let preset) = selection {
            UserDefaults.standard.set(preset.rawValue, forKey: Keys.selectedPreset)
        }
    }

    private func persistProfiles() {
        guard let data = try? JSONEncoder().encode(savedProfiles) else { return }
        UserDefaults.standard.set(data, forKey: Keys.savedProfiles)
    }

    private static func encodeSelection(_ selection: DNSSelection) -> String {
        switch selection {
        case .preset(let preset): return "preset:\(preset.rawValue)"
        case .profile(let id): return "profile:\(id.uuidString)"
        }
    }

    private static func decodeSelection(_ raw: String) -> DNSSelection? {
        if raw.hasPrefix("profile:") {
            let idString = String(raw.dropFirst("profile:".count))
            guard let id = UUID(uuidString: idString) else { return nil }
            return .profile(id)
        }
        if raw.hasPrefix("preset:") {
            let presetRaw = String(raw.dropFirst("preset:".count))
            guard let preset = DNSPreset(rawValue: presetRaw) else { return nil }
            return .preset(preset)
        }
        if let preset = DNSPreset(rawValue: raw) {
            return .preset(preset)
        }
        return nil
    }
}
