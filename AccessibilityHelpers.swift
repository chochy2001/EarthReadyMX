import SwiftUI

// MARK: - Accessibility Announcements

enum AccessibilityAnnouncement {
    static func announce(_ message: String) {
        UIAccessibility.post(
            notification: .announcement,
            argument: message
        )
    }

    static func announceScreenChange(_ message: String) {
        UIAccessibility.post(
            notification: .screenChanged,
            argument: message
        )
    }

    static func announceLayoutChange(_ message: String? = nil) {
        UIAccessibility.post(
            notification: .layoutChanged,
            argument: message
        )
    }
}
