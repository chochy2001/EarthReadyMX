import SwiftUI

/// Lightweight sheet shown from the splash screen that lets the user pick
/// between system, light, and dark color schemes.
///
/// Writes the choice through `@AppStorage` bound to
/// ``AppearancePreference/storageKey``; the app root reads the same key
/// and applies `.preferredColorScheme`, so the change is instant.
struct AppearanceSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppearancePreference.storageKey) private var schemePreference: String = AppearancePreference.system.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $schemePreference) {
                        ForEach(AppearancePreference.allCases) { option in
                            Label(option.label, systemImage: option.iconName)
                                .tag(option.rawValue)
                        }
                    } label: {
                        Text("Color scheme")
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("System follows your device setting. EarthReady was designed for dark mode, but works in light too.")
                }
            }
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
