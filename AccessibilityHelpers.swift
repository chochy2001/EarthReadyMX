import SwiftUI

// MARK: - Accessibility Announcements

@MainActor
enum AccessibilityAnnouncement {
    static func announceScreenChange(_ message: String) {
        UIAccessibility.post(
            notification: .screenChanged,
            argument: message
        )
    }
}
