import SwiftUI

// MARK: - Bag Frame Preference Key

private struct BagFramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// MARK: - Kit Builder View

struct KitBuilderView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var soundManager: SoundManager
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    @State private var items: [KitItem] = []
    @State private var bagContents: Set<UUID> = []
    @State private var score: Int = 0
    @State private var essentialsFound: Int = 0
    @State private var bagFrame: CGRect = .zero
    @State private var feedbackItem: KitItem?
    @State private var feedbackIsCorrect: Bool = true
    @State private var showResults: Bool = false
    @State private var showIntro: Bool = true
    @State private var wrongItemShake: UUID?

    private let totalEssentials = 10

    var body: some View {
        GeometryReader { geometry in
            let isWide = geometry.size.width > 600
            let columns = isWide
                ? [GridItem](repeating: GridItem(.flexible(), spacing: 12), count: 4)
                : [GridItem](repeating: GridItem(.flexible(), spacing: 12), count: 3)

            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.05, blue: 0.12), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if showIntro {
                    introOverlay
                } else if showResults {
                    resultsOverlay
                } else {
                    VStack(spacing: 0) {
                        // Back button
                        HStack {
                            Button(action: {
                                withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.7)) {
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

                        // TOP: Scrollable items
                        ScrollView {
                            VStack(spacing: 16) {
                                headerSection

                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(items) { item in
                                        DraggableKitItem(
                                            item: item,
                                            isInBag: bagContents.contains(item.id),
                                            bagFrame: $bagFrame,
                                            wrongItemShake: $wrongItemShake,
                                            reduceMotion: reduceMotion,
                                            differentiateWithoutColor: differentiateWithoutColor,
                                            onDrop: { handleDrop(item: item) }
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)

                                Spacer().frame(height: 8)
                            }
                            .frame(maxWidth: 700)
                            .frame(maxWidth: .infinity)
                        }

                        // BOTTOM: Backpack drop target (FIXED, always visible)
                        VStack(spacing: 12) {
                            BackpackDropTarget(
                                itemCount: bagContents.count,
                                reduceMotion: reduceMotion
                            )
                            .padding(.horizontal, 16)
                            .background(
                                GeometryReader { bagGeometry in
                                    Color.clear
                                        .preference(
                                            key: BagFramePreferenceKey.self,
                                            value: bagGeometry.frame(in: .global)
                                        )
                                }
                            )
                            .onPreferenceChange(BagFramePreferenceKey.self) { frame in
                                bagFrame = frame
                            }

                            if bagContents.count >= 5 {
                                completeButton
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.05, green: 0.05, blue: 0.12).opacity(0),
                                    Color(red: 0.05, green: 0.05, blue: 0.12)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 20)
                            .offset(y: -20),
                            alignment: .top
                        )
                    }
                }

                if feedbackItem != nil {
                    VStack {
                        Spacer()
                        FeedbackToast(
                            item: feedbackItem,
                            isCorrect: feedbackIsCorrect,
                            differentiateWithoutColor: differentiateWithoutColor
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 180)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .allowsHitTesting(false)
                }
            }
        }
        .onAppear {
            items = KitBuilderData.itemsForSession()
            AccessibilityAnnouncement.announceScreenChange(
                "Emergency Kit Builder. Drag essential items into your backpack. \(items.count) items to choose from."
            )
        }
    }

    // MARK: - Intro Overlay

    private var introOverlay: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "bag.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .accessibilityHidden(true)

            Text("Build Your Emergency Kit")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text("Drag the essential items into your backpack.\nAvoid dangerous or unnecessary items!")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button(action: {
                withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8)) {
                    showIntro = false
                }
            }) {
                Text("Start")
                    .font(.system(.title3, design: .rounded, weight: .bold))
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
            }
            .padding(.horizontal, 40)
            .accessibilityHint("Double tap to begin building your emergency kit")

            Spacer().frame(height: 40)
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Build Your Emergency Kit")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            Text("\(essentialsFound)/\(totalEssentials) essentials found")
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundColor(.orange)
                .accessibilityLabel("\(essentialsFound) of \(totalEssentials) essential items found")
        }
        .padding(.top, 20)
    }

    // MARK: - Complete Button

    private var completeButton: some View {
        Button(action: {
            finishGame()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                Text("Done")
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
        .modifier(PulseEffect())
        .accessibilityHint("Double tap to finish building your kit and see your results")
    }

    // MARK: - Drop Handling

    private func handleDrop(item: KitItem) {
        guard !bagContents.contains(item.id) else { return }

        bagContents.insert(item.id)
        score += item.points

        let isCorrect = item.category == .essential
        feedbackIsCorrect = isCorrect
        feedbackItem = item

        if isCorrect {
            essentialsFound += 1
            hapticManager.playCorrectAnswer()
            soundManager.playCorrectSound()
        } else {
            hapticManager.playWrongAnswer()
            soundManager.playIncorrectSound()
            wrongItemShake = item.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wrongItemShake = nil
            }
        }

        // Dismiss feedback toast after 2.5 seconds
        let capturedItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if feedbackItem?.id == capturedItem.id {
                withAnimation(reduceMotion ? .none : .easeOut(duration: 0.3)) {
                    feedbackItem = nil
                }
            }
        }
    }

    // MARK: - Finish Game

    private func finishGame() {
        // Bonus for finding all essentials
        if essentialsFound == totalEssentials {
            score += 20
        }

        gameState.kitScore = score
        gameState.kitEssentialsFound = essentialsFound

        withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8)) {
            showResults = true
        }

        AccessibilityAnnouncement.announceScreenChange(
            "Results. You found \(essentialsFound) of \(totalEssentials) essential items. Score: \(score) points."
        )
    }

    // MARK: - Star Rating

    private var starCount: Int {
        let wrongItems = bagContents.filter { id in
            items.first(where: { $0.id == id })?.category != .essential
        }.count

        if essentialsFound == totalEssentials && wrongItems == 0 {
            return 3
        } else if essentialsFound >= 7 {
            return 2
        } else if essentialsFound >= 4 {
            return 1
        }
        return 0
    }

    // MARK: - Results Overlay

    private var resultsOverlay: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 30)

                // Stars
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < starCount ? "star.fill" : "star")
                            .font(.system(.largeTitle))
                            .foregroundColor(index < starCount ? .yellow : .gray.opacity(0.4))
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(starCount) of 3 stars")

                // Score
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                    Text("Points")
                        .font(.system(.callout, design: .rounded, weight: .medium))
                        .foregroundColor(.gray)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Score: \(score) points")

                // Essentials counter
                Text("\(essentialsFound)/\(totalEssentials) Essentials Found")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundColor(.orange)

                // Summary of items
                resultsSummary

                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.7)) {
                            gameState.currentPhase = .checklist
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checklist")
                            Text("Continue to Checklist")
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
                    .accessibilityHint("Double tap to open your earthquake preparedness checklist")

                    Button(action: {
                        resetAndReplay()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Try Again")
                                .font(.system(.footnote, design: .rounded, weight: .semibold))
                        }
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .accessibilityHint("Double tap to restart the kit builder game")
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 40)
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
    }

    private var resultsSummary: some View {
        VStack(spacing: 12) {
            Text("Kit Summary")
                .font(.system(.body, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            ForEach(items.filter({ bagContents.contains($0.id) })) { item in
                let isCorrect = item.category == .essential
                HStack(spacing: 12) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)
                        .font(.system(.title3))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.system(.footnote, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                        Text(item.explanation)
                            .font(.system(.caption))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    Spacer()
                    if differentiateWithoutColor {
                        Text(isCorrect ? "CORRECT" : "WRONG")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundColor(isCorrect ? .green : .red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background((isCorrect ? Color.green : Color.red).opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .padding(14)
                .background((isCorrect ? Color.green : Color.red).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            (isCorrect ? Color.green : Color.red).opacity(differentiateWithoutColor ? 0.3 : 0),
                            style: isCorrect
                                ? StrokeStyle(lineWidth: 1.5)
                                : StrokeStyle(lineWidth: 1.5, dash: [5, 3])
                        )
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(item.name). \(isCorrect ? "Correct" : "Incorrect"). \(item.explanation)")
            }

            // Show missed essentials
            let missedEssentials = items.filter { $0.category == .essential && !bagContents.contains($0.id) }
            if !missedEssentials.isEmpty {
                Text("Missed Essentials")
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    .accessibilityAddTraits(.isHeader)

                ForEach(missedEssentials) { item in
                    HStack(spacing: 12) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.orange)
                            .font(.system(.title3))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.system(.footnote, design: .rounded, weight: .semibold))
                                .foregroundColor(.white)
                            Text(item.explanation)
                                .font(.system(.caption))
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color.orange.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Missed: \(item.name). \(item.explanation)")
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func resetAndReplay() {
        gameState.resetKitBuilder()
        bagContents = []
        score = 0
        essentialsFound = 0
        feedbackItem = nil
        showResults = false
        items = KitBuilderData.itemsForSession()
    }
}

// MARK: - Draggable Kit Item

private struct DraggableKitItem: View {
    let item: KitItem
    let isInBag: Bool
    @Binding var bagFrame: CGRect
    @Binding var wrongItemShake: UUID?
    let reduceMotion: Bool
    let differentiateWithoutColor: Bool
    let onDrop: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        isInBag
                            ? (item.category == .essential
                                ? Color.green.opacity(0.15)
                                : Color.red.opacity(0.15))
                            : Color.white.opacity(0.08)
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: item.icon)
                    .font(.system(.title2))
                    .foregroundColor(
                        isInBag
                            ? (item.category == .essential ? .green : .red)
                            : .white
                    )

                if isInBag {
                    Image(systemName: item.category == .essential ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(.caption))
                        .foregroundColor(item.category == .essential ? .green : .red)
                        .offset(x: 22, y: -22)
                }
            }

            Text(item.name)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(isInBag ? .gray : .white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 32)

            if differentiateWithoutColor && isInBag {
                Text(item.category == .essential ? "ESSENTIAL" : "WRONG")
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundColor(item.category == .essential ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isDragging ? 0.12 : 0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isDragging ? Color.orange.opacity(0.5) : Color.clear,
                    lineWidth: 1.5
                )
        )
        .opacity(isInBag ? 0.5 : 1.0)
        .scaleEffect(isDragging ? 1.1 : 1.0)
        .offset(dragOffset)
        .modifier(
            ShakeEffect(
                animatableData: wrongItemShake == item.id ? 1 : 0
            )
        )
        .animation(
            reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.6),
            value: isDragging
        )
        .animation(
            reduceMotion ? .none : .default,
            value: wrongItemShake
        )
        .gesture(
            isInBag
                ? nil
                : DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        dragOffset = value.translation
                        isDragging = true
                    }
                    .onEnded { value in
                        isDragging = false
                        if bagFrame.contains(value.location) {
                            onDrop()
                        }
                        withAnimation(
                            reduceMotion
                                ? .none
                                : .spring(response: 0.4, dampingFraction: 0.7)
                        ) {
                            dragOffset = .zero
                        }
                    }
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.name)
        .accessibilityValue(isInBag ? "In backpack" : "Not in backpack")
        .accessibilityHint(isInBag ? "Already added to your kit" : "Double tap to add to your emergency kit")
        .accessibilityAction(named: "Add to Kit") {
            if !isInBag {
                onDrop()
            }
        }
    }
}

// MARK: - Backpack Drop Target

private struct BackpackDropTarget: View {
    let itemCount: Int
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.orange.opacity(0.12))

            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2.5, dash: [8, 6])
                )
                .foregroundColor(.orange.opacity(0.5))

            VStack(spacing: 8) {
                ZStack {
                    Image(systemName: "bag.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    if itemCount > 0 {
                        Text("\(itemCount)")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .clipShape(Capsule())
                            .offset(x: 22, y: -18)
                    }
                }

                Text("Drop items here")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundColor(.orange.opacity(0.8))
            }
        }
        .frame(height: 120)
        .modifier(GlowEffect(color: .orange))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Backpack drop zone")
        .accessibilityValue("\(itemCount) items in backpack")
        .accessibilityHint("Drag items here to add them to your emergency kit")
    }
}

// MARK: - Feedback Toast

private struct FeedbackToast: View {
    let item: KitItem?
    let isCorrect: Bool
    let differentiateWithoutColor: Bool

    var body: some View {
        if let item = item {
            HStack(spacing: 12) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(.title3))
                    .foregroundColor(isCorrect ? .green : .red)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(item.name)
                            .font(.system(.footnote, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                        if differentiateWithoutColor {
                            Text(isCorrect ? "CORRECT" : "WRONG")
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                                .foregroundColor(isCorrect ? .green : .red)
                        }
                    }
                    Text(item.explanation)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(3)
                }

                Spacer()

                Text(item.points > 0 ? "+\(item.points)" : "\(item.points)")
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundColor(isCorrect ? .green : .red)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill((isCorrect ? Color.green : Color.red).opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke((isCorrect ? Color.green : Color.red).opacity(0.3), lineWidth: 1)
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                "\(isCorrect ? "Correct" : "Incorrect"): \(item.name). \(item.explanation). \(item.points > 0 ? "Plus" : "Minus") \(abs(item.points)) points."
            )
        }
    }
}

