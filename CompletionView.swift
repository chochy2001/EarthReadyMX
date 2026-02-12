import SwiftUI
import UIKit

// MARK: - Shareable Achievement Card

private struct ShareableAchievementCard: View {
    let learnCompleted: Bool
    let kitCompleted: Bool
    let drillCompleted: Bool
    let seismicCompleted: Bool
    let roomScannerCompleted: Bool
    let checklistCompleted: Bool

    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 16)

            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .green.opacity(0.4), radius: 12)

            Text("You're Earthquake Ready!")
                .font(.system(.title3, design: .rounded, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)

            Text("All 6 sections completed")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    shareStatCard(
                        icon: "shield.lefthalf.filled",
                        title: "Learn",
                        completed: learnCompleted,
                        colors: [.orange, .yellow]
                    )
                    shareStatCard(
                        icon: "bag.fill",
                        title: "Kit",
                        completed: kitCompleted,
                        colors: [.green, .mint]
                    )
                }
                HStack(spacing: 8) {
                    shareStatCard(
                        icon: "figure.walk",
                        title: "Drill",
                        completed: drillCompleted,
                        colors: [.cyan, .blue]
                    )
                    shareStatCard(
                        icon: "map.fill",
                        title: "Seismic",
                        completed: seismicCompleted,
                        colors: [.purple, .indigo]
                    )
                }
                HStack(spacing: 8) {
                    shareStatCard(
                        icon: "camera.viewfinder",
                        title: "Scanner",
                        completed: roomScannerCompleted,
                        colors: [.pink, .red]
                    )
                    shareStatCard(
                        icon: "checklist",
                        title: "Checklist",
                        completed: checklistCompleted,
                        colors: [.yellow, .orange]
                    )
                }
            }
            .padding(.horizontal, 16)

            HStack(spacing: 4) {
                Text("EarthReady")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                Image(systemName: "globe.americas.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer().frame(height: 12)
        }
        .frame(width: 400, height: 540)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.08, blue: 0.02),
                    Color(red: 0.08, green: 0.05, blue: 0.0),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func shareStatCard(
        icon: String,
        title: String,
        completed: Bool,
        colors: [Color]
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(.caption))
                .foregroundColor(completed ? .black : colors[0])
            Text(title)
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundColor(completed ? .black : .white)
            Spacer()
            if completed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(.caption))
                    .foregroundColor(.black)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            Group {
                if completed {
                    LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                } else {
                    Color.white.opacity(0.06)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Completion View

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

                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                gameState.currentPhase = .result
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(.callout, design: .rounded, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        }
                        .accessibilityLabel("Back to results")
                        Spacer()
                    }
                    .padding(.horizontal, 20)

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

            Text("6 of 6 Sections Completed")
                .font(.system(.callout, design: .rounded, weight: .semibold))
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .leading)

            completionRow(
                icon: "shield.lefthalf.filled",
                title: "Learn Safety Protocols",
                completed: gameState.isLearnCompleted,
                colors: [.orange, .yellow]
            )
            completionRow(
                icon: "bag.fill",
                title: "Build Your Kit",
                completed: gameState.isKitCompleted,
                colors: [.green, .mint]
            )
            completionRow(
                icon: "figure.walk",
                title: "Practice Drill",
                completed: gameState.isDrillCompleted,
                colors: [.cyan, .blue]
            )
            completionRow(
                icon: "map.fill",
                title: "Seismic Zones",
                completed: gameState.isSeismicZonesCompleted,
                colors: [.purple, .indigo]
            )
            completionRow(
                icon: "camera.viewfinder",
                title: "Room Safety Scanner",
                completed: gameState.isRoomScannerCompleted,
                colors: [.pink, .red]
            )
            completionRow(
                icon: "checklist",
                title: "Review Your Checklist",
                completed: gameState.isChecklistCompleted,
                colors: [.yellow, .orange]
            )
        }
        .padding(.horizontal, 20)
    }

    private func completionRow(
        icon: String,
        title: String,
        completed: Bool,
        colors: [Color]
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(.body))
                .foregroundColor(completed ? .black : colors[0])
                .frame(width: 24)
            Text(title)
                .font(.system(.callout, design: .rounded, weight: .semibold))
                .foregroundColor(completed ? .black : .white)
            Spacer()
            if completed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(.body))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            Group {
                if completed {
                    LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                } else {
                    Color.white.opacity(0.06)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(completed ? "completed" : "pending")")
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: shareAchievement) {
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
            .accessibilityHint("Double tap to share your EarthReady achievement as an image")

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

    // MARK: - Share Achievement

    private func shareAchievement() {
        let card = ShareableAchievementCard(
            learnCompleted: gameState.isLearnCompleted,
            kitCompleted: gameState.isKitCompleted,
            drillCompleted: gameState.isDrillCompleted,
            seismicCompleted: gameState.isSeismicZonesCompleted,
            roomScannerCompleted: gameState.isRoomScannerCompleted,
            checklistCompleted: gameState.isChecklistCompleted
        )
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3
        guard let image = renderer.uiImage else { return }

        let text = "I scored \(Int(gameState.scorePercentage))% on EarthReady!"
        let activityVC = UIActivityViewController(
            activityItems: [image, text],
            applicationActivities: nil
        )

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        var topVC = rootVC
        while let presented = topVC.presentedViewController { topVC = presented }
        activityVC.popoverPresentationController?.sourceView = topVC.view
        topVC.present(activityVC, animated: true)
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
