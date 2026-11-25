import Foundation
import SwiftUI

/// Coordinates tap cooldowns and single-flight execution to prevent duplicate
/// actions caused by rapid multi-taps.
@MainActor
public final class TapActionGuard: ObservableObject {
    public static let defaultCooldown: TimeInterval = 0.5

    public let cooldown: TimeInterval
    private let clock: @Sendable () -> TimeInterval
    private var lastTriggerTime: TimeInterval?

    @Published public private(set) var isInFlight: Bool = false

    public init(
        cooldown: TimeInterval = TapActionGuard.defaultCooldown,
        clock: @escaping @Sendable () -> TimeInterval = { ProcessInfo.processInfo.systemUptime }
    ) {
        self.cooldown = max(0, cooldown)
        self.clock = clock
    }

    /// Returns `true` and records the trigger timestamp when no single-flight lock
    /// is active and the cooldown window has elapsed (or when `cooldown <= 0`).
    public func shouldAllowTap(cooldown overrideCooldown: TimeInterval? = nil) -> Bool {
        guard !isInFlight else { return false }
        let effectiveCooldown = max(0, overrideCooldown ?? cooldown)
        guard effectiveCooldown > 0 else {
            lastTriggerTime = clock()
            return true
        }

        let now = clock()
        if let last = lastTriggerTime, now - last < effectiveCooldown {
            return false
        }
        lastTriggerTime = now
        return true
    }

    /// Executes `action` when allowed by the cooldown and single-flight state.
    @discardableResult
    public func perform(
        cooldown overrideCooldown: TimeInterval? = nil,
        _ action: () -> Void
    ) -> Bool {
        guard shouldAllowTap(cooldown: overrideCooldown) else { return false }
        action()
        return true
    }

    /// Acquires an exclusive single-flight lock while an operation is active.
    public func beginSingleFlight() -> Bool {
        guard !isInFlight else { return false }
        isInFlight = true
        return true
    }

    /// Releases the single-flight lock.
    public func endSingleFlight() {
        isInFlight = false
    }

    /// Clears cooldown history and any active single-flight lock.
    public func reset() {
        lastTriggerTime = nil
        isInFlight = false
    }
}

/// A `Button` wrapper that suppresses rapid duplicate taps within a cooldown window.
/// Pass `cooldown: 0` to opt out of throttling while keeping the same call site API.
public struct GuardedButton<Label: View>: View {
    private let role: ButtonRole?
    private let cooldown: TimeInterval
    private let action: () -> Void
    private let label: () -> Label

    @StateObject private var tapGuard = TapActionGuard()

    public init(
        role: ButtonRole? = nil,
        cooldown: TimeInterval = TapActionGuard.defaultCooldown,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.role = role
        self.cooldown = cooldown
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(role: role) {
            tapGuard.perform(cooldown: cooldown, action)
        } label: {
            label()
        }
    }
}

public extension GuardedButton where Label == Text {
    init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        cooldown: TimeInterval = TapActionGuard.defaultCooldown,
        action: @escaping () -> Void
    ) {
        self.init(role: role, cooldown: cooldown, action: action) {
            Text(titleKey)
        }
    }

    @_disfavoredOverload
    init<S: StringProtocol>(
        _ title: S,
        role: ButtonRole? = nil,
        cooldown: TimeInterval = TapActionGuard.defaultCooldown,
        action: @escaping () -> Void
    ) {
        self.init(role: role, cooldown: cooldown, action: action) {
            Text(title)
        }
    }
}
