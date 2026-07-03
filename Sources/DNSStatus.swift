import Foundation

enum DNSStatus: Equatable {
    case automatic
    case matched(DNSPreset)
    case matchedProfile(DNSProfile)
    case other

}
