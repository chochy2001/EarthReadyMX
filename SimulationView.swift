import SwiftUI

struct SimulationView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var soundManager: SoundManager
    @State private var currentIndex = 0
    @State private var selectedOption: SimulationOption?
    @State private var showExplanation = false
    @State private var shakeAmount: CGFloat = 0
    @State private var intensity: Double = 0

    private var currentScenario: SimulationScenario? {
        guard currentIndex < gameState.scenarios.count else { return nil }
        return gameState.scenarios[currentIndex]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08 + intensity * 0.1, green: 0.03, blue: 0.03),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                simulationHeader

                if let scenario = currentScenario {
                    ScrollView {
                        VStack(spacing: 16) {
                            if !showExplanation {
                                scenarioCard(scenario)
                                    .modifier(ShakeEffect(
                                        amount: selectedOption != nil && selectedOption?.isCorrect == false ? 8 : 0,
                                        animatableData: shakeAmount
                                    ))
                            } else {
                                compactScenarioCard(scenario)
                            }

                            ForEach(scenario.options) { option in
                                optionButton(option, scenario: scenario)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }

                    if showExplanation {
                        VStack(spacing: 12) {
                            explanationCard(scenario)
                                .padding(.horizontal, 20)
                            continueButton
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .onAppear {
            hapticManager.playEarthquakeSimulation()
            soundManager.playEarthquakeRumble()
        }
        .onDisappear {
            soundManager.stopEarthquakeRumble()
        }
    }

    private var simulationHeader: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Emergency Simulation")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Make the right call")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 3)
                        .frame(width: 50, height: 50)
                    Circle()
                        .trim(from: 0, to: CGFloat(currentIndex + 1) / CGFloat(gameState.scenarios.count))
                        .stroke(
                            LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    Text("\(currentIndex + 1)/\(gameState.scenarios.count)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            HStack(spacing: 16) {
                Label("\(gameState.score) correct", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.green)
                Label("\(gameState.totalQuestions - gameState.score) wrong", systemImage: "xmark.circle.fill")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.red.opacity(0.7))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }

    private func compactScenarioCard(_ scenario: SimulationScenario) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18))
                .foregroundColor(.orange)
            Text(scenario.situation)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func scenarioCard(_ scenario: SimulationScenario) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                )
            Text(scenario.situation)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func optionButton(_ option: SimulationOption, scenario: SimulationScenario) -> some View {
        Button(action: {
            guard selectedOption == nil else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedOption = option
                showExplanation = true
                gameState.answerScenario(scenario, correct: option.isCorrect)
            }
            if option.isCorrect {
                hapticManager.playCorrectAnswer()
                soundManager.playCorrectSound()
            } else {
                hapticManager.playWrongAnswer()
                soundManager.playIncorrectSound()
                withAnimation(.easeInOut(duration: 0.5)) {
                    shakeAmount = 3
                    intensity = 0.5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation { intensity = 0 }
                }
            }
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(optionCircleColor(option))
                        .frame(width: 32, height: 32)
                    if let selected = selectedOption {
                        if option.id == selected.id {
                            Image(systemName: option.isCorrect ? "checkmark" : "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else if option.isCorrect {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                Text(option.text)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(optionTextColor(option))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(16)
            .background(optionBackground(option))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(optionBorderColor(option), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(selectedOption != nil)
    }

    private func explanationCard(_ scenario: SimulationScenario) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Why?")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            Text(scenario.explanation)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
        )
    }

    private var continueButton: some View {
        Button(action: {
            if currentIndex + 1 < gameState.scenarios.count {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentIndex += 1
                    selectedOption = nil
                    showExplanation = false
                    shakeAmount = 0
                }
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.currentPhase = .result
                }
            }
        }) {
            HStack(spacing: 8) {
                Text(currentIndex + 1 < gameState.scenarios.count ? "Next Scenario" : "See Results")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Image(systemName: currentIndex + 1 < gameState.scenarios.count ? "arrow.right" : "chart.bar.fill")
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Color Helpers

    private func optionCircleColor(_ option: SimulationOption) -> Color {
        guard let selected = selectedOption else { return Color.white.opacity(0.1) }
        if option.isCorrect { return .green }
        if option.id == selected.id && !option.isCorrect { return .red }
        return Color.white.opacity(0.05)
    }

    private func optionTextColor(_ option: SimulationOption) -> Color {
        guard let selected = selectedOption else { return .white }
        if option.isCorrect { return .green }
        if option.id == selected.id && !option.isCorrect { return .red }
        return .white.opacity(0.3)
    }

    private func optionBackground(_ option: SimulationOption) -> Color {
        guard let selected = selectedOption else { return Color.white.opacity(0.06) }
        if option.isCorrect { return Color.green.opacity(0.1) }
        if option.id == selected.id && !option.isCorrect { return Color.red.opacity(0.1) }
        return Color.white.opacity(0.03)
    }

    private func optionBorderColor(_ option: SimulationOption) -> Color {
        guard let selected = selectedOption else { return Color.white.opacity(0.08) }
        if option.isCorrect { return Color.green.opacity(0.4) }
        if option.id == selected.id && !option.isCorrect { return Color.red.opacity(0.4) }
        return Color.white.opacity(0.04)
    }
}
