import XCTest
@testable import EarthReadyCore

final class ChecklistDataTests: XCTestCase {

    func testAllCategoriesHaveUniqueTitles() {
        let categories = ChecklistData.allCategories()
        let titles = categories.map(\.title)
        XCTAssertEqual(Set(titles).count, titles.count, "duplicate category titles would break GameState's persistence keys")
    }

    func testEveryCategoryHasNonEmptyItems() {
        let categories = ChecklistData.allCategories()
        for category in categories {
            XCTAssertFalse(category.items.isEmpty, "\(category.title) must have at least one checklist item")
        }
    }

    func testItemTitlesAreUniqueWithinEachCategory() {
        // GameState derives persistence keys from "categoryTitle::itemTitle"; a
        // duplicate item title within the same category would collide.
        for category in ChecklistData.allCategories() {
            let titles = category.items.map(\.title)
            XCTAssertEqual(Set(titles).count, titles.count, "\(category.title) has duplicate item titles")
        }
    }

    func testAllItemsStartIncomplete() {
        for category in ChecklistData.allCategories() {
            for item in category.items {
                XCTAssertFalse(item.isCompleted, "freshly generated checklist items must start incomplete")
            }
        }
    }

    func testAllItemsHaveNonEmptyTitleAndDescription() {
        for category in ChecklistData.allCategories() {
            for item in category.items {
                XCTAssertFalse(item.title.trimmingCharacters(in: .whitespaces).isEmpty)
                XCTAssertFalse(item.description.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
