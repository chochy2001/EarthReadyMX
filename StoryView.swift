import SwiftUI
import EarthReadyCore

struct StoryView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var soundManager: SoundManager
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // MARK: - Slide Progression
    @State private var currentSlide = 0
    @State private var slideVisible: [Bool] = Array(repeating: false, count: 6)

    // MARK: - Slide 1 State
    @State private var showDate = false
    @State private var showCity = false

    // MARK: - Slide 2 State
    @State private var showDrillText = false
    @State private var showDrillSubtitle = false
    @State private var seismographPoints: [CGFloat] = Array(repeating: 0, count: 60)
    @State private var seismographTimer: Timer?

    // MARK: - Slide 3 State
    @State private var typewriterText = ""
    @State private var typewriterIndex = 0
    @State private var showStrikeSubtitle = false
    @State private var shakeAmount: CGFloat = 0
    @State private var typewriterTimer: Timer?

    // MARK: - Slide 4 State
    @State private var deathCount = 0
    @State private var showBuildings = false
    @State private var showInjured = false

    // MARK: - Slide 5 State
    @State private var showSecondsText = false
    @State private var showSecondsSubtitle = false

    // MARK: - Slide 6 State
    @State private var showCallToAction = false
    @State private var showActionButton = false
    @State private var hopefulGradient = false

    // MARK: - Sequence Cancellation
    @State private var sequenceToken = UUID()
    @State private var pendingWorkItems: [DispatchWorkItem] = []

    private let fullTypewriterText = "A 7.1 magnitude earthquake struck."

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.5), value: hopefulGradient)

            VStack {
                HStack {
                    Spacer()
                    GuardedButton(action: skipToSimulation) {
                        Text("Skip")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    .accessibilityLabel("Skip story")
                    .accessibilityHint("Go directly to the earthquake quiz")
                }
                .padding(.top, 8)
                .padding(.trailing, 8)

                Spacer()
            }

            VStack(spacing: 0) {
                Spacer()
                slideContent
                Spacer()
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            startStorySequence()
        }
        .onDisappear {
            cleanupTimers()
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        Group {
            if hopefulGradient {
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.1, blue: 0.05),
                        Color(red: 0.2, green: 0.12, blue: 0.02),
                        Color(red: 0.1, green: 0.05, blue: 0.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.05, blue: 0.15),
                        Color(red: 0.15, green: 0.05, blue: 0.05),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    // MARK: - Slide Content

    @ViewBuilder
    private var slideContent: some View {
        switch currentSlide {
        case 0:
            slideOneView
        case 1:
            slideTwoView
        case 2:
            slideThreeView
        case 3:
            slideFourView
        case 4:
            slideFiveView
        case 5:
            slideSixView
        default:
            EmptyView()
        }
    }

    // MARK: - Slide 1: September 19, 2017

    private var slideOneView: some View {
        VStack(spacing: 16) {
            if showDate {
                Text("September 19, 2017")
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
            if showCity {
                Text("Mexico City")
                    .font(.system(.title2, design: .rounded, weight: .medium))
                    .foregroundColor(.gray)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 40)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Slide 2: A National Drill

    private var slideTwoView: some View {
        VStack(spacing: 20) {
            if showDrillText {
                Text("That morning, millions practiced an earthquake drill.")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
            if showDrillSubtitle {
                Text("Commemorating 32 years since the devastating 1985 earthquake.")
                    .font(.system(.body, design: .rounded, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }

            SeismographView(points: seismographPoints, isActive: false)
                .frame(height: 60)
                .padding(.horizontal, 30)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Seismograph showing calm readings")
                .accessibilityAddTraits(.isImage)
        }
        .padding(.horizontal, 40)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Slide 3: 1:14 PM

    private var slideThreeView: some View {
        VStack(spacing: 16) {
            Text("1:14 PM \u{2014} Without Warning")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.red.opacity(0.9))
                .multilineTextAlignment(.center)

            Text(typewriterText)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if showStrikeSubtitle {
                Text("The epicenter was just 120 km away. The alert arrived too late.")
                    .font(.system(.body, design: .rounded, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 40)
        .modifier(ShakeEffect(animatableData: reduceMotion ? 0 : shakeAmount))
        .accessibilityElement(children: .combine)
    }

    // MARK: - Slide 4: The Impact

    private var slideFourView: some View {
        VStack(spacing: 8) {
            Text("The Impact")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 16)

            impactStat(
                number: "\(deathCount)",
                label: "lives lost",
                visible: true
            )

            if showBuildings {
                impactStat(
                    number: "44",
                    label: "buildings collapsed",
                    visible: true
                )
                .transition(.opacity)
            }

            if showInjured {
                impactStat(
                    number: "6,000+",
                    label: "people injured",
                    visible: true
                )
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 40)
        .accessibilityElement(children: .combine)
    }

    private func impactStat(number: String, label: String, visible: Bool) -> some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(.orange)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(number) \(label)")
    }

    // MARK: - Slide 5: 20 Seconds

    private var slideFiveView: some View {
        VStack(spacing: 16) {
            if showSecondsText {
                Text("The strong shaking lasted just 20 seconds.")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
            if showSecondsSubtitle {
                Text("But those 20 seconds changed everything.")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundColor(.orange.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 40)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Slide 6: Be Ready

    private var slideSixView: some View {
        VStack(spacing: 24) {
            if showCallToAction {
                VStack(spacing: 12) {
                    Text("The difference between life and loss is preparation.")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Test your knowledge. Learn to protect yourself and others.")
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.opacity)
            }

            if showActionButton {
                GuardedButton(action: {
                    cleanupTimers()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        gameState.currentPhase = .simulation
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "shield.checkered")
                            .font(.title3)
                        Text("Test Your Knowledge")
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
                .accessibilityLabel("Test Your Knowledge")
                .accessibilityHint("Double tap to begin the earthquake quiz")
            }
        }
        .padding(.horizontal, 20)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Skip

    private func skipToSimulation() {
        guard gameState.currentPhase == .story else { return }
        cleanupTimers()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            gameState.currentPhase = .simulation
        }
    }

    // MARK: - Cleanup

    private func cleanupTimers() {
        sequenceToken = UUID()
        pendingWorkItems.forEach { $0.cancel() }
        pendingWorkItems.removeAll()
        seismographTimer?.invalidate()
        seismographTimer = nil
        typewriterTimer?.invalidate()
        typewriterTimer = nil
        soundManager.stop()
    }

    private func scheduleAfter(_ delay: TimeInterval, token: UUID, action: @escaping @MainActor () -> Void) {
        let item = DispatchWorkItem {
            Task { @MainActor in
                guard sequenceToken == token else { return }
                action()
            }
        }
        pendingWorkItems.append(item)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }

    // MARK: - Animation Sequence

    private func startStorySequence() {
        cleanupTimers()
        let token = sequenceToken
        if reduceMotion {
            startReducedMotionSequence(token: token)
            return
        }
        startSlideOne(token: token)
    }

    private func startReducedMotionSequence(token: UUID) {
        currentSlide = 0
        showDate = true
        showCity = true
        AccessibilityAnnouncement.announceScreenChange(
            "September 19, 2017. Mexico City. Story about the earthquake."
        )

        scheduleAfter(3.5, token: token) {
            advanceToSlide(1)
            showDrillText = true
            showDrillSubtitle = true
            startCalmSeismograph()
            AccessibilityAnnouncement.announceScreenChange(
                "That morning, millions practiced an earthquake drill."
            )
        }

        scheduleAfter(8.5, token: token) {
            advanceToSlide(2)
            typewriterText = fullTypewriterText
            typewriterIndex = fullTypewriterText.count
            showStrikeSubtitle = true
            AccessibilityAnnouncement.announceScreenChange(
                "A 7.1 magnitude earthquake struck. The alert arrived too late."
            )
        }

        scheduleAfter(14.5, token: token) {
            advanceToSlide(3)
            deathCount = 370
            showBuildings = true
            showInjured = true
            AccessibilityAnnouncement.announceScreenChange(
                "370 lives lost. 44 buildings collapsed. Over 6000 people injured."
            )
        }

        scheduleAfter(21.5, token: token) {
            advanceToSlide(4)
            showSecondsText = true
            showSecondsSubtitle = true
            AccessibilityAnnouncement.announceScreenChange(
                "The strong shaking lasted just 20 seconds."
            )
        }

        scheduleAfter(26.5, token: token) {
            advanceToSlide(5)
            hopefulGradient = true
            showCallToAction = true
            showActionButton = true
            AccessibilityAnnouncement.announceScreenChange(
                "The difference between life and loss is preparation. Test Your Knowledge button available."
            )
        }
    }

    // MARK: - Slide One

    private func startSlideOne(token: UUID) {
        currentSlide = 0

        scheduleAfter(0.3, token: token) {
            withAnimation(.easeIn(duration: 0.8)) {
                showDate = true
            }
        }

        scheduleAfter(1.2, token: token) {
            withAnimation(.easeIn(duration: 0.6)) {
                showCity = true
            }
        }

        AccessibilityAnnouncement.announceScreenChange(
            "September 19, 2017. Mexico City."
        )

        scheduleAfter(3.5, token: token) {
            startSlideTwo(token: token)
        }
    }

    // MARK: - Slide Two

    private func startSlideTwo(token: UUID) {
        withAnimation(.easeInOut(duration: 0.4)) {
            advanceToSlide(1)
        }

        startCalmSeismograph()

        scheduleAfter(0.3, token: token) {
            withAnimation(.easeIn(duration: 0.6)) {
                showDrillText = true
            }
        }

        scheduleAfter(1.0, token: token) {
            withAnimation(.easeIn(duration: 0.6)) {
                showDrillSubtitle = true
            }
        }

        AccessibilityAnnouncement.announceScreenChange(
            "That morning, millions practiced an earthquake drill."
        )

        scheduleAfter(5.0, token: token) {
            startSlideThree(token: token)
        }
    }

    // MARK: - Slide Three

    private func startSlideThree(token: UUID) {
        seismographTimer?.invalidate()
        seismographTimer = nil

        withAnimation(.easeInOut(duration: 0.4)) {
            advanceToSlide(2)
        }

        // Typewriter effect
        typewriterIndex = 0
        typewriterTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { _ in
            Task { @MainActor [self] in
                guard sequenceToken == token else {
                    self.typewriterTimer?.invalidate()
                    self.typewriterTimer = nil
                    return
                }
                if typewriterIndex < fullTypewriterText.count {
                    typewriterIndex += 1
                    typewriterText = String(fullTypewriterText.prefix(typewriterIndex))
                } else {
                    self.typewriterTimer?.invalidate()
                    self.typewriterTimer = nil
                }
            }
        }

        // Shake + haptic + sound at 0.5s
        scheduleAfter(0.5, token: token) {
            hapticManager.playEarthquakeSplash()
            soundManager.playSeismicAlert(duration: 2.0)
            withAnimation(.easeInOut(duration: 0.8)) {
                shakeAmount = 6
            }
        }

        scheduleAfter(1.8, token: token) {
            withAnimation(.easeIn(duration: 0.5)) {
                showStrikeSubtitle = true
            }
        }

        AccessibilityAnnouncement.announceScreenChange(
            "1:14 PM. Without warning. A 7.1 magnitude earthquake struck."
        )

        scheduleAfter(6.0, token: token) {
            startSlideFour(token: token)
        }
    }

    // MARK: - Slide Four

    private func startSlideFour(token: UUID) {
        withAnimation(.easeInOut(duration: 0.4)) {
            advanceToSlide(3)
        }

        // Animate death count from 0 to 370
        scheduleAfter(0.3, token: token) {
            withAnimation(.easeInOut(duration: 2.0)) {
                deathCount = 370
            }
            hapticManager.playEncouragement()
        }

        // Show buildings after 1s
        scheduleAfter(1.3, token: token) {
            withAnimation(.easeIn(duration: 0.5)) {
                showBuildings = true
            }
            hapticManager.playEncouragement()
        }

        // Show injured after 2s
        scheduleAfter(2.3, token: token) {
            withAnimation(.easeIn(duration: 0.5)) {
                showInjured = true
            }
            hapticManager.playEncouragement()
        }

        AccessibilityAnnouncement.announceScreenChange(
            "The impact. 370 lives lost. 44 buildings collapsed. Over 6000 people injured."
        )

        scheduleAfter(7.0, token: token) {
            startSlideFive(token: token)
        }
    }

    // MARK: - Slide Five

    private func startSlideFive(token: UUID) {
        withAnimation(.easeInOut(duration: 0.4)) {
            advanceToSlide(4)
        }

        scheduleAfter(0.3, token: token) {
            withAnimation(.easeIn(duration: 0.6)) {
                showSecondsText = true
            }
        }

        scheduleAfter(1.2, token: token) {
            withAnimation(.easeIn(duration: 0.6)) {
                showSecondsSubtitle = true
            }
        }

        AccessibilityAnnouncement.announceScreenChange(
            "The strong shaking lasted just 20 seconds. But those 20 seconds changed everything."
        )

        scheduleAfter(5.0, token: token) {
            startSlideSix(token: token)
        }
    }

    // MARK: - Slide Six

    private func startSlideSix(token: UUID) {
        withAnimation(.easeInOut(duration: 0.4)) {
            advanceToSlide(5)
        }

        withAnimation(.easeInOut(duration: 1.5)) {
            hopefulGradient = true
        }

        scheduleAfter(0.5, token: token) {
            withAnimation(.easeIn(duration: 0.8)) {
                showCallToAction = true
            }
        }

        scheduleAfter(1.5, token: token) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showActionButton = true
            }
        }

        AccessibilityAnnouncement.announceScreenChange(
            "The difference between life and loss is preparation. Test Your Knowledge button available."
        )
    }

    // MARK: - Helpers

    private func advanceToSlide(_ slide: Int) {
        currentSlide = slide
    }

    private func startCalmSeismograph() {
        seismographTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in
                seismographPoints.removeFirst()
                let last = seismographPoints.last ?? 0
                seismographPoints.append(last * 0.9 + CGFloat.random(in: -0.05...0.05))
            }
        }
    }
}
