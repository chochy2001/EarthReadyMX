import SwiftUI

struct ResultView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var soundManager: SoundManager
    @Environment(\.accessibilityReduceMotion) var reduceMotion
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
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("\(gameState.score)/\(gameState.totalQuestions)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
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
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(scoreColors.first ?? .white)
            Text(gameState.scoreMessage)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var responsesSection: some View {
        VStack(spacing: 12) {
            Text("Your Responses")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            ForEach(Array(gameState.scenarios.enumerated()), id: \.element.id) { index, scenario in
                let wasCorrect = gameState.answeredScenarios[scenario.id] ?? false
                HStack(spacing: 12) {
                    Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(wasCorrect ? .green : .red)
                        .font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Scenario \(index + 1)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        Text(String(scenario.situation.prefix(60)) + "...")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                .padding(14)
                .background((wasCorrect ? Color.green : Color.red).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Scenario \(index + 1): \(wasCorrect ? "Correct" : "Incorrect")")
            }
        }
        .padding(.horizontal, 20)
    }

    private var takeawaysSection: some View {
        VStack(spacing: 12) {
            Text("Key Takeaways")
                .font(.system(size: 18, weight: .bold, design: .rounded))
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
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.reset()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Start Over")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityHint("Double tap to restart the app from the beginning")

            Text("Share this app to help others be prepared.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
    }

    private func takeawayItem(icon: String, color: Color, title: String, text: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 40, height: 40)
                Image(systemName: icon).font(.system(size: 16)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundColor(.white)
                Text(text).font(.system(size: 12, weight: .regular)).foregroundColor(.gray)
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
        .onAppear { generateParticles() }
    }

    private func generateParticles() {
        let colors: [Color] = [.orange, .yellow, .green, .cyan, .white]
        for _ in 0..<40 {
            particles.append(Particle(
                startX: CGFloat.random(in: 0...400),
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
