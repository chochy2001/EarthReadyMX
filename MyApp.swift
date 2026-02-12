import SwiftUI

@main
struct MyApp: App {
    @StateObject private var gameState = GameState()
    @StateObject private var hapticManager = HapticManager()
    @StateObject private var soundManager = SoundManager()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var speechManager = SpeechManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
                .environmentObject(hapticManager)
                .environmentObject(soundManager)
                .environmentObject(motionManager)
                .environmentObject(speechManager)
                .preferredColorScheme(.dark)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .background {
                        gameState.saveChecklistState()
                    }
                }
        }
    }
}
