import Foundation

enum DNSPreset: String, CaseIterable, Identifiable {
    case defaultServers
    case cloudflare
    case google
    case quad9
    case custom

    var id: String { rawValue }

    var servers: [String] {
        switch self {
        case .defaultServers: return []
        case .cloudflare: return ["1.1.1.1", "1.0.0.1"]
        case .google: return ["8.8.8.8", "8.8.4.4"]
        case .quad9: return ["9.9.9.9", "149.112.112.112"]
        case .custom: return []
        }
    }

    var icon: String {
        switch self {
        case .defaultServers: return "bolt.shield.fill"
        case .cloudflare: return "cloud.fill"
        case .google: return "globe.americas.fill"
        case .quad9: return "shield.checkered"
        case .custom: return "slider.horizontal.3"
        }
    }

    var englishName: String {
        switch self {
        case .defaultServers: return "Default"
        case .cloudflare: return "Cloudflare"
        case .google: return "Google"
        case .quad9: return "Quad9"
        case .custom: return "Custom"
        }
    }

    var persianName: String {
        switch self {
        case .defaultServers: return "پیش‌فرض"
        case .cloudflare: return "کلودفلر"
        case .google: return "گوگل"
        case .quad9: return "کواد۹"
        case .custom: return "سفارشی"
        }
    }

    func name(for language: AppLanguage) -> String {
        language == .persian ? persianName : englishName
    }

    static func matchingPreset(
        for servers: [String],
        customPrimary: String = "",
        customSecondary: String = ""
    ) -> DNSPreset? {
        let normalized = servers.map { $0.trimmingCharacters(in: .whitespaces) }

        if normalized.isEmpty || normalized == ["0.0.0.0"] {
            return .defaultServers
        }

        for preset in allCases where preset != .custom {
            if serversMatch(normalized, preset.servers) {
                return preset
            }
        }

        var customServers = [customPrimary.trimmingCharacters(in: .whitespaces)]
        let secondary = customSecondary.trimmingCharacters(in: .whitespaces)
        if !secondary.isEmpty { customServers.append(secondary) }
        if !customPrimary.isEmpty, serversMatch(normalized, customServers) {
            return .custom
        }

        return nil
    }

    private static func serversMatch(_ current: [String], _ preset: [String]) -> Bool {
        guard !preset.isEmpty, current.count == preset.count else { return false }
        return Set(current) == Set(preset)
    }

    var englishDescription: String {
        switch self {
        case .defaultServers: return "System default (DHCP)"
        case .cloudflare: return "Fast & privacy-focused"
        case .google: return "Reliable public DNS"
        case .quad9: return "Security & malware blocking"
        case .custom: return "Enter your own addresses"
        }
    }

    var persianDescription: String {
        switch self {
        case .defaultServers: return "پیش‌فرض سیستم (DHCP)"
        case .cloudflare: return "سریع و متمرکز بر حریم خصوصی"
        case .google: return "DNS عمومی قابل اعتماد"
        case .quad9: return "امنیت و مسدودسازی بدافزار"
        case .custom: return "آدرس‌های خود را وارد کنید"
        }
    }
}

enum DNSValidator {
    static func isValidIPv4(_ input: String) -> Bool {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }

        let parts = trimmed.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 4 else { return false }

        return parts.allSatisfy { part in
            guard let value = Int(part), value >= 0, value <= 255 else { return false }
            return part == String(value) || (part.count > 1 && part.first == "0") == false
        }
    }

    static func isValidIPv6(_ input: String) -> Bool {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard trimmed.contains(":") else { return false }
        return trimmed.split(separator: ":").count >= 3
    }

    static func isValid(_ input: String) -> Bool {
        isValidIPv4(input) || isValidIPv6(input)
    }
}
