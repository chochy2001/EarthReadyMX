import SwiftUI

// MARK: - Drill Phase

enum DrillPhase: Int, CaseIterable, Sendable {
    case briefing
    case alert
    case drop
    case cover
    case holdOn
    case shakingStops
    case check
    case evacuate
    case rallyPoint
    case complete

    var title: String {
        switch self {
        case .briefing: return "Preparation"
        case .alert: return "Seismic Alert!"
        case .drop: return "DROP!"
        case .cover: return "COVER!"
        case .holdOn: return "HOLD ON!"
        case .shakingStops: return "Shaking Stopped"
        case .check: return "Check Hazards"
        case .evacuate: return "Evacuate"
        case .rallyPoint: return "Rally Point"
        case .complete: return "Drill Complete!"
        }
    }

    var icon: String {
        switch self {
        case .briefing: return "clock.badge.checkmark"
        case .alert: return "exclamationmark.triangle.fill"
        case .drop: return "arrow.down.to.line"
        case .cover: return "shield.fill"
        case .holdOn: return "hand.raised.fill"
        case .shakingStops: return "waveform.path.ecg"
        case .check: return "eye.fill"
        case .evacuate: return "figure.walk"
        case .rallyPoint: return "mappin.and.ellipse"
        case .complete: return "checkmark.seal.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .briefing: return .cyan
        case .alert: return .red
        case .drop: return .orange
        case .cover: return .yellow
        case .holdOn: return .orange
        case .shakingStops: return .green
        case .check: return .yellow
        case .evacuate: return .cyan
        case .rallyPoint: return .green
        case .complete: return .mint
        }
    }

    var instruction: String {
        switch self {
        case .briefing:
            return "Earthquake drill. Prepare your body and mind. Identify the nearest safe spot."
        case .alert:
            return "Seismic alert activated. You have seconds to act. Move to the nearest safe spot."
        case .drop:
            return "Drop! Get on your knees to avoid falling during the earthquake."
        case .cover:
            return "Cover! Protect your head and neck. Get under a sturdy table."
        case .holdOn:
            return "Hold on! Grip the table firmly. Do not let go."
        case .shakingStops:
            return "The shaking has stopped. Stay calm. Do not stand up yet."
        case .check:
            return "Check for hazards. Look for gas leaks, downed wires, and structural damage."
        case .evacuate:
            return "Evacuate calmly using the safest route. Do not use elevators. Help others if you can."
        case .rallyPoint:
            return "Head to the rally point. Confirm everyone is present and safe."
        case .complete:
            return "Drill completed successfully. Remember to practice regularly."
        }
    }

    var holdOnSecondInstruction: String {
        "Hold your position. The earthquake continues. Protect your head."
    }

    var holdOnThirdInstruction: String {
        "Keep holding on. It will be over soon."
    }

    var duration: TimeInterval {
        switch self {
        case .briefing: return 10
        case .alert: return 8
        case .drop: return 8
        case .cover: return 10
        case .holdOn: return 20
        case .shakingStops: return 5
        case .check: return 10
        case .evacuate: return 8
        case .rallyPoint: return 5
        case .complete: return 6
        }
    }
}

// MARK: - Drill View

struct DrillView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var soundManager: SoundManager
    @EnvironmentObject var speechManager: SpeechManager
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.scenePhase) var scenePhase

    @State private var currentPhase: DrillPhase = .briefing
    @State private var timeInPhase: TimeInterval = 0
    @State private var totalElapsed: TimeInterval = 0
    @State private var isActive = false
    @State private var isPaused = false
    @State private var drillTimer: Timer?
    @State private var countdownValue: Int = 3
    @State private var showCountdown = true
    @State private var drillStopped = false
    @State private var shakeAmount: CGFloat = 0
    @State private var currentInstructionText: String = ""
    @State private var hasAppeared = false

    private var totalDrillDuration: TimeInterval {
        DrillPhase.allCases.reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        ZStack {
            backgroundGradient

            if drillStopped {
                drillStoppedView
            } else if currentPhase == .complete && !speechManager.isSpeaking {
                drillCompleteView
            } else {
                activeDrillView
            }
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            AccessibilityAnnouncement.announceScreenChange(
                "Emergency drill started. Follow the voice instructions."
            )
            startCountdown()
        }
        .onDisappear {
            cleanupDrill()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background && isActive {
                pauseDrill()
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: backgroundColors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: currentPhase)
    }

    private var backgroundColors: [Color] {
        switch currentPhase {
        case .alert, .drop:
            return [Color(red: 0.15, green: 0.02, blue: 0.02), Color.black]
        case .cover, .holdOn:
            return [Color(red: 0.12, green: 0.05, blue: 0.0), Color.black]
        case .complete:
            return [Color(red: 0.02, green: 0.1, blue: 0.05), Color.black]
        default:
            return [Color(red: 0.05, green: 0.05, blue: 0.1), Color.black]
        }
    }

    // MARK: - Active Drill View

    private var activeDrillView: some View {
        VStack(spacing: 0) {
            if showCountdown {
                countdownView
            } else if isPaused {
                pausedView
            } else {
                drillContent
            }
        }
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Countdown

    private var countdownView: some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        cleanupDrill()
                        gameState.currentPhase = .result
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundColor(.orange)
                }
                .accessibilityLabel("Back")
                .accessibilityHint("Return to results screen")
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()

            Text("Get Ready")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            Text("\(countdownValue)")
                .font(.system(.largeTitle, design: .rounded, weight: .black))
                .foregroundColor(.orange)
                .scaleEffect(reduceMotion ? 1.0 : 1.2)
                .animation(
                    reduceMotion ? .none : .easeOut(duration: 0.3),
                    value: countdownValue
                )
                .accessibilityLabel("\(countdownValue) seconds to start")

            Text("Drill begins in \(countdownValue)...")
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundColor(.gray)

            Spacer()

            stopButton
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
        }
    }

    // MARK: - Paused View

    private var pausedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "pause.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.orange)
                .accessibilityHidden(true)

            Text("Drill Paused")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            Text("Phase: \(currentPhase.title)")
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundColor(.gray)

            Button(action: {
                resumeDrill()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("Resume Drill")
                        .font(.system(.callout, design: .rounded, weight: .bold))
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
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
            .accessibilityHint("Double tap to resume the drill")

            Spacer()

            stopButton
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
        }
    }

    // MARK: - Drill Content

    private var drillContent: some View {
        VStack(spacing: 0) {
            phaseProgressDots
                .padding(.top, 16)
                .padding(.horizontal, 20)

            Spacer()

            phaseIcon
                .padding(.bottom, 12)

            phaseTitleView
                .padding(.bottom, 8)

            instructionView
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

            phaseTimerBar
                .padding(.horizontal, 40)
                .padding(.bottom, 8)

            totalTimeLabel
                .padding(.bottom, 16)

            Spacer()

            stopButton
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
        }
    }

    // MARK: - Phase Progress Dots

    private var phaseProgressDots: some View {
        HStack(spacing: 6) {
            ForEach(DrillPhase.allCases, id: \.rawValue) { phase in
                Circle()
                    .fill(dotColor(for: phase))
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Phase \(currentPhase.rawValue + 1) of \(DrillPhase.allCases.count): \(currentPhase.title)")
    }

    private func dotColor(for phase: DrillPhase) -> Color {
        if phase.rawValue < currentPhase.rawValue {
            return .green
        } else if phase == currentPhase {
            return currentPhase.iconColor
        } else {
            return Color.white.opacity(0.15)
        }
    }

    // MARK: - Phase Icon

    private var phaseIcon: some View {
        ZStack {
            Circle()
                .fill(currentPhase.iconColor.opacity(0.15))
                .frame(width: 120, height: 120)

            Circle()
                .stroke(currentPhase.iconColor.opacity(0.3), lineWidth: 2)
                .frame(width: 120, height: 120)

            Image(systemName: currentPhase.icon)
                .font(.system(size: 50))
                .foregroundColor(currentPhase.iconColor)
                .modifier(
                    ShakeEffect(
                        amount: shouldShake ? 4 : 0,
                        animatableData: shakeAmount
                    )
                )
        }
        .shadow(color: currentPhase.iconColor.opacity(0.3), radius: 20)
        .accessibilityHidden(true)
    }

    private var shouldShake: Bool {
        !reduceMotion && (
            currentPhase == .alert ||
            currentPhase == .drop ||
            currentPhase == .cover ||
            currentPhase == .holdOn
        )
    }

    // MARK: - Phase Title

    private var phaseTitleView: some View {
        Text(currentPhase.title)
            .font(.system(.title, design: .rounded, weight: .black))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Instruction View

    private var instructionView: some View {
        Text(highlightedInstruction)
            .font(.system(.body, design: .rounded, weight: .medium))
            .foregroundColor(.white.opacity(0.85))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .frame(minHeight: 60)
            .accessibilityLabel(currentInstructionText)
    }

    private var highlightedInstruction: AttributedString {
        let text = currentInstructionText
        var attributed = AttributedString(text)

        if let range = speechManager.currentWordRange,
           speechManager.isSpeaking,
           range.location != NSNotFound,
           range.location + range.length <= text.count {
            let nsString = text as NSString
            let word = nsString.substring(with: range)

            if let attrRange = attributed.range(of: word) {
                attributed[attrRange].foregroundColor = currentPhase.iconColor
                attributed[attrRange].font = .system(.body, design: .rounded, weight: .bold)
            }
        }

        return attributed
    }

    // MARK: - Phase Timer Bar

    private var phaseTimerBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.08))

                RoundedRectangle(cornerRadius: 4)
                    .fill(currentPhase.iconColor.opacity(0.6))
                    .frame(
                        width: geometry.size.width * phaseProgress
                    )
                    .animation(.linear(duration: 0.1), value: timeInPhase)
            }
        }
        .frame(height: 6)
        .accessibilityHidden(true)
    }

    private var phaseProgress: CGFloat {
        guard currentPhase.duration > 0 else { return 0 }
        return min(1.0, CGFloat(timeInPhase / currentPhase.duration))
    }

    // MARK: - Total Time Label

    private var totalTimeLabel: some View {
        Text(formattedTime(totalElapsed))
            .font(.system(.footnote, design: .monospaced, weight: .medium))
            .foregroundColor(.gray)
            .accessibilityLabel("Total time: \(Int(totalElapsed)) seconds")
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Stop Button

    private var stopButton: some View {
        Button(action: {
            stopDrill()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "stop.fill")
                Text("Stop Drill")
                    .font(.system(.callout, design: .rounded, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.red.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .accessibilityHint("Double tap to stop the drill immediately")
    }

    // MARK: - Drill Stopped View

    private var drillStoppedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "stop.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
                .accessibilityHidden(true)

            Text("Drill Stopped")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 8) {
                Text("Last phase: \(currentPhase.title)")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundColor(.gray)

                Text("Time: \(formattedTime(totalElapsed))")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundColor(.gray)

                Text("Phases completed: \(currentPhase.rawValue) of \(DrillPhase.allCases.count)")
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundColor(.gray.opacity(0.7))
            }

            VStack(spacing: 12) {
                Button(action: {
                    restartDrill()
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
                            colors: [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityHint("Double tap to restart the drill")

                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        gameState.currentPhase = .result
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back to Results")
                            .font(.system(.footnote, design: .rounded, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityHint("Double tap to return to results")
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Drill Complete View

    private var drillCompleteView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 70))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .accessibilityHidden(true)

            Text("Drill Complete!")
                .font(.system(.title, design: .rounded, weight: .black))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 8) {
                Text("Total Time: \(formattedTime(totalElapsed))")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundColor(.mint)

                Text("All \(DrillPhase.allCases.count) phases completed")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundColor(.gray)
            }

            completedPhasesList
                .padding(.horizontal, 20)

            VStack(spacing: 12) {
                Button(action: {
                    restartDrill()
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
                            colors: [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityHint("Double tap to practice the drill again")

                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        gameState.currentPhase = .result
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checklist")
                        Text("Back to Results")
                            .font(.system(.callout, design: .rounded, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityHint("Double tap to return to results")
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
    }

    private var completedPhasesList: some View {
        VStack(spacing: 4) {
            ForEach(DrillPhase.allCases, id: \.rawValue) { phase in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(.caption))
                        .foregroundColor(.green)
                    Image(systemName: phase.icon)
                        .font(.system(.caption))
                        .foregroundColor(phase.iconColor)
                    Text(phase.title)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(phase.title) completed")
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Drill Control Logic

    private func startCountdown() {
        showCountdown = true
        countdownValue = 3

        func tick() {
            if countdownValue > 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    guard showCountdown else { return }
                    countdownValue -= 1
                    tick()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    guard showCountdown else { return }
                    showCountdown = false
                    beginDrill()
                }
            }
        }
        tick()
    }

    private func beginDrill() {
        isActive = true
        isPaused = false
        totalElapsed = 0
        timeInPhase = 0
        currentPhase = .briefing
        drillStopped = false

        startDrillTimer()
        advanceToPhase(.briefing)
    }

    private func startDrillTimer() {
        drillTimer?.invalidate()
        drillTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                guard isActive, !isPaused else { return }
                timeInPhase += 0.1
                totalElapsed += 0.1

                if shouldShake {
                    shakeAmount += 0.1
                }
            }
        }
    }

    private func advanceToPhase(_ phase: DrillPhase) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPhase = phase
        }
        timeInPhase = 0
        currentInstructionText = phase.instruction

        triggerHapticsForPhase(phase)
        triggerSoundForPhase(phase)

        if phase == .holdOn {
            startHoldOnSequence()
        } else {
            speechManager.speak(text: phase.instruction) { [self] in
                guard isActive, !isPaused, !drillStopped else { return }
                scheduleNextPhase(after: phase)
            }
        }
    }

    private func startHoldOnSequence() {
        // First instruction
        speechManager.speak(text: currentPhase.instruction) {
            guard self.isActive, !self.isPaused, !self.drillStopped else { return }

            // Wait 5 seconds then speak second instruction
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                guard self.isActive, !self.isPaused, !self.drillStopped else { return }
                self.currentInstructionText = self.currentPhase.holdOnSecondInstruction

                self.speechManager.speak(text: self.currentPhase.holdOnSecondInstruction) {
                    guard self.isActive, !self.isPaused, !self.drillStopped else { return }

                    // Wait 5 more seconds then speak third instruction
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        guard self.isActive, !self.isPaused, !self.drillStopped else { return }
                        self.currentInstructionText = self.currentPhase.holdOnThirdInstruction

                        self.speechManager.speak(text: self.currentPhase.holdOnThirdInstruction) {
                            guard self.isActive, !self.isPaused, !self.drillStopped else { return }
                            self.scheduleNextPhase(after: .holdOn)
                        }
                    }
                }
            }
        }
    }

    private func scheduleNextPhase(after phase: DrillPhase) {
        let allPhases = DrillPhase.allCases
        guard let currentIndex = allPhases.firstIndex(of: phase),
              currentIndex + 1 < allPhases.count else {
            return
        }
        let next = allPhases[currentIndex + 1]

        // Short pause between phases to let TTS finish and effects settle
        let delay: TimeInterval = (phase == .shakingStops) ? 1.5 : 0.5

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard self.isActive, !self.isPaused, !self.drillStopped else { return }

            if next == .complete {
                self.handleDrillComplete()
            } else {
                self.advanceToPhase(next)
            }
        }
    }

    private func handleDrillComplete() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPhase = .complete
        }
        timeInPhase = 0
        currentInstructionText = DrillPhase.complete.instruction

        hapticManager.playPerfectScore()
        soundManager.playCelebration(scorePercentage: 100)
        gameState.drillCompleted = true

        speechManager.speak(text: DrillPhase.complete.instruction) {
            // Drill finished
        }

        isActive = false
        drillTimer?.invalidate()
        drillTimer = nil
    }

    private func triggerHapticsForPhase(_ phase: DrillPhase) {
        switch phase {
        case .alert:
            hapticManager.playEarthquakeSplash()
        case .drop:
            hapticManager.playCorrectAnswer()
        case .cover, .holdOn:
            hapticManager.playEarthquakeSimulation()
        case .check, .evacuate, .rallyPoint:
            hapticManager.playEncouragement()
        default:
            break
        }
    }

    private func triggerSoundForPhase(_ phase: DrillPhase) {
        switch phase {
        case .alert:
            soundManager.playSeismicAlert(duration: 3.0)
        case .cover:
            soundManager.playEarthquakeRumble()
        case .shakingStops:
            soundManager.stopEarthquakeRumble()
        default:
            break
        }
    }

    // MARK: - Pause / Resume / Stop

    private func pauseDrill() {
        isPaused = true
        speechManager.stop()
        soundManager.stop()
    }

    private func resumeDrill() {
        isPaused = false
        // Re-speak current phase instruction
        currentInstructionText = currentPhase.instruction
        speechManager.speak(text: currentPhase.instruction) {
            guard self.isActive, !self.isPaused, !self.drillStopped else { return }
            self.scheduleNextPhase(after: self.currentPhase)
        }
        triggerSoundForPhase(currentPhase)
    }

    private func stopDrill() {
        isActive = false
        isPaused = false
        drillStopped = true
        showCountdown = false
        speechManager.stop()
        soundManager.stop()
        drillTimer?.invalidate()
        drillTimer = nil
    }

    private func restartDrill() {
        drillStopped = false
        showCountdown = true
        currentPhase = .briefing
        timeInPhase = 0
        totalElapsed = 0
        shakeAmount = 0
        currentInstructionText = ""
        startCountdown()
    }

    private func cleanupDrill() {
        isActive = false
        speechManager.stop()
        soundManager.stop()
        drillTimer?.invalidate()
        drillTimer = nil
    }
}
