import SwiftUI

@main
struct MyApp: App {
    @StateObject private var gameState = GameState()
    @StateObject private var hapticManager = HapticManager()
    @StateObject private var soundManager = SoundManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
                .environmentObject(hapticManager)
                .environmentObject(soundManager)
                .preferredColorScheme(.dark)
        }
    }
}
