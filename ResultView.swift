import SwiftUI

struct ResultView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var soundManager: SoundManager
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @State private var showScore = false
    @State private var showMessage = false
    @State private var showDetails = false
    @State private var showActions = false
    @State private var animatedScore: Double = 0
    @State private var ringProgress: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.08, blue: 0.05), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if gameState.scorePercentage == 100 && !reduceMotion {
                ParticlesView()
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            }

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 20)

                    if showScore {
                        scoreRing.transition(.scale.combined(with: .opacity))
                    }

                    if showMessage {
                        messageSection.transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if showDetails {
                        responsesSection.transition(.move(edge: .bottom).combined(with: .opacity))
                        takeawaysSection.transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if showActions {
                        actionsSection.transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer().frame(height: 40)
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear { startAnimationSequence() }
    }

    private var scoreRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 12)
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(
                    LinearGradient(colors: scoreColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 4) {
                Text("\(Int(animatedScore))%")
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                    .minimumScaleFactor(0.5)
                    .foregroundColor(.white)
                Text("\(gameState.score)/\(gameState.totalQuestions)")
                    .font(.system(.callout, design: .rounded, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 200, height: 200)
        .padding(10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Score: \(Int(gameState.scorePercentage)) percent, \(gameState.score) out of \(gameState.totalQuestions) correct")
        .accessibilityAddTraits(.isImage)
    }

    private var messageSection: some View {
        VStack(spacing: 8) {
            Text(scoreTitle)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(scoreColors.first ?? .white)
                .accessibilityAddTraits(.isHeader)
            Text(gameState.scoreMessage)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var responsesSection: some View {
        VStack(spacing: 12) {
            Text("Your Responses")
                .font(.system(.body, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            ForEach(Array(gameState.scenarios.enumerated()), id: \.element.id) { index, scenario in
                let wasCorrect = gameState.answeredScenarios[scenario.id] ?? false
                HStack(spacing: 12) {
                    Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(wasCorrect ? .green : .red)
                        .font(.system(.title3))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Scenario \(index + 1)")
                            .font(.system(.footnote, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                        Text(String(scenario.situation.prefix(60)) + "...")
                            .font(.system(.caption))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    Spacer()
                    if differentiateWithoutColor {
                        Text(wasCorrect ? "CORRECT" : "WRONG")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundColor(wasCorrect ? .green : .red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background((wasCorrect ? Color.green : Color.red).opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .padding(14)
                .background((wasCorrect ? Color.green : Color.red).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            (wasCorrect ? Color.green : Color.red).opacity(differentiateWithoutColor ? 0.3 : 0),
                            style: wasCorrect
                                ? StrokeStyle(lineWidth: 1.5)
                                : StrokeStyle(lineWidth: 1.5, dash: [5, 3])
                        )
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Scenario \(index + 1): \(scenario.situation). \(wasCorrect ? "Correct" : "Incorrect")")
            }
        }
        .padding(.horizontal, 20)
    }

    private var takeawaysSection: some View {
        VStack(spacing: 12) {
            Text("Key Takeaways")
                .font(.system(.body, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            takeawayItem(icon: "arrow.down.to.line", color: .orange,
                         title: "Drop, Cover, Hold On",
                         text: "The universal response during any earthquake")
            takeawayItem(icon: "text.bubble.fill", color: .blue,
                         title: "Text, Don't Call",
                         text: "Keep phone lines open for emergencies")
            takeawayItem(icon: "bag.fill", color: .green,
                         title: "Be Prepared",
                         text: "An emergency kit can save your life")
        }
        .padding(.horizontal, 20)
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Progress")
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(sectionsCompletedCount) of 6")
                    .font(.system(.callout, design: .rounded, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .accessibilityLabel("Progress: \(sectionsCompletedCount) of 6 sections completed")

            sectionButton(
                title: "Learn Safety Protocols",
                icon: "shield.lefthalf.filled",
                colors: [.orange, .yellow],
                isCompleted: gameState.isLearnCompleted,
                hint: "Double tap to learn earthquake safety protocols"
            ) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.currentPhase = .learn
                }
            }

            sectionButton(
                title: "Build Your Kit",
                icon: "bag.fill",
                colors: [.green, .mint],
                isCompleted: gameState.isKitCompleted,
                hint: "Double tap to build your emergency kit"
            ) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.currentPhase = .kitBuilder
                }
            }

            sectionButton(
                title: "Practice Drill",
                icon: "figure.walk",
                colors: [.cyan, .blue],
                isCompleted: gameState.isDrillCompleted,
                hint: "Double tap to start a guided earthquake drill"
            ) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.currentPhase = .drill
                }
            }

            sectionButton(
                title: "Seismic Zones",
                icon: "map.fill",
                colors: [.purple, .indigo],
                isCompleted: gameState.isSeismicZonesCompleted,
                hint: "Double tap to explore seismic zones"
            ) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.currentPhase = .seismicZone
                }
            }

            sectionButton(
                title: "Room Safety Scanner",
                icon: "camera.viewfinder",
                colors: [.pink, .red],
                isCompleted: gameState.isRoomScannerCompleted,
                hint: "Double tap to scan a room for safety hazards"
            ) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.currentPhase = .roomScanner
                }
            }

            sectionButton(
                title: "Review Your Checklist",
                icon: "checklist",
                colors: [.yellow, .orange],
                isCompleted: gameState.isChecklistCompleted,
                hint: "Double tap to review your earthquake preparedness checklist"
            ) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.currentPhase = .checklist
                }
            }

            // Start Over
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.resetQuiz()
                    gameState.currentPhase = .splash
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Start Over")
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityHint("Double tap to restart the app from the beginning")
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func sectionButton(
        title: String,
        icon: String,
        colors: [Color],
        isCompleted: Bool,
        hint: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .font(.system(.callout, design: .rounded, weight: .bold))
                if isCompleted {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(.body))
                }
            }
            .foregroundColor(isCompleted ? .black : colors[0])
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                Group {
                    if isCompleted {
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: isCompleted ? 0 : 2
                    )
            )
        }
        .accessibilityLabel("\(title)\(isCompleted ? ", completed" : "")")
        .accessibilityHint(hint)
    }

    private func takeawayItem(icon: String, color: Color, title: String, text: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 40, height: 40)
                Image(systemName: icon).font(.system(.callout)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(.footnote, design: .rounded, weight: .semibold)).foregroundColor(.white)
                Text(text).font(.system(.caption)).foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(text)")
    }

    private var scoreTitle: String {
        let pct = gameState.scorePercentage
        if pct == 100 { return "Outstanding!" }
        if pct >= 80 { return "Well Done!" }
        if pct >= 60 { return "Good Start!" }
        return "Keep Practicing!"
    }

    private var sectionsCompletedCount: Int {
        [
            gameState.isLearnCompleted,
            gameState.isKitCompleted,
            gameState.isDrillCompleted,
            gameState.isSeismicZonesCompleted,
            gameState.isRoomScannerCompleted,
            gameState.isChecklistCompleted
        ].filter { $0 }.count
    }

    private var scoreColors: [Color] {
        let pct = gameState.scorePercentage
        if pct >= 80 { return [.green, .mint] }
        if pct >= 60 { return [.orange, .yellow] }
        return [.red, .orange]
    }

    private func startAnimationSequence() {
        if reduceMotion {
            showScore = true
            showMessage = true
            showDetails = true
            showActions = true
            ringProgress = gameState.scorePercentage / 100
            animatedScore = gameState.scorePercentage
            if gameState.scorePercentage == 100 {
                hapticManager.playPerfectScore()
            } else {
                hapticManager.playEncouragement()
            }
            soundManager.playCelebration(scorePercentage: gameState.scorePercentage)
            AccessibilityAnnouncement.announceScreenChange(
                "Results. You scored \(Int(gameState.scorePercentage)) percent, \(gameState.score) out of \(gameState.totalQuestions) correct. \(scoreTitle)"
            )
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showScore = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 1.2)) {
                ringProgress = gameState.scorePercentage / 100
            }
            let target = gameState.scorePercentage
            let steps = 30
            for i in 0...steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) / Double(steps)) {
                    animatedScore = target * Double(i) / Double(steps)
                }
            }
            if gameState.scorePercentage == 100 {
                hapticManager.playPerfectScore()
            } else {
                hapticManager.playEncouragement()
            }
            soundManager.playCelebration(scorePercentage: gameState.scorePercentage)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showMessage = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showDetails = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showActions = true }
        }
    }
}

// MARK: - Particles

struct ParticlesView: View {
    @State private var particles: [Particle] = []

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    for particle in particles {
                        let age = timeline.date.timeIntervalSince(particle.created)
                        let progress = age / particle.lifetime
                        guard progress < 1 else { continue }

                        let x = particle.startX + particle.velocityX * age
                        let y = particle.startY + particle.velocityY * age + 50 * age * age
                        let opacity = 1 - progress
                        let pSize = particle.size * (1 - progress * 0.5)

                        context.opacity = opacity
                        context.fill(
                            Circle().path(in: CGRect(x: x - pSize / 2, y: y - pSize / 2, width: pSize, height: pSize)),
                            with: .color(particle.color)
                        )
                    }
                }
            }
            .onAppear { generateParticles(width: geometry.size.width) }
        }
    }

    private func generateParticles(width: CGFloat) {
        let actualWidth = max(width, 300)
        let colors: [Color] = [.orange, .yellow, .green, .cyan, .white]
        for _ in 0..<40 {
            particles.append(Particle(
                startX: CGFloat.random(in: 0...actualWidth),
                startY: -20,
                velocityX: CGFloat.random(in: -30...30),
                velocityY: CGFloat.random(in: 20...80),
                size: CGFloat.random(in: 3...8),
                color: colors.randomElement() ?? .orange,
                lifetime: Double.random(in: 2...4),
                created: Date()
            ))
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    let startX: CGFloat
    let startY: CGFloat
    let velocityX: CGFloat
    let velocityY: CGFloat
    let size: CGFloat
    let color: Color
    let lifetime: Double
    let created: Date
}
