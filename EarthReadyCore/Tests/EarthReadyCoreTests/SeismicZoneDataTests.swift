import XCTest
@testable import EarthReadyCore

final class SeismicZoneDataTests: XCTestCase {

    func testAllCountriesReturnsFourCountries() {
        let countries = SeismicZoneData.allCountries()
        XCTAssertEqual(countries.count, 4)
        XCTAssertEqual(Set(countries.map(\.name)).count, 4, "country names must be unique")
    }

    func testEveryCountryHasAtLeastOneStateAndOneHistoricalEarthquake() {
        for country in SeismicZoneData.allCountries() {
            XCTAssertFalse(country.states.isEmpty, "\(country.name) must list at least one state or region")
            XCTAssertFalse(country.historicalEarthquakes.isEmpty, "\(country.name) must list at least one historical earthquake")
        }
    }

    func testEveryStateHasNonEmptyNameAndDescription() {
        for country in SeismicZoneData.allCountries() {
            for state in country.states {
                XCTAssertFalse(state.name.trimmingCharacters(in: .whitespaces).isEmpty, "\(country.name) has a state with an empty name")
                XCTAssertFalse(state.description.trimmingCharacters(in: .whitespaces).isEmpty, "\(state.name) in \(country.name) has an empty description")
            }
        }
    }

    func testStateNamesAreUniqueWithinEachCountry() {
        for country in SeismicZoneData.allCountries() {
            let names = country.states.map(\.name)
            XCTAssertEqual(Set(names).count, names.count, "\(country.name) has duplicate state names")
        }
    }

    func testHistoricalEarthquakesHavePlausibleMagnitudesAndYears() {
        for country in SeismicZoneData.allCountries() {
            for quake in country.historicalEarthquakes {
                XCTAssertGreaterThan(quake.magnitude, 0, "\(quake.location) has a non-positive magnitude")
                XCTAssertLessThan(quake.magnitude, 10, "\(quake.location) has an implausibly high magnitude")
                XCTAssertGreaterThanOrEqual(quake.year, 1900, "\(quake.location) has an implausibly old year")
                XCTAssertLessThanOrEqual(quake.year, 2026, "\(quake.location) has a year in the future")
            }
        }
    }

    func testRiskLevelHasNonEmptyLabelDescriptionAndSafetyTips() {
        for level in SeismicRiskLevel.allCases {
            XCTAssertFalse(level.label.isEmpty)
            XCTAssertFalse(level.description.isEmpty)
            XCTAssertFalse(level.safetyTips.isEmpty, "\(level.label) must provide at least one safety tip")
        }
    }

    func testMexicoIncludesTheGuerreroGapAsVeryHighRisk() {
        let mexico = SeismicZoneData.mexico()
        let guerrero = mexico.states.first { $0.name == "Guerrero" }
        XCTAssertEqual(guerrero?.riskLevel, .veryHigh)
    }
}
