import SwiftUI

@main
struct MyApp: App {
    @StateObject private var gameState = GameState()
    @StateObject private var hapticManager = HapticManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
                .environmentObject(hapticManager)
                .preferredColorScheme(.dark)
        }
    }
}
