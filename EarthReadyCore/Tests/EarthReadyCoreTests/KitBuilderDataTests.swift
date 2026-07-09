import XCTest
@testable import EarthReadyCore

final class KitBuilderDataTests: XCTestCase {

    func testEssentialAndDangerousItemsAreDisjoint() {
        // An item classified in both sets would break the kit-building game
        // (it could be scored as both correct and incorrect).
        let essentialNames = Set(KitBuilderData.essentialItems().map(\.name))
        let dangerousNames = Set(KitBuilderData.dangerousItems().map(\.name))
        XCTAssertTrue(essentialNames.isDisjoint(with: dangerousNames))
    }

    func testEssentialAndDistractorItemsAreDisjoint() {
        let essentialNames = Set(KitBuilderData.essentialItems().map(\.name))
        let distractorNames = Set(KitBuilderData.distractorItems().map(\.name))
        XCTAssertTrue(essentialNames.isDisjoint(with: distractorNames))
    }

    func testAllItemNamesAreUnique() {
        let names = KitBuilderData.allItems().map(\.name)
        XCTAssertEqual(Set(names).count, names.count)
    }

    func testEssentialItemsAllHavePositivePoints() {
        for item in KitBuilderData.essentialItems() {
            XCTAssertGreaterThan(item.points, 0, "\(item.name) is essential and must reward positive points")
        }
    }

    func testDangerousAndDistractorItemsHaveNonPositivePoints() {
        for item in KitBuilderData.dangerousItems() + KitBuilderData.distractorItems() {
            XCTAssertLessThan(item.points, 0, "\(item.name) is not essential and must penalize points")
        }
    }

    func testItemsForSessionAlwaysIncludesAllEssentials() {
        for _ in 0..<20 {
            let session = KitBuilderData.itemsForSession()
            let essentialNames = Set(KitBuilderData.essentialItems().map(\.name))
            let sessionNames = Set(session.map(\.name))
            XCTAssertTrue(essentialNames.isSubset(of: sessionNames), "every session must keep all 10 essential items")
        }
    }

    func testItemsForSessionHasNoDuplicateItems() {
        for _ in 0..<20 {
            let session = KitBuilderData.itemsForSession()
            let ids = session.map(\.id)
            XCTAssertEqual(Set(ids).count, ids.count, "a session must never repeat the same item twice")
        }
    }

    func testItemsForSessionAddsAtMostSixNonEssentialItems() {
        for _ in 0..<20 {
            let session = KitBuilderData.itemsForSession()
            let nonEssentialCount = session.filter { $0.category != .essential }.count
            XCTAssertLessThanOrEqual(nonEssentialCount, 6)
        }
    }
}
