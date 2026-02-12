import SwiftUI

// MARK: - Scene Illustration

struct SceneIllustration: View {
    let scenarioIndex: Int
    let isShaking: Bool

    var body: some View {
        ZStack {
            sceneBackground
            sceneElements
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(sceneDescription)
        .accessibilityAddTraits(.isImage)
    }

    private var sceneDescription: String {
        switch scenarioIndex {
        case 0: return "Illustration of a classroom with desks, a blackboard, and windows"
        case 1: return "Illustration of an apartment with a gas stove and windows"
        case 2: return "Illustration of a street between tall buildings"
        case 3: return "Illustration of a person trying to make a phone call"
        case 4: return "Illustration of a damaged building after an earthquake"
        default: return "Earthquake scenario illustration"
        }
    }

    @ViewBuilder
    private var sceneBackground: some View {
        switch scenarioIndex {
        case 0: classroomBackground
        case 1: apartmentBackground
        case 2: streetBackground
        case 3: communicationBackground
        case 4: aftershockBackground
        default: Color.black.opacity(0.3)
        }
    }

    @ViewBuilder
    private var sceneElements: some View {
        switch scenarioIndex {
        case 0: classroomElements
        case 1: apartmentElements
        case 2: streetElements
        case 3: communicationElements
        case 4: aftershockElements
        default: EmptyView()
        }
    }

    // MARK: - Scene 1: Classroom (3rd floor)

    private var classroomBackground: some View {
        LinearGradient(
            colors: [Color(red: 0.2, green: 0.15, blue: 0.1), Color(red: 0.12, green: 0.08, blue: 0.06)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var classroomElements: some View {
        ZStack {
            // Floor
            Rectangle()
                .fill(Color.brown.opacity(0.3))
                .frame(height: 50)
                .offset(y: 65)

            // Blackboard
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.1, green: 0.25, blue: 0.15))
                .frame(width: 160, height: 50)
                .offset(y: -50)

            // Window
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.cyan.opacity(0.3), lineWidth: 2)
                .frame(width: 40, height: 50)
                .overlay(
                    VStack(spacing: 0) {
                        Rectangle().fill(Color.cyan.opacity(0.1)).frame(height: 25)
                        Rectangle().fill(Color.cyan.opacity(0.05)).frame(height: 25)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                )
                .offset(x: -130, y: -45)

            // Desks
            HStack(spacing: 30) {
                deskIcon.offset(y: isShaking ? -3 : 0)
                deskIcon
                deskIcon.offset(y: isShaking ? 2 : 0)
            }
            .offset(y: 20)

            // Hanging lamp
            Image(systemName: "lamp.ceiling.fill")
                .font(.system(size: 22))
                .foregroundColor(.yellow.opacity(0.6))
                .rotationEffect(.degrees(isShaking ? 15 : 0))
                .offset(y: -75)

            // Clock
            Image(systemName: "clock.fill")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.5))
                .offset(x: 100, y: -50)
                .rotationEffect(.degrees(isShaking ? 20 : 0))

            // Person
            Image(systemName: "person.fill")
                .font(.system(size: 28))
                .foregroundColor(.orange)
                .offset(y: 30)

            // Falling books (when shaking)
            if isShaking {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.brown.opacity(0.6))
                    .offset(x: 80, y: 10)
                    .rotationEffect(.degrees(25))
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.brown.opacity(0.5))
                    .offset(x: -90, y: 15)
                    .rotationEffect(.degrees(-15))
            }
        }
    }

    private var deskIcon: some View {
        VStack(spacing: 2) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.brown.opacity(0.5))
                .frame(width: 45, height: 5)
            HStack(spacing: 30) {
                Rectangle().fill(Color.brown.opacity(0.3)).frame(width: 3, height: 20)
                Rectangle().fill(Color.brown.opacity(0.3)).frame(width: 3, height: 20)
            }
        }
    }

    // MARK: - Scene 2: Apartment (gas smell)

    private var apartmentBackground: some View {
        LinearGradient(
            colors: [Color(red: 0.15, green: 0.12, blue: 0.08), Color(red: 0.08, green: 0.06, blue: 0.04)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var apartmentElements: some View {
        ZStack {
            // Floor
            Rectangle()
                .fill(Color(red: 0.2, green: 0.15, blue: 0.1).opacity(0.5))
                .frame(height: 40)
                .offset(y: 70)

            // Window
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.cyan.opacity(0.4), lineWidth: 2)
                .frame(width: 50, height: 55)
                .overlay(
                    Color.cyan.opacity(0.08)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                )
                .offset(x: -100, y: -30)

            // Kitchen counter
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 10)
                .offset(x: 40, y: 20)

            // Stove with flame
            Image(systemName: "flame.fill")
                .font(.system(size: 24))
                .foregroundColor(.orange)
                .offset(x: 40, y: 0)

            // Gas cloud
            Image(systemName: "cloud.fill")
                .font(.system(size: 30))
                .foregroundColor(.yellow.opacity(0.2))
                .offset(x: 20, y: -30)
            Image(systemName: "cloud.fill")
                .font(.system(size: 20))
                .foregroundColor(.yellow.opacity(0.15))
                .offset(x: 60, y: -20)

            // Exclamation
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18))
                .foregroundColor(.red.opacity(0.7))
                .offset(x: 40, y: -55)

            // Door
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.brown.opacity(0.4))
                .frame(width: 30, height: 60)
                .offset(x: -50, y: 10)
            Image(systemName: "door.left.hand.open")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.3))
                .offset(x: -50, y: 10)

            // Person
            Image(systemName: "person.fill")
                .font(.system(size: 28))
                .foregroundColor(.orange)
                .offset(x: -10, y: 35)
        }
    }

    // MARK: - Scene 3: Street between buildings

    private var streetBackground: some View {
        LinearGradient(
            colors: [Color(red: 0.15, green: 0.2, blue: 0.3), Color(red: 0.05, green: 0.05, blue: 0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var streetElements: some View {
        ZStack {
            // Road
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 60)
                .offset(y: 60)

            // Left building
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.25, green: 0.2, blue: 0.18))
                .frame(width: 80, height: 150)
                .offset(x: -120, y: -5)
            windowGrid.offset(x: -120, y: -20)

            // Right building
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.2, green: 0.18, blue: 0.22))
                .frame(width: 70, height: 130)
                .offset(x: 120, y: 5)
            windowGrid.offset(x: 120, y: -10)

            // Street lamp
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 4, height: 60)
                .offset(x: 50, y: 10)
                .rotationEffect(.degrees(isShaking ? 8 : 0), anchor: .bottom)
            Circle()
                .fill(Color.yellow.opacity(0.3))
                .frame(width: 12, height: 12)
                .offset(x: 50, y: -20)

            // Open area/park
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(0.15))
                .frame(width: 80, height: 40)
                .offset(y: 55)
            Image(systemName: "tree.fill")
                .font(.system(size: 18))
                .foregroundColor(.green.opacity(0.5))
                .offset(x: -15, y: 45)
            Image(systemName: "tree.fill")
                .font(.system(size: 14))
                .foregroundColor(.green.opacity(0.4))
                .offset(x: 15, y: 48)

            // Person
            Image(systemName: "figure.walk")
                .font(.system(size: 26))
                .foregroundColor(.orange)
                .offset(y: 30)

            // Falling debris
            if isShaking {
                ForEach(0..<3, id: \.self) { i in
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 6, height: 6)
                        .offset(
                            x: CGFloat([-90, 100, -80][i]),
                            y: CGFloat([-20, -10, 5][i])
                        )
                        .rotationEffect(.degrees(Double(i) * 30))
                }
            }
        }
    }

    private var windowGrid: some View {
        VStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 6) {
                    ForEach(0..<2, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.cyan.opacity(0.15))
                            .frame(width: 14, height: 12)
                    }
                }
            }
        }
    }

    // MARK: - Scene 4: Communication (after earthquake)

    private var communicationBackground: some View {
        LinearGradient(
            colors: [Color(red: 0.08, green: 0.08, blue: 0.15), Color.black],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var communicationElements: some View {
        ZStack {
            // Phone with signal waves
            Image(systemName: "iphone")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.4))
                .offset(y: -10)

            // Signal waves (crossed out for congestion)
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .font(.system(size: 30))
                .foregroundColor(.red.opacity(0.5))
                .offset(y: -50)

            // Text message bubble
            Image(systemName: "message.fill")
                .font(.system(size: 28))
                .foregroundColor(.green.opacity(0.6))
                .offset(x: 80, y: -20)

            // Phone call (crossed)
            Image(systemName: "phone.down.fill")
                .font(.system(size: 22))
                .foregroundColor(.red.opacity(0.5))
                .offset(x: -80, y: -20)

            // Family icons
            HStack(spacing: 20) {
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.orange.opacity(0.6))
                Image(systemName: "person.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.orange.opacity(0.5))
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange.opacity(0.4))
            }
            .offset(y: 50)

            // Question marks
            Text("?")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.yellow.opacity(0.4))
                .offset(x: -60, y: 50)
            Text("?")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.yellow.opacity(0.3))
                .offset(x: 60, y: 55)
        }
    }

    // MARK: - Scene 5: Aftershock (building inspection)

    private var aftershockBackground: some View {
        LinearGradient(
            colors: [Color(red: 0.12, green: 0.1, blue: 0.08), Color(red: 0.06, green: 0.04, blue: 0.03)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var aftershockElements: some View {
        ZStack {
            // Damaged building
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 140, height: 120)
                .offset(y: -10)

            // Cracks on building
            Path { path in
                path.move(to: CGPoint(x: 160, y: 30))
                path.addLine(to: CGPoint(x: 175, y: 60))
                path.addLine(to: CGPoint(x: 168, y: 80))
                path.addLine(to: CGPoint(x: 180, y: 110))
            }
            .stroke(Color.red.opacity(0.4), lineWidth: 2)

            Path { path in
                path.move(to: CGPoint(x: 220, y: 50))
                path.addLine(to: CGPoint(x: 210, y: 75))
                path.addLine(to: CGPoint(x: 225, y: 100))
            }
            .stroke(Color.red.opacity(0.3), lineWidth: 1.5)

            // Windows (some broken)
            HStack(spacing: 15) {
                windowPane(broken: false)
                windowPane(broken: true)
                windowPane(broken: false)
            }
            .offset(y: -30)

            // Rubble at base
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { i in
                    let widths: [CGFloat] = [10, 14, 8, 12, 11]
                    let heights: [CGFloat] = [6, 9, 5, 8, 7]
                    let rotations: [Double] = [-15, 20, -5, 25, -20]
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: widths[i], height: heights[i])
                        .rotationEffect(.degrees(rotations[i]))
                }
            }
            .offset(y: 55)

            // Warning sign
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 22))
                .foregroundColor(.yellow.opacity(0.7))
                .offset(y: -65)

            // Person inspecting
            Image(systemName: "person.fill")
                .font(.system(size: 26))
                .foregroundColor(.orange)
                .offset(x: -80, y: 30)

            // Aftershock wave indicator
            if isShaking {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.5))
                    .offset(y: 70)
            }
        }
    }

    private func windowPane(broken: Bool) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.cyan.opacity(broken ? 0.05 : 0.12))
                .frame(width: 20, height: 18)
            if broken {
                Path { path in
                    path.move(to: CGPoint(x: 2, y: 2))
                    path.addLine(to: CGPoint(x: 18, y: 16))
                    path.move(to: CGPoint(x: 16, y: 3))
                    path.addLine(to: CGPoint(x: 5, y: 15))
                }
                .stroke(Color.red.opacity(0.4), lineWidth: 1)
                .frame(width: 20, height: 18)
            }
            Rectangle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .frame(width: 20, height: 18)
        }
    }
}

// MARK: - Countdown Timer

struct CountdownTimerView: View {
    let timeRemaining: Double
    let totalTime: Double
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    private var progress: Double {
        guard totalTime > 0 else { return 0 }
        return max(0, timeRemaining / totalTime)
    }

    private var urgencyColor: Color {
        if progress > 0.5 { return .green }
        if progress > 0.25 { return .yellow }
        return .red
    }

    private var urgencyIcon: String {
        if progress > 0.5 { return "timer" }
        if progress > 0.25 { return "exclamationmark.circle" }
        return "exclamationmark.triangle.fill"
    }

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 3)
                    .frame(width: 32, height: 32)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(urgencyColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))
                Image(systemName: differentiateWithoutColor ? urgencyIcon : "timer")
                    .font(.system(.caption))
                    .foregroundColor(urgencyColor)
            }
            Text("\(Int(timeRemaining))s")
                .font(.system(.footnote, design: .rounded, weight: .bold))
                .minimumScaleFactor(0.7)
                .foregroundColor(urgencyColor)
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int(timeRemaining)) seconds remaining")
        .accessibilityValue(progress > 0.5 ? "Plenty of time" : progress > 0.25 ? "Time is running low" : "Almost out of time")
    }
}
