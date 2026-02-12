import Foundation

enum KitItemCategory: Sendable {
    case essential
    case dangerous
    case distractor
}

struct KitItem: Identifiable, Sendable {
    let id: UUID
    let icon: String
    let name: String
    let explanation: String
    let category: KitItemCategory
    let points: Int

    init(
        id: UUID = UUID(),
        icon: String,
        name: String,
        explanation: String,
        category: KitItemCategory,
        points: Int
    ) {
        self.id = id
        self.icon = icon
        self.name = name
        self.explanation = explanation
        self.category = category
        self.points = points
    }
}

enum KitBuilderData {

    // MARK: - All Items

    static func allItems() -> [KitItem] {
        essentialItems() + dangerousItems() + distractorItems()
    }

    // MARK: - Essential Items (correct for emergency kit)

    static func essentialItems() -> [KitItem] {
        [
            KitItem(
                icon: "drop.fill",
                name: "Bottled Water",
                explanation: "Water is the most critical supply. You need at least 1 gallon per person per day for 3 days.",
                category: .essential,
                points: 15
            ),
            KitItem(
                icon: "fork.knife",
                name: "Non-perishable Food",
                explanation: "Canned goods, energy bars, and dried food last long and require no refrigeration.",
                category: .essential,
                points: 15
            ),
            KitItem(
                icon: "cross.case.fill",
                name: "First Aid Kit",
                explanation: "Bandages, antiseptic, pain relievers, and prescription medications can save lives after an earthquake.",
                category: .essential,
                points: 15
            ),
            KitItem(
                icon: "flashlight.on.fill",
                name: "Flashlight",
                explanation: "Power outages are common after earthquakes. A flashlight is safer than candles.",
                category: .essential,
                points: 10
            ),
            KitItem(
                icon: "speaker.wave.3.fill",
                name: "Emergency Whistle",
                explanation: "A whistle helps rescuers find you if trapped under debris. Sound carries farther than your voice.",
                category: .essential,
                points: 10
            ),
            KitItem(
                icon: "doc.text.fill",
                name: "Important Documents",
                explanation: "Copies of IDs, insurance, and medical records in a waterproof bag are essential for recovery.",
                category: .essential,
                points: 10
            ),
            KitItem(
                icon: "radio.fill",
                name: "Battery Radio",
                explanation: "When power and internet are down, a battery or hand-crank radio keeps you informed of emergency broadcasts.",
                category: .essential,
                points: 10
            ),
            KitItem(
                icon: "battery.100.bolt",
                name: "Power Bank",
                explanation: "A charged portable battery keeps your phone alive for emergency calls and information.",
                category: .essential,
                points: 10
            ),
            KitItem(
                icon: "banknote.fill",
                name: "Cash",
                explanation: "ATMs and card readers will not work without power. Small bills are essential for purchases.",
                category: .essential,
                points: 5
            ),
            KitItem(
                icon: "tshirt.fill",
                name: "Warm Clothes",
                explanation: "Extra clothing and a thermal blanket protect against hypothermia if you must sleep outdoors.",
                category: .essential,
                points: 5
            ),
        ]
    }

    // MARK: - Dangerous Items (wrong for emergency kit)

    static func dangerousItems() -> [KitItem] {
        [
            KitItem(
                icon: "flame.fill",
                name: "Candles",
                explanation: "Candles cause fires, especially near gas leaks common after earthquakes. Use a flashlight instead.",
                category: .dangerous,
                points: -10
            ),
            KitItem(
                icon: "wineglass.fill",
                name: "Glass Bottles",
                explanation: "Glass shatters during aftershocks and adds dangerous weight. Use plastic containers.",
                category: .dangerous,
                points: -10
            ),
            KitItem(
                icon: "books.vertical.fill",
                name: "Heavy Books",
                explanation: "Heavy items slow evacuation and waste precious backpack space needed for survival essentials.",
                category: .dangerous,
                points: -5
            ),
            KitItem(
                icon: "laptopcomputer",
                name: "Laptop",
                explanation: "Heavy, fragile, and useless without power. Your phone with a power bank is far more practical.",
                category: .dangerous,
                points: -5
            ),
            KitItem(
                icon: "shoe.fill",
                name: "High Heels",
                explanation: "You need sturdy, closed-toe shoes to walk over debris safely. High heels cause injuries.",
                category: .dangerous,
                points: -5
            ),
            KitItem(
                icon: "tv.fill",
                name: "TV Remote",
                explanation: "Completely useless without power or a TV. Do not waste space on non-essential electronics.",
                category: .dangerous,
                points: -5
            ),
        ]
    }

    // MARK: - Distractor Items (plausible but not priority)

    static func distractorItems() -> [KitItem] {
        [
            KitItem(
                icon: "sunglasses.fill",
                name: "Sunglasses",
                explanation: "While eye protection can help, sunglasses are not a priority over life-saving essentials.",
                category: .distractor,
                points: -2
            ),
            KitItem(
                icon: "suit.spade.fill",
                name: "Playing Cards",
                explanation: "Entertainment is low priority when survival is at stake. Focus on essentials first.",
                category: .distractor,
                points: -2
            ),
            KitItem(
                icon: "humidity.fill",
                name: "Perfume",
                explanation: "Perfume is flammable and takes up space. It has no place in an emergency kit.",
                category: .distractor,
                points: -2
            ),
        ]
    }

    /// Returns a shuffled selection of items for a game session.
    /// Always includes all 10 essential items plus a random selection of dangerous/distractor items.
    static func itemsForSession() -> [KitItem] {
        let essentials = essentialItems()
        let nonEssentials = dangerousItems() + distractorItems()
        let selectedNonEssentials = Array(nonEssentials.shuffled().prefix(6))
        return (essentials + selectedNonEssentials).shuffled()
    }
}
