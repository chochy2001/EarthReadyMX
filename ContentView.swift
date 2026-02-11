import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch gameState.currentPhase {
            case .splash:
                SplashView()
                    .transition(.opacity.combined(with: .scale))
            case .learn:
                LearnView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .simulation:
                SimulationView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .result:
                ResultView()
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            case .checklist:
                ChecklistView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.6), value: gameState.currentPhase)
    }
}
