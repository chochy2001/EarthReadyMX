import SwiftUI

struct CompletionView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var soundManager: SoundManager
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showStats = false
    @State private var showActions = false
    @State private var checkmarkScale: CGFloat = 0.3

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.08, blue: 0.02),
                    Color(red: 0.08, green: 0.05, blue: 0.0),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if !reduceMotion {
                ParticlesView()
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            }

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 30)

                    if showIcon {
                        shieldIcon
                            .transition(.scale.combined(with: .opacity))
                    }

                    if showTitle {
                        titleSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if showStats {
                        statsSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if showActions {
                        actionsSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer().frame(height: 40)
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear { startAnimationSequence() }
    }

    // MARK: - Shield Icon

    private var shieldIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.orange.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)

            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(checkmarkScale)
                .shadow(color: .green.opacity(0.4), radius: 20)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Achievement shield with checkmark")
        .accessibilityAddTraits(.isImage)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("You're Earthquake Ready!")
                .font(.system(.title, design: .rounded, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text("You've learned how to protect yourself and others.")
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: 12) {
            Text("Your Journey")
                .font(.system(.body, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: 12) {
                statCard(
                    icon: "brain.head.profile",
                    title: "Quiz Score",
                    value: "\(Int(gameState.scorePercentage))%",
                    color: scoreColor,
                    badge: differentiateWithoutColor ? scoreBadgeText : nil
                )

                statCard(
                    icon: "bag.fill",
                    title: "Kit Builder",
                    value: kitBuilderValue,
                    color: .orange,
                    badge: differentiateWithoutColor ? kitBadgeText : nil
                )
            }

            HStack(spacing: 12) {
                statCard(
                    icon: "figure.walk",
                    title: "Drill",
                    value: gameState.drillCompleted ? "Done" : "Pending",
                    color: gameState.drillCompleted ? .green : .gray,
                    badge: differentiateWithoutColor
                        ? (gameState.drillCompleted ? "COMPLETED" : "PENDING")
                        : nil
                )

                statCard(
                    icon: "checklist",
                    title: "Checklist",
                    value: "\(gameState.checklistPercentage)%",
                    color: gameState.checklistPercentage == 100 ? .green : .orange,
                    badge: differentiateWithoutColor
                        ? "\(gameState.checklistPercentage)% DONE"
                        : nil
                )
            }
        }
        .padding(.horizontal, 20)
    }

    private func statCard(
        icon: String,
        title: String,
        value: String,
        color: Color,
        badge: String?
    ) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(.body))
                    .foregroundColor(color)
            }

            Text(title)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundColor(.gray)

            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)

            if let badge = badge {
                Text(badge)
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundColor(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title): \(value)")
    }

    // MARK: - Computed Properties

    private var scoreColor: Color {
        let pct = gameState.scorePercentage
        if pct >= 80 { return .green }
        if pct >= 60 { return .orange }
        return .red
    }

    private var scoreBadgeText: String {
        let pct = gameState.scorePercentage
        if pct >= 80 { return "GREAT" }
        if pct >= 60 { return "GOOD" }
        return "NEEDS WORK"
    }

    private var kitBuilderValue: String {
        if gameState.kitScore > 0 {
            return "\(gameState.kitScore) pts"
        }
        return "Not played"
    }

    private var kitBadgeText: String {
        if gameState.kitScore > 0 {
            return "\(gameState.kitScore) POINTS"
        }
        return "NOT PLAYED"
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: 12) {
            ShareLink(
                item: "I completed EarthReady and learned earthquake safety protocols!"
            ) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Your Achievement")
                        .font(.system(.callout, design: .rounded, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityHint("Double tap to share your EarthReady achievement")

            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.resetQuiz()
                    gameState.currentPhase = .simulation
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Practice Again")
                        .font(.system(.callout, design: .rounded, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityHint("Double tap to retake the earthquake quiz")

            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.resetAll()
                    gameState.currentPhase = .splash
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "house.fill")
                    Text("Start From Beginning")
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityHint("Double tap to reset all progress and start from scratch")
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Animation Sequence

    private func startAnimationSequence() {
        if reduceMotion {
            showIcon = true
            showTitle = true
            showStats = true
            showActions = true
            checkmarkScale = 1.0
            hapticManager.playPerfectScore()
            soundManager.playCelebration(scorePercentage: 100)
            AccessibilityAnnouncement.announceScreenChange(
                "Congratulations! You've completed EarthReady and learned earthquake safety protocols."
            )
            return
        }

        hapticManager.playPerfectScore()
        soundManager.playCelebration(scorePercentage: 100)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                showIcon = true
                checkmarkScale = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showTitle = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showStats = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showActions = true
            }
            AccessibilityAnnouncement.announceScreenChange(
                "Congratulations! You've completed EarthReady and learned earthquake safety protocols."
            )
        }
    }
}
