import XCTest
@testable import EarthReadyCore

@MainActor
final class GameStateTests: XCTestCase {

    private func makeIsolatedDefaults(_ testName: String = #function) -> UserDefaults {
        let suiteName = "EarthReadyCoreTests.\(testName).\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        addTeardownBlock {
            defaults.removePersistentDomain(forName: suiteName)
        }
        return defaults
    }

    // MARK: - Checklist persistence

    func testChecklistStateRoundTripsThroughUserDefaults() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)

        let category = state.checklistCategories[0]
        let item = category.items[0]
        state.toggleChecklistItem(categoryId: category.id, itemId: item.id)

        let reloaded = GameState(userDefaults: defaults)
        let reloadedItem = reloaded.checklistCategories[0].items[0]
        XCTAssertTrue(reloadedItem.isCompleted, "completed item must survive a reload from the same UserDefaults suite")
    }

    func testLoadChecklistStateDoesNotCrashWhenItemsAreRenamed() {
        let defaults = makeIsolatedDefaults()
        // Simulate stale persisted keys from items that no longer exist.
        defaults.set(["Nonexistent Category::Nonexistent Item"], forKey: "checklist_completed_items")

        let state = GameState(userDefaults: defaults)

        XCTAssertEqual(state.completedChecklistItems, 0, "stale keys must not match any current item")
    }

    func testResetAllClearsAllFourPersistedKeys() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)

        let category = state.checklistCategories[0]
        state.toggleChecklistItem(categoryId: category.id, itemId: category.items[0].id)
        state.markSeismicZonesVisited()
        state.markRoomScannerUsed()
        state.score = 5
        state.totalQuestions = 5
        state.saveBestScoreIfNeeded()

        state.resetAll()

        XCTAssertNil(defaults.array(forKey: "checklist_completed_items"))
        XCTAssertFalse(defaults.bool(forKey: "seismic_zones_visited"))
        XCTAssertFalse(defaults.bool(forKey: "room_scanner_used"))
        XCTAssertEqual(state.completedChecklistItems, 0)
        XCTAssertFalse(state.seismicZonesVisited)
        XCTAssertFalse(state.roomScannerUsed)
    }

    func testResetAllDoesNotClearBestScore() {
        // resetAll intentionally preserves the best score across playthroughs.
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)
        state.score = 5
        state.totalQuestions = 5
        state.saveBestScoreIfNeeded()
        XCTAssertEqual(state.bestScore, 100)

        state.resetAll()

        XCTAssertEqual(state.bestScore, 100)
    }

    // MARK: - Best score logic

    func testSaveBestScoreIfNeededOnlyStoresHigherScore() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)

        state.score = 3
        state.totalQuestions = 5
        state.saveBestScoreIfNeeded()
        XCTAssertEqual(state.bestScore, 60)

        state.score = 1
        state.totalQuestions = 5
        state.saveBestScoreIfNeeded()
        XCTAssertEqual(state.bestScore, 60, "a worse score must never lower the persisted best score")

        state.score = 5
        state.totalQuestions = 5
        state.saveBestScoreIfNeeded()
        XCTAssertEqual(state.bestScore, 100, "a better score must replace the persisted best score")
    }

    // MARK: - Quiz logic

    func testShuffleQuizPreservesAllScenariosAndOptions() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)

        let situationsBefore = Set(state.scenarios.map(\.situation))
        state.shuffleQuiz()
        let situationsAfter = Set(state.scenarios.map(\.situation))

        XCTAssertEqual(state.scenarios.count, 5)
        XCTAssertEqual(situationsBefore, situationsAfter)
        for scenario in state.scenarios {
            XCTAssertTrue(scenario.options.contains(where: \.isCorrect), "every scenario must keep exactly one correct option after shuffling")
        }
    }

    func testAnswerScenarioTracksScoreAndCount() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)
        let scenario = state.scenarios[0]

        state.answerScenario(scenario, correct: true)

        XCTAssertEqual(state.score, 1)
        XCTAssertEqual(state.totalQuestions, 1)
        XCTAssertEqual(state.answeredScenarios[scenario.id], true)
    }

    func testAnswerScenarioSavesBestScoreOnlyWhenAllScenariosAnswered() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)

        for scenario in state.scenarios.dropLast() {
            state.answerScenario(scenario, correct: true)
        }
        XCTAssertEqual(state.bestScore, 0, "best score must not be saved before the quiz is complete")

        state.answerScenario(state.scenarios.last!, correct: true)
        XCTAssertEqual(state.bestScore, 100)
    }

    func testResetQuizClearsProgressAndReshufflesScenarios() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)
        state.answerScenario(state.scenarios[0], correct: true)
        state.currentPhase = .result

        state.resetQuiz()

        XCTAssertEqual(state.currentPhase, .splash)
        XCTAssertEqual(state.score, 0)
        XCTAssertEqual(state.totalQuestions, 0)
        XCTAssertTrue(state.answeredScenarios.isEmpty)
        XCTAssertEqual(state.scenarios.count, 5)
    }

    func testScorePercentageHandlesZeroQuestionsWithoutDividingByZero() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)
        XCTAssertEqual(state.scorePercentage, 0)
    }

    // MARK: - Checklist progress

    func testToggleChecklistItemTogglesCompletionAndPersists() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)
        let category = state.checklistCategories[0]
        let item = category.items[0]

        state.toggleChecklistItem(categoryId: category.id, itemId: item.id)
        XCTAssertTrue(state.checklistCategories[0].items[0].isCompleted)

        state.toggleChecklistItem(categoryId: category.id, itemId: item.id)
        XCTAssertFalse(state.checklistCategories[0].items[0].isCompleted)
    }

    func testToggleChecklistGroupTogglesOnlyMatchingPriority() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)
        let category = state.checklistCategories[0]
        let criticalCount = category.items.filter { $0.priority == .critical }.count
        XCTAssertGreaterThan(criticalCount, 0)

        state.toggleChecklistGroup(categoryId: category.id, priority: .critical)

        let updated = state.checklistCategories[0]
        for item in updated.items where item.priority == .critical {
            XCTAssertTrue(item.isCompleted)
        }
        for item in updated.items where item.priority != .critical {
            XCTAssertFalse(item.isCompleted)
        }

        // Toggling again while all-critical are complete must turn them off.
        state.toggleChecklistGroup(categoryId: category.id, priority: .critical)
        for item in state.checklistCategories[0].items where item.priority == .critical {
            XCTAssertFalse(item.isCompleted)
        }
    }

    func testChecklistPercentageAndCompletionFlags() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)
        XCTAssertEqual(state.checklistPercentage, 0)
        XCTAssertFalse(state.isChecklistCompleted)

        for category in state.checklistCategories {
            for item in category.items {
                state.toggleChecklistItem(categoryId: category.id, itemId: item.id)
            }
        }

        XCTAssertEqual(state.checklistPercentage, 100)
        XCTAssertTrue(state.isChecklistCompleted)
    }

    // MARK: - Completion flags

    func testMarkSeismicZonesVisitedIsIdempotentAndPersists() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)
        XCTAssertFalse(state.isSeismicZonesCompleted)

        state.markSeismicZonesVisited()
        XCTAssertTrue(state.isSeismicZonesCompleted)
        XCTAssertTrue(defaults.bool(forKey: "seismic_zones_visited"))

        // Calling again must not throw or change state.
        state.markSeismicZonesVisited()
        XCTAssertTrue(state.isSeismicZonesCompleted)
    }

    func testMarkRoomScannerUsedIsIdempotentAndPersists() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)
        XCTAssertFalse(state.isRoomScannerCompleted)

        state.markRoomScannerUsed()
        XCTAssertTrue(state.isRoomScannerCompleted)
        XCTAssertTrue(defaults.bool(forKey: "room_scanner_used"))
    }

    func testAllSectionsCompletedRequiresEverySection() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)
        XCTAssertFalse(state.allSectionsCompleted)

        state.learnPhasesCompleted = Set(EarthquakePhase.allCases)
        state.kitEssentialsFound = 10
        state.drillCompleted = true
        state.markSeismicZonesVisited()
        state.markRoomScannerUsed()
        for category in state.checklistCategories {
            for item in category.items {
                state.toggleChecklistItem(categoryId: category.id, itemId: item.id)
            }
        }

        XCTAssertTrue(state.allSectionsCompleted)
    }

    // MARK: - Messages

    func testScoreMessageThresholds() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)

        state.totalQuestions = 10
        state.score = 10
        XCTAssertEqual(state.scoreMessage, "Perfect! You're fully prepared.")

        state.score = 8
        XCTAssertEqual(state.scoreMessage, "Great job! You know your safety protocols well.")

        state.score = 6
        XCTAssertEqual(state.scoreMessage, "Good effort! Review the tips to improve.")

        state.score = 3
        XCTAssertEqual(state.scoreMessage, "Keep learning! Earthquake preparedness saves lives.")
    }

    func testTipsForFiltersByPhase() {
        let defaults = makeIsolatedDefaults()
        let state = GameState(userDefaults: defaults)

        for phase in EarthquakePhase.allCases {
            let tips = state.tipsFor(phase: phase)
            XCTAssertFalse(tips.isEmpty, "each phase must have at least one safety tip")
            XCTAssertTrue(tips.allSatisfy { $0.phase == phase })
        }
    }
}
