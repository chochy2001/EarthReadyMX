import SwiftUI

struct SplashView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var soundManager: SoundManager
    @EnvironmentObject var motionManager: MotionManager
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var shakeAmount: CGFloat = 0
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showStats = false
    @State private var showButton = false
    @State private var crackLines: [CrackLine] = []
    @State private var seismographPoints: [CGFloat] = Array(repeating: 0, count: 60)
    @State private var isShaking = false
    @State private var seismographTimer: Timer?
    @State private var viewSize: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.05, blue: 0.15),
                    Color(red: 0.15, green: 0.05, blue: 0.05),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ForEach(crackLines) { crack in
                CrackShape(points: crack.points)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1.5)
                    .ignoresSafeArea()
            }
            .accessibilityHidden(true)

            VStack(spacing: 24) {
                Spacer()

                SeismographView(points: seismographPoints, isActive: isShaking)
                    .frame(height: 80)
                    .padding(.horizontal, 30)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(
                        isShaking
                            ? "Seismograph showing active earthquake waves"
                            : "Seismograph showing calm readings"
                    )
                    .accessibilityAddTraits(.isImage)

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.orange.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 30,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .glowEffect(color: .orange)
                        .accessibilityHidden(true)

                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .modifier(ShakeEffect(animatableData: reduceMotion ? 0 : shakeAmount))
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("EarthReady app icon, a globe representing the Americas")
                .accessibilityAddTraits(.isImage)

                if showTitle {
                    VStack(spacing: 8) {
                        Text("EarthReady")
                            .font(.system(.largeTitle, design: .rounded, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("Know What To Do When The Ground Shakes")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if showStats {
                    HStack(spacing: 20) {
                        StatBadge(value: "12K+", label: "earthquakes\nper year", icon: "waveform.path.ecg")
                        StatBadge(value: "3 min", label: "to be\nprepared", icon: "clock.fill")
                        StatBadge(value: "70%", label: "survival\nincrease", icon: "heart.fill")
                    }
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if showSubtitle {
                    Text("In 2017, a 7.1 magnitude earthquake struck Mexico City.\n250+ lives were lost. Preparedness makes the difference.")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 40)
                        .transition(.opacity)
                }

                Spacer()

                if showButton {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            gameState.currentPhase = .learn
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "shield.checkered")
                                .font(.title3)
                            Text("Start Learning")
                                .font(.system(.body, design: .rounded, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .orange.opacity(0.4), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 40)
                    .pulseEffect()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .accessibilityLabel("Start Learning")
                    .accessibilityHint("Double tap to begin learning earthquake safety protocols")
                }

                Spacer().frame(height: 40)
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            viewSize = geometry.size
            if !reduceMotion {
                motionManager.startUpdates()
            }
            startAnimationSequence()
        }
        .onDisappear {
            seismographTimer?.invalidate()
            seismographTimer = nil
            motionManager.stopUpdates()
            soundManager.stop()
        }
        } // GeometryReader
    }

    private func startAnimationSequence() {
        if reduceMotion {
            showTitle = true
            showStats = true
            showSubtitle = true
            showButton = true
            startSeismograph()
            hapticManager.playEarthquakeSplash()
            AccessibilityAnnouncement.announceScreenChange(
                "EarthReady. Earthquake preparedness app. Tap Start Learning to begin."
            )
            return
        }

        startSeismograph()

        hapticManager.playEarthquakeSplash()
        soundManager.playSeismicAlert(duration: 2.2)

        withAnimation(.easeInOut(duration: 0.8)) {
            shakeAmount = 6
            isShaking = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { generateCracks() }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showTitle = true }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showStats = true }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeIn(duration: 0.6)) { showSubtitle = true }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            isShaking = false
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showButton = true }
            AccessibilityAnnouncement.announceScreenChange("EarthReady. Earthquake preparedness. Tap Start Learning to begin.")
        }
    }

    private func startSeismograph() {
        seismographTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in
                seismographPoints.removeFirst()
                if motionManager.isMotionAvailable {
                    // Use real accelerometer data from CoreMotion
                    if isShaking {
                        // During earthquake animation: amplify real motion data
                        let motionValue = motionManager.filteredMagnitude
                        let amplified = motionValue * 2.5
                        let clamped = max(-1, min(1, amplified))
                        seismographPoints.append(clamped)
                    } else {
                        // After shake: show subtle live baseline from real motion
                        let motionValue = motionManager.filteredMagnitude * 0.3
                        let last = seismographPoints.last ?? 0
                        let blended = last * 0.7 + motionValue * 0.3
                        seismographPoints.append(blended)
                    }
                } else {
                    // Fallback: synthetic data for Simulator
                    if isShaking {
                        seismographPoints.append(CGFloat.random(in: -1...1))
                    } else {
                        let last = seismographPoints.last ?? 0
                        seismographPoints.append(last * 0.9 + CGFloat.random(in: -0.05...0.05))
                    }
                }
            }
        }
    }

    private func generateCracks() {
        let screenWidth = max(viewSize.width, 300)
        let screenHeight = max(viewSize.height, 600)
        for _ in 0..<5 {
            let start = CGPoint(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight)
            )
            var points = [start]
            var current = start
            for _ in 0..<Int.random(in: 3...8) {
                current = CGPoint(
                    x: current.x + CGFloat.random(in: -40...40),
                    y: current.y + CGFloat.random(in: 10...50)
                )
                points.append(current)
            }
            withAnimation(.easeOut(duration: 0.5)) {
                crackLines.append(CrackLine(points: points))
            }
        }
    }
}

// MARK: - Supporting Views

struct CrackLine: Identifiable, Sendable {
    let id = UUID()
    let points: [CGPoint]
}

struct CrackShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}

struct SeismographView: View {
    let points: [CGFloat]
    let isActive: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geo.size.height / 2))
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height / 2))
                }
                .stroke(Color.green.opacity(0.15), lineWidth: 1)

                Path { path in
                    let width = geo.size.width
                    let height = geo.size.height
                    let mid = height / 2
                    let step = width / CGFloat(max(points.count - 1, 1))
                    let amplitude = height * 0.4

                    guard !points.isEmpty else { return }
                    path.move(to: CGPoint(x: 0, y: mid + points[0] * amplitude))
                    for i in 1..<points.count {
                        path.addLine(to: CGPoint(
                            x: CGFloat(i) * step,
                            y: mid + points[i] * amplitude
                        ))
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            .green.opacity(0.5),
                            isActive ? .red : .green,
                            isActive ? .orange : .green.opacity(0.5)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    @State private var isExpanded = false
    @EnvironmentObject var hapticManager: HapticManager

    private var accessibilityDescription: String {
        let cleanLabel = label.replacingOccurrences(of: "\n", with: " ")
        return "\(value) \(cleanLabel)"
    }

    var body: some View {
        Button(action: {
            hapticManager.playEncouragement()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.orange)
                Text(value)
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(.caption2, weight: .medium))
                    .minimumScaleFactor(0.6)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(isExpanded ? nil : 2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, isExpanded ? 16 : 12)
            .padding(.horizontal, 4)
            .background(Color.white.opacity(isExpanded ? 0.1 : 0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isExpanded ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Double tap to \(isExpanded ? "collapse" : "expand") details")
        .accessibilityAddTraits(.isButton)
    }
}
