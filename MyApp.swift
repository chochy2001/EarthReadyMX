import SwiftUI

@main
struct MyApp: App {
    @StateObject private var gameState = GameState()
    @StateObject private var hapticManager = HapticManager()
    @StateObject private var soundManager = SoundManager()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var speechManager = SpeechManager()
    @Environment(\.scenePhase) private var scenePhase

    // Persisted color scheme preference. Defaults to "system" so the OS
    // setting wins until the user opts into a forced mode from the splash
    // menu. Replaces the previous hard-coded `.preferredColorScheme(.dark)`
    // which denied light-mode users their setting.
    @AppStorage(AppearancePreference.storageKey) private var schemePreference: String = AppearancePreference.system.rawValue

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
                .environmentObject(hapticManager)
                .environmentObject(soundManager)
                .environmentObject(motionManager)
                .environmentObject(speechManager)
                .preferredColorScheme(AppearancePreference(rawValue: schemePreference)?.colorScheme)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .background {
                        gameState.saveChecklistState()
                    }
                }
        }
    }
}
