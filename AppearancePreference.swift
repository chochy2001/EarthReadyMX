import SwiftUI

/// User-facing color scheme preference persisted in UserDefaults.
///
/// EarthReady ships with a dark visual identity (gradients evoking night
/// and seismic alerts), so the default remains `system` so the OS setting
/// wins. Users who prefer a light interface can opt in from the splash
/// settings menu.
enum AppearancePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    static let storageKey = "colorScheme"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}
