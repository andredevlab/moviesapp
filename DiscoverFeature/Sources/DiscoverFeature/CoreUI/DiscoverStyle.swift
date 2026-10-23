import SwiftUI

enum DiscoverStyle {
    static let accent = Color(red: 0.58, green: 0.38, blue: 0.96)
    static let spacing: CGFloat = 20
    static let cornerRadius: CGFloat = 24

    static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.06, green: 0.07, blue: 0.09)
            : Color(red: 0.95, green: 0.95, blue: 0.97)
    }

    static func surface(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.11, green: 0.12, blue: 0.15)
            : .white
    }
}
