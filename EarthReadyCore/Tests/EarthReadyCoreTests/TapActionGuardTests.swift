import XCTest
@testable import EarthReadyCore

private final class TestClock: @unchecked Sendable {
    var now: TimeInterval = 100.0
}

@MainActor
final class TapActionGuardTests: XCTestCase {

    func testDefaultCooldownIsHalfSecond() {
        XCTAssertEqual(TapActionGuard.defaultCooldown, 0.5)
        let guardObj = TapActionGuard()
        XCTAssertEqual(guardObj.cooldown, 0.5)
    }

    func testRapidTapsWithinCooldownAreBlocked() {
        let clock = TestClock()
        let tapGuard = TapActionGuard(clock: { clock.now })
        var count = 0

        XCTAssertTrue(tapGuard.perform { count += 1 })
        XCTAssertFalse(tapGuard.perform { count += 1 })

        clock.now += 0.49
        XCTAssertFalse(tapGuard.perform { count += 1 })
        XCTAssertEqual(count, 1)

        clock.now += 0.01
        XCTAssertTrue(tapGuard.perform { count += 1 })
        XCTAssertEqual(count, 2)
    }

    func testZeroCooldownOptsOutOfThrottling() {
        let clock = TestClock()
        let tapGuard = TapActionGuard(cooldown: 0, clock: { clock.now })
        var count = 0

        XCTAssertTrue(tapGuard.perform { count += 1 })
        XCTAssertTrue(tapGuard.perform { count += 1 })
        XCTAssertTrue(tapGuard.perform { count += 1 })
        XCTAssertEqual(count, 3)
    }

    func testZeroOverrideCooldownOptsOutEvenWhenDefaultIsNonZero() {
        let clock = TestClock()
        let tapGuard = TapActionGuard(cooldown: 0.5, clock: { clock.now })
        var count = 0

        XCTAssertTrue(tapGuard.perform(cooldown: 0) { count += 1 })
        XCTAssertTrue(tapGuard.perform(cooldown: 0) { count += 1 })
        XCTAssertEqual(count, 2)
    }

    func testSingleFlightLockBlocksUntilEnded() {
        let clock = TestClock()
        let tapGuard = TapActionGuard(cooldown: 0, clock: { clock.now })

        XCTAssertTrue(tapGuard.beginSingleFlight())
        XCTAssertTrue(tapGuard.isInFlight)
        XCTAssertFalse(tapGuard.beginSingleFlight())
        XCTAssertFalse(tapGuard.shouldAllowTap())

        tapGuard.endSingleFlight()
        XCTAssertFalse(tapGuard.isInFlight)
        XCTAssertTrue(tapGuard.beginSingleFlight())
    }

    func testResetClearsCooldownAndSingleFlightState() {
        let clock = TestClock()
        let tapGuard = TapActionGuard(cooldown: 0.5, clock: { clock.now })

        XCTAssertTrue(tapGuard.shouldAllowTap())
        XCTAssertTrue(tapGuard.beginSingleFlight())
        XCTAssertFalse(tapGuard.shouldAllowTap())

        tapGuard.reset()
        XCTAssertFalse(tapGuard.isInFlight)
        XCTAssertTrue(tapGuard.shouldAllowTap())
    }
}
