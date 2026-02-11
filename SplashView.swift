import SwiftUI

struct SplashView: View {
    @EnvironmentObject var gameState: GameState
    @State private var shakeAmount: CGFloat = 0
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showStats = false
    @State private var showButton = false
    @State private var crackLines: [CrackLine] = []
    @State private var seismographPoints: [CGFloat] = Array(repeating: 0, count: 60)
    @State private var isShaking = false
    @State private var seismographTimer: Timer?

    var body: some View {
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

            VStack(spacing: 24) {
                Spacer()

                SeismographView(points: seismographPoints, isActive: isShaking)
                    .frame(height: 80)
                    .padding(.horizontal, 30)

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

                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .modifier(ShakeEffect(animatableData: shakeAmount))
                }

                if showTitle {
                    VStack(spacing: 8) {
                        Text("EarthReady")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("Know What To Do When The Ground Shakes")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
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
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
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
                                .font(.system(size: 18, weight: .bold, design: .rounded))
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
                }

                Spacer().frame(height: 40)
            }
        }
        .onAppear { startAnimationSequence() }
        .onDisappear {
            seismographTimer?.invalidate()
            seismographTimer = nil
        }
    }

    private func startAnimationSequence() {
        startSeismograph()

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
        }
    }

    private func startSeismograph() {
        seismographTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in
                seismographPoints.removeFirst()
                if isShaking {
                    seismographPoints.append(CGFloat.random(in: -1...1))
                } else {
                    let last = seismographPoints.last ?? 0
                    seismographPoints.append(last * 0.9 + CGFloat.random(in: -0.05...0.05))
                }
            }
        }
    }

    private func generateCracks() {
        let screenWidth: CGFloat = 400
        let screenHeight: CGFloat = 800
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

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.orange)
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: isExpanded ? 11 : 9, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(isExpanded ? nil : 1)
                    .fixedSize(horizontal: false, vertical: isExpanded)
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
    }
}
