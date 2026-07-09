import SwiftUI

/// User-facing color scheme preference persisted in UserDefaults.
///
/// EarthReady ships with a dark visual identity (gradients evoking night
/// and seismic alerts), so the default remains `system` so the OS setting
/// wins. Users who prefer a light interface can opt in from the splash
/// settings menu.
public enum AppearancePreference: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    public static let storageKey = "colorScheme"

    public var id: String { rawValue }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    public var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    public var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}
