import SwiftUI

enum AppPhase: Equatable, Sendable {
    case splash
    case learn
    case simulation
    case result
    case checklist
}

// MARK: - Checklist Models

enum ChecklistPriority: Int, CaseIterable, Sendable {
    case critical = 0
    case important = 1
    case recommended = 2

    var label: String {
        switch self {
        case .critical: return "Critical"
        case .important: return "Important"
        case .recommended: return "Recommended"
        }
    }

    var color: Color {
        switch self {
        case .critical: return .red
        case .important: return .orange
        case .recommended: return .blue
        }
    }

    var icon: String {
        switch self {
        case .critical: return "exclamationmark.triangle.fill"
        case .important: return "exclamationmark.circle.fill"
        case .recommended: return "info.circle.fill"
        }
    }
}

struct ChecklistItem: Identifiable, Sendable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let priority: ChecklistPriority
    var isCompleted: Bool = false
}

struct ChecklistCategory: Identifiable, Sendable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let gradientColors: [Color]
    var items: [ChecklistItem]

    var completedCount: Int { items.filter(\.isCompleted).count }
    var totalCount: Int { items.count }
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    var isComplete: Bool { completedCount == totalCount }
}

enum EarthquakePhase: String, CaseIterable, Sendable {
    case before = "Before"
    case during = "During"
    case after = "After"
}

struct SafetyTip: Identifiable, Sendable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let phase: EarthquakePhase
}

struct SimulationScenario: Identifiable, Sendable {
    let id = UUID()
    let situation: String
    let options: [SimulationOption]
    let explanation: String
}

struct SimulationOption: Identifiable, Sendable {
    let id = UUID()
    let text: String
    let isCorrect: Bool
}

@MainActor
class GameState: ObservableObject {
    @Published var currentPhase: AppPhase = .splash
    @Published var score: Int = 0
    @Published var totalQuestions: Int = 0
    @Published var answeredScenarios: [UUID: Bool] = [:]
    @Published var learnPhasesCompleted: Set<EarthquakePhase> = []
    @Published var checklistCategories: [ChecklistCategory] = ChecklistData.allCategories()

    // MARK: - Persistence
    private static let checklistKey = "checklist_completed_items"
    private static let bestScoreKey = "best_quiz_score"

    init() {
        loadChecklistState()
    }

    private func stableKey(categoryTitle: String, itemTitle: String) -> String {
        "\(categoryTitle)::\(itemTitle)"
    }

    func saveChecklistState() {
        var completedKeys: [String] = []
        for category in checklistCategories {
            for item in category.items where item.isCompleted {
                completedKeys.append(stableKey(categoryTitle: category.title, itemTitle: item.title))
            }
        }
        UserDefaults.standard.set(completedKeys, forKey: Self.checklistKey)
    }

    func loadChecklistState() {
        guard let completedKeys = UserDefaults.standard.stringArray(forKey: Self.checklistKey) else { return }
        let completedSet = Set(completedKeys)
        for catIndex in checklistCategories.indices {
            for itemIndex in checklistCategories[catIndex].items.indices {
                let key = stableKey(
                    categoryTitle: checklistCategories[catIndex].title,
                    itemTitle: checklistCategories[catIndex].items[itemIndex].title
                )
                if completedSet.contains(key) {
                    checklistCategories[catIndex].items[itemIndex].isCompleted = true
                }
            }
        }
    }

    func saveBestScoreIfNeeded() {
        let currentBest = UserDefaults.standard.integer(forKey: Self.bestScoreKey)
        let currentPercentage = Int(scorePercentage)
        if currentPercentage > currentBest {
            UserDefaults.standard.set(currentPercentage, forKey: Self.bestScoreKey)
        }
    }

    var bestScore: Int {
        UserDefaults.standard.integer(forKey: Self.bestScoreKey)
    }

    let safetyTips: [SafetyTip] = [
        SafetyTip(
            icon: "bag.fill",
            title: "Emergency Kit",
            description: "Prepare a kit with water, food, flashlight, first-aid supplies, and important documents. Keep it accessible.",
            phase: .before
        ),
        SafetyTip(
            icon: "map.fill",
            title: "Evacuation Routes",
            description: "Identify safe exit routes from your home, school, and workplace. Practice them regularly.",
            phase: .before
        ),
        SafetyTip(
            icon: "person.3.fill",
            title: "Family Plan",
            description: "Establish a meeting point and communication plan with your family. Choose an out-of-area contact.",
            phase: .before
        ),
        SafetyTip(
            icon: "wrench.and.screwdriver.fill",
            title: "Secure Your Space",
            description: "Anchor heavy furniture, water heaters, and appliances. Store heavy objects on lower shelves.",
            phase: .before
        ),
        SafetyTip(
            icon: "arrow.down.to.line",
            title: "Drop, Cover, Hold",
            description: "DROP to your hands and knees. Take COVER under a sturdy desk or table. HOLD ON until shaking stops.",
            phase: .during
        ),
        SafetyTip(
            icon: "building.2.fill",
            title: "Stay Indoors",
            description: "If inside, stay inside. Move away from windows, mirrors, and heavy objects that could fall.",
            phase: .during
        ),
        SafetyTip(
            icon: "car.fill",
            title: "If Driving",
            description: "Pull over to a safe area away from buildings, overpasses, and power lines. Stay in the vehicle.",
            phase: .during
        ),
        SafetyTip(
            icon: "tree.fill",
            title: "If Outdoors",
            description: "Move to an open area away from buildings, streetlights, and utility wires. Drop and cover your head.",
            phase: .during
        ),
        SafetyTip(
            icon: "exclamationmark.triangle.fill",
            title: "Check for Hazards",
            description: "Look for gas leaks, damaged wiring, and structural damage. If you smell gas, leave immediately.",
            phase: .after
        ),
        SafetyTip(
            icon: "phone.fill",
            title: "Communicate",
            description: "Text instead of calling to keep phone lines open for emergencies. Check on neighbors.",
            phase: .after
        ),
        SafetyTip(
            icon: "arrow.triangle.2.circlepath",
            title: "Expect Aftershocks",
            description: "Be prepared for aftershocks. They can occur minutes, hours, or even days after the main quake.",
            phase: .after
        ),
        SafetyTip(
            icon: "radio.fill",
            title: "Stay Informed",
            description: "Listen to official emergency broadcasts. Follow instructions from local authorities.",
            phase: .after
        )
    ]

    let scenarios: [SimulationScenario] = [
        SimulationScenario(
            situation: "You're in a classroom on the 3rd floor when strong shaking begins. What do you do?",
            options: [
                SimulationOption(text: "Run to the stairs immediately", isCorrect: false),
                SimulationOption(text: "Drop, cover under a desk, and hold on", isCorrect: true),
                SimulationOption(text: "Stand in the doorway", isCorrect: false),
                SimulationOption(text: "Jump out the window", isCorrect: false)
            ],
            explanation: "Drop, Cover, and Hold On is the safest action. Running during shaking can cause falls and injuries. Doorways are not safer than other spots in modern buildings."
        ),
        SimulationScenario(
            situation: "The shaking has stopped. You notice a strong gas smell in your apartment. What's your priority?",
            options: [
                SimulationOption(text: "Light a match to check for the source", isCorrect: false),
                SimulationOption(text: "Open windows and evacuate immediately", isCorrect: true),
                SimulationOption(text: "Call 911 from inside the building", isCorrect: false),
                SimulationOption(text: "Ignore it and wait for help", isCorrect: false)
            ],
            explanation: "Gas leaks can cause explosions. Never use flames or electrical switches. Evacuate first, then call emergency services from outside."
        ),
        SimulationScenario(
            situation: "You're walking on the street when an earthquake hits. Buildings are on both sides. What do you do?",
            options: [
                SimulationOption(text: "Run inside the nearest building", isCorrect: false),
                SimulationOption(text: "Keep walking normally", isCorrect: false),
                SimulationOption(text: "Move to an open area, drop and protect your head", isCorrect: true),
                SimulationOption(text: "Stand against a building wall", isCorrect: false)
            ],
            explanation: "In the open, move away from buildings, power lines, and trees. Drop down and protect your head and neck with your arms."
        ),
        SimulationScenario(
            situation: "After the earthquake, you want to check on your family. The phone lines are overwhelmed. Best approach?",
            options: [
                SimulationOption(text: "Keep calling repeatedly", isCorrect: false),
                SimulationOption(text: "Send text messages instead", isCorrect: true),
                SimulationOption(text: "Drive across the city to find them", isCorrect: false),
                SimulationOption(text: "Post on social media and wait", isCorrect: false)
            ],
            explanation: "Text messages use less bandwidth than calls and are more likely to get through. Having a pre-arranged meeting point is even better."
        ),
        SimulationScenario(
            situation: "You feel a small aftershock while inspecting damage in your building. What should you do?",
            options: [
                SimulationOption(text: "Ignore it, aftershocks are harmless", isCorrect: false),
                SimulationOption(text: "Drop, cover, and hold on again", isCorrect: true),
                SimulationOption(text: "Run outside as fast as possible", isCorrect: false),
                SimulationOption(text: "Go to the roof for safety", isCorrect: false)
            ],
            explanation: "Treat every aftershock like a new earthquake. Drop, Cover, and Hold On. Aftershocks can sometimes be as strong as the main quake."
        )
    ]

    func tipsFor(phase: EarthquakePhase) -> [SafetyTip] {
        safetyTips.filter { $0.phase == phase }
    }

    func answerScenario(_ scenario: SimulationScenario, correct: Bool) {
        answeredScenarios[scenario.id] = correct
        totalQuestions += 1
        if correct {
            score += 1
        }
        if answeredScenarios.count == scenarios.count {
            saveBestScoreIfNeeded()
        }
    }

    func resetQuiz() {
        currentPhase = .splash
        score = 0
        totalQuestions = 0
        answeredScenarios = [:]
        learnPhasesCompleted = []
    }

    func resetAll() {
        currentPhase = .splash
        score = 0
        totalQuestions = 0
        answeredScenarios = [:]
        learnPhasesCompleted = []
        checklistCategories = ChecklistData.allCategories()
        UserDefaults.standard.removeObject(forKey: Self.checklistKey)
    }

    var scorePercentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }

    // MARK: - Checklist

    var totalChecklistItems: Int {
        checklistCategories.reduce(0) { $0 + $1.totalCount }
    }

    var completedChecklistItems: Int {
        checklistCategories.reduce(0) { $0 + $1.completedCount }
    }

    var checklistProgress: Double {
        guard totalChecklistItems > 0 else { return 0 }
        return Double(completedChecklistItems) / Double(totalChecklistItems)
    }

    var checklistPercentage: Int {
        Int(checklistProgress * 100)
    }

    func toggleChecklistItem(categoryId: UUID, itemId: UUID) {
        guard let catIndex = checklistCategories.firstIndex(where: { $0.id == categoryId }),
              let itemIndex = checklistCategories[catIndex].items.firstIndex(where: { $0.id == itemId }) else {
            return
        }
        checklistCategories[catIndex].items[itemIndex].isCompleted.toggle()
        saveChecklistState()
    }

    var checklistMotivationalMessage: String {
        let pct = checklistPercentage
        if pct == 0 {
            return "Every journey starts with a single step. Begin preparing today."
        } else if pct < 25 {
            return "Great start! You're taking the first steps to protect your family."
        } else if pct < 50 {
            return "You're making real progress. Keep going!"
        } else if pct < 75 {
            return "Over halfway there! Your preparedness level is impressive."
        } else if pct < 100 {
            return "Almost there! You're among the most prepared people."
        } else {
            return "Outstanding! You and your family are fully prepared."
        }
    }

    var scoreMessage: String {
        let pct = scorePercentage
        if pct == 100 {
            return "Perfect! You're fully prepared."
        } else if pct >= 80 {
            return "Great job! You know your safety protocols well."
        } else if pct >= 60 {
            return "Good effort! Review the tips to improve."
        } else {
            return "Keep learning! Earthquake preparedness saves lives."
        }
    }
}
