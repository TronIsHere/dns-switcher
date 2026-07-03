import SwiftUI

enum AppTheme {
    static let canvas = Color(red: 0.09, green: 0.09, blue: 0.11)
    static let surface = Color(red: 0.14, green: 0.14, blue: 0.16)
    static let softAccent = Color(red: 0.35, green: 0.58, blue: 1.0)
    static let hairline = Color.white.opacity(0.08)
    static let muted = Color.primary.opacity(0.55)

    static func cardShadow(radius: CGFloat = 16, y: CGFloat = 6) -> some View {
        Color.clear.shadow(color: .black.opacity(0.35), radius: radius, x: 0, y: y)
    }
}
