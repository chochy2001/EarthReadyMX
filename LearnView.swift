import SwiftUI

struct LearnView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedPhase: EarthquakePhase = .before
    @State private var expandedTipId: UUID?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.12),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                phaseSelector.padding(.top, 8)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(gameState.tipsFor(phase: selectedPhase)) { tip in
                            TipCard(tip: tip, isExpanded: expandedTipId == tip.id) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    expandedTipId = expandedTipId == tip.id ? nil : tip.id
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }

                bottomSection
            }
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Safety Protocol")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .accessibilityAddTraits(.isHeader)
                Text("Tap each card to learn more")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 30))
                .foregroundColor(.orange)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private var phaseSelector: some View {
        HStack(spacing: 4) {
            ForEach(EarthquakePhase.allCases, id: \.self) { phase in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedPhase = phase
                        expandedTipId = nil
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: iconFor(phase: phase))
                            .font(.caption)
                        Text(phase.rawValue)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(selectedPhase == phase ? .black : .white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if selectedPhase == phase {
                                LinearGradient(
                                    colors: colorsFor(phase: phase),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            } else {
                                Color.white.opacity(0.08)
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedPhase == phase ? Color.clear : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
                }
                .accessibilityLabel("\(phase.rawValue) phase")
                .accessibilityValue(selectedPhase == phase ? "Selected" : "Not selected")
                .accessibilityHint("Double tap to view \(phase.rawValue.lowercased()) earthquake tips")
                .accessibilityAddTraits(selectedPhase == phase ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, 20)
    }

    private var bottomSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(EarthquakePhase.allCases, id: \.self) { phase in
                    HStack(spacing: 4) {
                        Image(systemName: gameState.learnPhasesCompleted.contains(phase)
                              ? "checkmark.circle.fill" : "circle")
                            .font(.caption)
                            .foregroundColor(gameState.learnPhasesCompleted.contains(phase) ? .green : .gray)
                        Text(phase.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(gameState.learnPhasesCompleted.contains(phase) ? .green : .gray)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(phase.rawValue) phase")
                    .accessibilityValue(gameState.learnPhasesCompleted.contains(phase) ? "Completed" : "Not completed")
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .accessibilityLabel("Progress: \(gameState.learnPhasesCompleted.count) of 3 phases completed")

            HStack(spacing: 12) {
                Button(action: {
                    _ = withAnimation {
                        gameState.learnPhasesCompleted.insert(selectedPhase)
                    }
                    if let next = nextUncompletedPhase() {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedPhase = next
                            expandedTipId = nil
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: gameState.learnPhasesCompleted.contains(selectedPhase)
                              ? "checkmark.circle.fill" : "checkmark.circle")
                        Text(gameState.learnPhasesCompleted.contains(selectedPhase) ? "Completed" : "Mark as Read")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(gameState.learnPhasesCompleted.contains(selectedPhase) ? .green : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        gameState.learnPhasesCompleted.contains(selectedPhase)
                        ? Color.green.opacity(0.15)
                        : Color.white.opacity(0.1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityValue(gameState.learnPhasesCompleted.contains(selectedPhase) ? "Completed" : "Not completed")
                .accessibilityHint(
                    gameState.learnPhasesCompleted.contains(selectedPhase)
                        ? "This phase is already completed"
                        : "Double tap to mark \(selectedPhase.rawValue) phase as read"
                )

                if gameState.learnPhasesCompleted.count == 3 {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            gameState.currentPhase = .simulation
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Test Yourself")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityHint("Double tap to start the earthquake simulation quiz")
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color.black.opacity(0.8))
    }

    private func iconFor(phase: EarthquakePhase) -> String {
        switch phase {
        case .before: return "clock.arrow.circlepath"
        case .during: return "waveform.path.ecg"
        case .after: return "checkmark.shield"
        }
    }

    private func colorsFor(phase: EarthquakePhase) -> [Color] {
        switch phase {
        case .before: return [.blue, .cyan]
        case .during: return [.orange, .red]
        case .after: return [.green, .mint]
        }
    }

    private func nextUncompletedPhase() -> EarthquakePhase? {
        EarthquakePhase.allCases.first { !gameState.learnPhasesCompleted.contains($0) }
    }
}

struct TipCard: View {
    let tip: SafetyTip
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(colorFor(phase: tip.phase).opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: tip.icon)
                            .font(.system(size: 18))
                            .foregroundColor(colorFor(phase: tip.phase))
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tip.title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        if !isExpanded {
                            Text(tip.description.prefix(50) + "...")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .accessibilityHidden(true)
                }
                .padding(16)

                if isExpanded {
                    Text(tip.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isExpanded ? colorFor(phase: tip.phase).opacity(0.3) : Color.white.opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tip.title). \(isExpanded ? tip.description : "")")
        .accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to expand and read details")
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
    }

    private func colorFor(phase: EarthquakePhase) -> Color {
        switch phase {
        case .before: return .cyan
        case .during: return .orange
        case .after: return .green
        }
    }
}
