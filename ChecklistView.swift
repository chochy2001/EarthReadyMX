import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var hapticManager: HapticManager
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @State private var selectedCategory: ChecklistCategory?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.06, blue: 0.12),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if let category = selectedCategory {
                categoryDetailView(category)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                mainChecklistView
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedCategory?.id)
    }

    // MARK: - Main Checklist View

    private var mainChecklistView: some View {
        VStack(spacing: 0) {
            checklistHeader

            ScrollView {
                VStack(spacing: 20) {
                    progressSection
                        .padding(.top, 16)

                    ForEach(gameState.checklistCategories) { category in
                        CategoryCard(category: category) {
                            selectedCategory = category
                        }
                    }

                    sourceAttribution
                        .padding(.top, 8)

                    startOverButton
                        .padding(.top, 4)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Header

    private var checklistHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Preparedness")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .accessibilityAddTraits(.isHeader)
                Text("Based on FEMA & CENAPRED guidelines")
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("\(gameState.checklistPercentage)%")
                .font(.system(.title3, design: .rounded, weight: .black))
                .minimumScaleFactor(0.7)
                .foregroundColor(gameState.checklistPercentage == 100 ? .green : .orange)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: gameState.checklistProgress)
                    .stroke(
                        LinearGradient(
                            colors: gameState.checklistPercentage == 100
                                ? [.green, .mint]
                                : [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.5), value: gameState.checklistProgress)

                VStack(spacing: 2) {
                    Text("\(gameState.completedChecklistItems)")
                        .font(.system(.title, design: .rounded, weight: .black))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.white)
                    Text("of \(gameState.totalChecklistItems)")
                        .font(.system(.footnote, design: .rounded, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 120, height: 120)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(gameState.completedChecklistItems) of \(gameState.totalChecklistItems) items completed, \(gameState.checklistPercentage) percent")

            Text(gameState.checklistMotivationalMessage)
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Source Attribution

    private var sourceAttribution: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.shield.fill")
                .font(.caption)
                .foregroundColor(.green.opacity(0.6))
            Text("Data from FEMA Ready.gov & CENAPRED Mexico")
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundColor(.gray.opacity(0.6))
        }
    }

    // MARK: - Start Over Button

    private var startOverButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                gameState.reset()
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

    // MARK: - Category Detail View

    private func categoryDetailView(_ category: ChecklistCategory) -> some View {
        let currentCategory = gameState.checklistCategories.first(where: { $0.id == category.id }) ?? category

        return VStack(spacing: 0) {
            // Detail header
            HStack {
                Button(action: {
                    selectedCategory = nil
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(.footnote, weight: .semibold))
                        Text("Back")
                            .font(.system(.callout, design: .rounded, weight: .medium))
                    }
                    .foregroundColor(.orange)
                }
                .accessibilityLabel("Go back to checklist")

                Spacer()

                Text("\(currentCategory.completedCount)/\(currentCategory.totalCount)")
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundColor(currentCategory.isComplete ? .green : .white)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // Category title
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: currentCategory.gradientColors.map { $0.opacity(0.2) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    Image(systemName: currentCategory.icon)
                        .font(.system(.body))
                        .foregroundColor(currentCategory.color)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(currentCategory.title)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                        .accessibilityAddTraits(.isHeader)
                    Text(currentCategory.subtitle)
                        .font(.system(.footnote, design: .rounded, weight: .medium))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // Progress bar
            ProgressBarView(progress: currentCategory.progress, colors: currentCategory.gradientColors)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            // Items grouped by priority
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(ChecklistPriority.allCases, id: \.self) { priority in
                        let items = currentCategory.items.filter { $0.priority == priority }
                        if !items.isEmpty {
                            prioritySectionHeader(priority)
                                .padding(.top, priority == .critical ? 8 : 16)

                            ForEach(items) { item in
                                ChecklistItemRow(
                                    item: item,
                                    categoryColor: currentCategory.color
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        gameState.toggleChecklistItem(
                                            categoryId: currentCategory.id,
                                            itemId: item.id
                                        )
                                    }
                                    if item.isCompleted == false {
                                        hapticManager.playCorrectAnswer()
                                    }
                                }
                            }
                        }
                    }
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    @ViewBuilder
    private func prioritySectionHeader(_ priority: ChecklistPriority) -> some View {
        HStack(spacing: 6) {
            if differentiateWithoutColor {
                Image(systemName: priority.icon)
                    .font(.system(.caption2))
                    .foregroundColor(priority.color.opacity(0.8))
            } else {
                Circle()
                    .fill(priority.color.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
            Text(priority.label.uppercased())
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundColor(priority.color.opacity(0.8))
                .tracking(1)
            Spacer()
        }
        .accessibilityLabel("\(priority.label) priority items")
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: ChecklistCategory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: category.gradientColors.map { $0.opacity(0.2) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        Image(systemName: category.icon)
                            .font(.system(.title3))
                            .foregroundColor(category.color)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.title)
                            .font(.system(.callout, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                        Text(category.subtitle)
                            .font(.system(.caption))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(category.completedCount)/\(category.totalCount)")
                            .font(.system(.footnote, design: .rounded, weight: .bold))
                            .foregroundColor(category.isComplete ? .green : .white)
                        if category.isComplete {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                ProgressBarView(progress: category.progress, colors: category.gradientColors)
            }
            .padding(16)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        category.isComplete ? Color.green.opacity(0.3) : Color.white.opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(category.title). \(category.completedCount) of \(category.totalCount) completed")
        .accessibilityValue(category.isComplete ? "Complete" : "\(Int(category.progress * 100)) percent")
        .accessibilityHint("Double tap to view items")
    }
}

// MARK: - Checklist Item Row

struct ChecklistItemRow: View {
    let item: ChecklistItem
    let categoryColor: Color
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                CheckboxView(isChecked: item.isCompleted, color: categoryColor)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Image(systemName: item.icon)
                            .font(.system(.caption))
                            .foregroundColor(item.isCompleted ? categoryColor.opacity(0.5) : categoryColor)
                        Text(item.title)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(item.isCompleted ? .gray : .white)
                            .strikethrough(item.isCompleted, color: .gray.opacity(0.5))
                    }
                    Text(item.description)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.gray.opacity(item.isCompleted ? 0.5 : 0.8))
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(12)
            .background(
                item.isCompleted
                    ? categoryColor.opacity(0.05)
                    : Color.white.opacity(0.04)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.title). \(item.description)")
        .accessibilityValue(item.isCompleted ? "Completed" : "Not completed")
        .accessibilityHint("Double tap to \(item.isCompleted ? "uncheck" : "check") this item")
    }
}

// MARK: - Checkbox View

struct CheckboxView: View {
    let isChecked: Bool
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isChecked ? color.opacity(0.2) : Color.white.opacity(0.06))
                .frame(width: 28, height: 28)

            RoundedRectangle(cornerRadius: 8)
                .stroke(isChecked ? color : Color.white.opacity(0.2), lineWidth: 1.5)
                .frame(width: 28, height: 28)

            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isChecked)
    }
}

// MARK: - Progress Bar

struct ProgressBarView: View {
    let progress: Double
    let colors: [Color]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.08))

                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * max(0, min(1, progress)))
                    .animation(.easeOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress: \(Int(progress * 100)) percent")
    }
}
