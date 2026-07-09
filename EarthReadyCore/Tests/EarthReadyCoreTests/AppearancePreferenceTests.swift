import XCTest
import SwiftUI
@testable import EarthReadyCore

final class AppearancePreferenceTests: XCTestCase {

    func testSystemMapsToNilColorScheme() {
        XCTAssertNil(AppearancePreference.system.colorScheme)
    }

    func testLightMapsToLightColorScheme() {
        XCTAssertEqual(AppearancePreference.light.colorScheme, .light)
    }

    func testDarkMapsToDarkColorScheme() {
        XCTAssertEqual(AppearancePreference.dark.colorScheme, .dark)
    }

    func testAllCasesHaveDistinctNonEmptyLabels() {
        let labels = AppearancePreference.allCases.map(\.label)
        XCTAssertEqual(Set(labels).count, labels.count)
        XCTAssertTrue(labels.allSatisfy { !$0.isEmpty })
    }

    func testIdMatchesRawValue() {
        for preference in AppearancePreference.allCases {
            XCTAssertEqual(preference.id, preference.rawValue)
        }
    }

    func testStorageKeyIsStable() {
        // The app reads/writes this exact key via @AppStorage; changing it
        // silently would reset every user's saved preference.
        XCTAssertEqual(AppearancePreference.storageKey, "colorScheme")
    }
}
