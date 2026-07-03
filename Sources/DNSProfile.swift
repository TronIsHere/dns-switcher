import Foundation

struct DNSProfile: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var primaryDNS: String
    var secondaryDNS: String

    init(id: UUID = UUID(), name: String, primaryDNS: String, secondaryDNS: String = "") {
        self.id = id
        self.name = name
        self.primaryDNS = primaryDNS
        self.secondaryDNS = secondaryDNS
    }

    var servers: [String] {
        var result = [primaryDNS.trimmingCharacters(in: .whitespaces)]
        let secondary = secondaryDNS.trimmingCharacters(in: .whitespaces)
        if !secondary.isEmpty { result.append(secondary) }
        return result
    }

    static func matchingProfile(for servers: [String], in profiles: [DNSProfile]) -> DNSProfile? {
        guard !servers.isEmpty else { return nil }
        let normalized = servers.map { $0.trimmingCharacters(in: .whitespaces) }
        return profiles.first { profile in
            serversMatch(normalized, profile.servers)
        }
    }

    private static func serversMatch(_ current: [String], _ target: [String]) -> Bool {
        guard !target.isEmpty, current.count == target.count else { return false }
        return Set(current) == Set(target)
    }
}

enum DNSSelection: Equatable {
    case preset(DNSPreset)
    case profile(UUID)

    var preset: DNSPreset? {
        if case .preset(let preset) = self { return preset }
        return nil
    }

    var profileID: UUID? {
        if case .profile(let id) = self { return id }
        return nil
    }
}
