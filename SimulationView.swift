import SwiftUI

struct SimulationView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var soundManager: SoundManager
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @State private var currentIndex = 0
    @State private var selectedOption: SimulationOption?
    @State private var showExplanation = false
    @State private var shakeAmount: CGFloat = 0
    @State private var intensity: Double = 0
    @State private var timeRemaining: Double = 15
    @State private var timerActive = false
    @State private var countdownTimer: Timer?
    @State private var sceneShaking = true
    @State private var timedOut = false

    private var currentScenario: SimulationScenario? {
        guard currentIndex < gameState.scenarios.count else { return nil }
        return gameState.scenarios[currentIndex]
    }

    private var answerGiven: Bool {
        selectedOption != nil || timedOut
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
                        VStack(spacing: 12) {
                            if !showExplanation {
                                SceneIllustration(
                                    scenarioIndex: currentIndex,
                                    isShaking: sceneShaking && selectedOption == nil
                                )
                                .modifier(ShakeEffect(
                                    amount: sceneShaking && selectedOption == nil ? 3 : 0,
                                    animatableData: shakeAmount
                                ))
                                .padding(.horizontal, 20)

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
                        .padding(.top, 8)
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
            startTimer()
        }
        .onDisappear {
            soundManager.stopEarthquakeRumble()
            stopTimer()
        }
    }

    private var simulationHeader: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Emergency Simulation")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                        .accessibilityAddTraits(.isHeader)
                    Text("Make the right call")
                        .font(.system(.footnote, design: .rounded, weight: .medium))
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
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .minimumScaleFactor(0.7)
                        .foregroundColor(.white)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Scenario \(currentIndex + 1) of \(gameState.scenarios.count)")
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            HStack(spacing: 16) {
                Label("\(gameState.score) correct", systemImage: "checkmark.circle.fill")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundColor(.green)
                Label("\(gameState.totalQuestions - gameState.score) wrong", systemImage: "xmark.circle.fill")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundColor(.red.opacity(0.7))
                Spacer()
                if selectedOption == nil && !timedOut {
                    CountdownTimerView(timeRemaining: timeRemaining, totalTime: 15)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }

    private func compactScenarioCard(_ scenario: SimulationScenario) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(.body))
                .foregroundColor(.orange)
            Text(scenario.situation)
                .font(.system(.footnote, design: .rounded, weight: .medium))
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
                .font(.system(.largeTitle))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                )
                .accessibilityHidden(true)
            Text(scenario.situation)
                .font(.system(.headline, design: .rounded))
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
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel("Emergency scenario: \(scenario.situation)")
    }

    private func optionButton(_ option: SimulationOption, scenario: SimulationScenario) -> some View {
        Button(action: {
            guard selectedOption == nil else { return }
            stopTimer()
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
                    if timedOut {
                        if option.isCorrect {
                            Image(systemName: "checkmark")
                                .font(.system(.footnote, weight: .bold))
                                .foregroundColor(.white)
                        }
                    } else if let selected = selectedOption {
                        if option.id == selected.id {
                            Image(systemName: option.isCorrect ? "checkmark" : "xmark")
                                .font(.system(.footnote, weight: .bold))
                                .foregroundColor(.white)
                        } else if option.isCorrect {
                            Image(systemName: "checkmark")
                                .font(.system(.footnote, weight: .bold))
                                .foregroundColor(.white)
                        } else if differentiateWithoutColor {
                            Image(systemName: "minus")
                                .font(.system(.footnote, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                }
                Text(option.text)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundColor(optionTextColor(option))
                    .multilineTextAlignment(.leading)
                if differentiateWithoutColor && answerGiven {
                    Spacer()
                    if option.isCorrect {
                        Text("CORRECT")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundColor(.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else if let selected = selectedOption, option.id == selected.id, !option.isCorrect {
                        Text("WRONG")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                } else {
                    Spacer()
                }
            }
            .padding(16)
            .background(optionBackground(option))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        optionBorderColor(option),
                        style: timedOut && !option.isCorrect
                            ? StrokeStyle(lineWidth: 2, dash: [5, 3])
                            : StrokeStyle(lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(selectedOption != nil || timedOut)
        .accessibilityLabel(option.text)
        .accessibilityValue(optionAccessibilityValue(option))
        .accessibilityHint(selectedOption == nil && !timedOut ? "Double tap to select this answer" : "")
    }

    private func optionAccessibilityValue(_ option: SimulationOption) -> String {
        if timedOut {
            return option.isCorrect ? "Correct answer" : ""
        }
        guard let selected = selectedOption else { return "" }
        if option.id == selected.id {
            return option.isCorrect ? "Your answer, correct" : "Your answer, incorrect"
        }
        if option.isCorrect {
            return "Correct answer"
        }
        return ""
    }

    private func explanationCard(_ scenario: SimulationScenario) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if timedOut {
                HStack(spacing: 8) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .foregroundColor(.red)
                    Text("Time's Up!")
                        .font(.system(.callout, design: .rounded, weight: .bold))
                        .foregroundColor(.red)
                }
            }
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Why?")
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(scenario.explanation)
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(timedOut ? Color.red.opacity(0.08) : Color.yellow.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(timedOut ? Color.red.opacity(0.2) : Color.yellow.opacity(0.2), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(timedOut
            ? "Time's up. Explanation: \(scenario.explanation)"
            : "Explanation: \(scenario.explanation)")
    }

    private var continueButton: some View {
        Button(action: {
            if currentIndex + 1 < gameState.scenarios.count {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentIndex += 1
                    selectedOption = nil
                    showExplanation = false
                    shakeAmount = 0
                    timedOut = false
                }
                startTimer()
            } else {
                stopTimer()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.currentPhase = .result
                }
            }
        }) {
            HStack(spacing: 8) {
                Text(currentIndex + 1 < gameState.scenarios.count ? "Next Scenario" : "See Results")
                    .font(.system(.callout, design: .rounded, weight: .bold))
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
        .accessibilityHint(
            currentIndex + 1 < gameState.scenarios.count
                ? "Double tap to go to the next scenario"
                : "Double tap to see your final results"
        )
    }

    // MARK: - Timer Logic

    private func startTimer() {
        timeRemaining = 15
        timerActive = true
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                guard timerActive else { return }
                if timeRemaining > 0 {
                    timeRemaining -= 0.1
                } else {
                    handleTimeout()
                }
            }
        }
    }

    private func stopTimer() {
        timerActive = false
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    private func handleTimeout() {
        guard selectedOption == nil, let scenario = currentScenario else { return }
        stopTimer()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            timedOut = true
            showExplanation = true
            gameState.answerScenario(scenario, correct: false)
        }
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

    // MARK: - Color Helpers

    private func optionCircleColor(_ option: SimulationOption) -> Color {
        if timedOut {
            if option.isCorrect { return .green }
            return Color.white.opacity(0.05)
        }
        guard let selected = selectedOption else { return Color.white.opacity(0.1) }
        if option.isCorrect { return .green }
        if option.id == selected.id && !option.isCorrect { return .red }
        return Color.white.opacity(0.05)
    }

    private func optionTextColor(_ option: SimulationOption) -> Color {
        if timedOut {
            if option.isCorrect { return .green }
            return .white.opacity(0.3)
        }
        guard let selected = selectedOption else { return .white }
        if option.isCorrect { return .green }
        if option.id == selected.id && !option.isCorrect { return .red }
        return .white.opacity(0.3)
    }

    private func optionBackground(_ option: SimulationOption) -> Color {
        if timedOut {
            if option.isCorrect { return Color.green.opacity(0.1) }
            return Color.white.opacity(0.03)
        }
        guard let selected = selectedOption else { return Color.white.opacity(0.06) }
        if option.isCorrect { return Color.green.opacity(0.1) }
        if option.id == selected.id && !option.isCorrect { return Color.red.opacity(0.1) }
        return Color.white.opacity(0.03)
    }

    private func optionBorderColor(_ option: SimulationOption) -> Color {
        if timedOut {
            if option.isCorrect { return Color.green.opacity(0.4) }
            return Color.white.opacity(0.04)
        }
        guard let selected = selectedOption else { return Color.white.opacity(0.08) }
        if option.isCorrect { return Color.green.opacity(0.4) }
        if option.id == selected.id && !option.isCorrect { return Color.red.opacity(0.4) }
        return Color.white.opacity(0.04)
    }
}
