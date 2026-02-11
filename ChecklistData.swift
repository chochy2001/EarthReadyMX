import SwiftUI

enum ChecklistData {
    static func allCategories() -> [ChecklistCategory] {
        [emergencyKit(), homeSafety(), familyPlan()]
    }

    // MARK: - Emergency Kit (FEMA + CENAPRED)

    static func emergencyKit() -> ChecklistCategory {
        ChecklistCategory(
            icon: "bag.fill",
            title: "Emergency Kit",
            subtitle: "Essential supplies for 72 hours",
            color: .orange,
            gradientColors: [.orange, .red],
            items: [
                ChecklistItem(icon: "drop.fill", title: "Water Supply",
                              description: "One gallon per person per day for at least 3 days, for drinking and sanitation.",
                              priority: .critical),
                ChecklistItem(icon: "fork.knife", title: "Non-perishable Food",
                              description: "At least a 3-day supply. Canned goods, energy bars, dried fruits.",
                              priority: .critical),
                ChecklistItem(icon: "cross.case.fill", title: "First Aid Kit",
                              description: "Bandages, antiseptic, pain relievers, prescription medications, gauze, tape.",
                              priority: .critical),
                ChecklistItem(icon: "flashlight.on.fill", title: "Flashlight & Batteries",
                              description: "LED flashlight with extra batteries. Avoid candles due to fire risk.",
                              priority: .critical),
                ChecklistItem(icon: "speaker.wave.3.fill", title: "Emergency Whistle",
                              description: "To signal for help if trapped under debris.",
                              priority: .critical),
                ChecklistItem(icon: "doc.text.fill", title: "Important Documents",
                              description: "Copies of IDs, insurance, medical records in waterproof bag.",
                              priority: .critical),
                ChecklistItem(icon: "radio.fill", title: "Battery/Hand-crank Radio",
                              description: "Essential when power and internet are down after an earthquake.",
                              priority: .important),
                ChecklistItem(icon: "battery.100.bolt", title: "Phone Charger & Power Bank",
                              description: "Portable battery pack, keep charged. Solar charger as backup.",
                              priority: .important),
                ChecklistItem(icon: "banknote.fill", title: "Cash (Small Bills)",
                              description: "ATMs and card readers won't work without power.",
                              priority: .important),
                ChecklistItem(icon: "facemask.fill", title: "Dust Masks",
                              description: "N95 or similar to filter contaminated air from debris.",
                              priority: .important),
                ChecklistItem(icon: "wrench.fill", title: "Manual Can Opener",
                              description: "For canned food. Don't rely on electric openers.",
                              priority: .recommended),
                ChecklistItem(icon: "map.fill", title: "Local Maps",
                              description: "Paper maps of your area. GPS may not work without cell service.",
                              priority: .recommended),
                ChecklistItem(icon: "tshirt.fill", title: "Warm Clothing & Blanket",
                              description: "Extra clothes, rain jacket, sturdy shoes, thermal blanket.",
                              priority: .recommended),
                ChecklistItem(icon: "wrench.and.screwdriver.fill", title: "Wrench/Pliers",
                              description: "To turn off gas and water utilities if needed.",
                              priority: .recommended)
            ]
        )
    }

    // MARK: - Home Safety (FEMA + CENAPRED)

    static func homeSafety() -> ChecklistCategory {
        ChecklistCategory(
            icon: "house.fill",
            title: "Home Safety",
            subtitle: "Secure your living space",
            color: .blue,
            gradientColors: [.blue, .cyan],
            items: [
                ChecklistItem(icon: "cabinet.fill", title: "Secure Heavy Furniture",
                              description: "Anchor bookcases, shelves, and tall furniture to walls with brackets.",
                              priority: .critical),
                ChecklistItem(icon: "shield.checkered", title: "Identify Safe Spots",
                              description: "Under sturdy tables/desks in each room. Away from windows.",
                              priority: .critical),
                ChecklistItem(icon: "flame.fill", title: "Know Gas Shutoff",
                              description: "Learn location of gas valve and how to shut it off.",
                              priority: .critical),
                ChecklistItem(icon: "figure.walk.departure", title: "Check Evacuation Routes",
                              description: "Identify 2 exits from each room. Remove obstacles.",
                              priority: .critical),
                ChecklistItem(icon: "drop.triangle.fill", title: "Know Water Shutoff",
                              description: "Locate main water valve. Know how to turn it off.",
                              priority: .important),
                ChecklistItem(icon: "bolt.fill", title: "Know Electrical Panel",
                              description: "Know location and how to shut off main breaker.",
                              priority: .important),
                ChecklistItem(icon: "heater.vertical.fill", title: "Secure Water Heater",
                              description: "Strap to wall studs to prevent tipping and gas leaks.",
                              priority: .important),
                ChecklistItem(icon: "arrow.down.to.line", title: "Store Heavy Items Low",
                              description: "Move heavy objects from high shelves to lower shelves.",
                              priority: .important),
                ChecklistItem(icon: "building.2.fill", title: "Inspect Home Structure",
                              description: "Check for cracks in walls, foundation issues.",
                              priority: .recommended),
                ChecklistItem(icon: "photo.artframe", title: "Secure Hanging Objects",
                              description: "Mirrors, paintings, light fixtures. Use closed hooks.",
                              priority: .recommended)
            ]
        )
    }

    // MARK: - Family Plan (CENAPRED + FEMA)

    static func familyPlan() -> ChecklistCategory {
        ChecklistCategory(
            icon: "person.3.fill",
            title: "Family Plan",
            subtitle: "Coordinate with your loved ones",
            color: .green,
            gradientColors: [.green, .mint],
            items: [
                ChecklistItem(icon: "mappin.and.ellipse", title: "Designate Meeting Point",
                              description: "Choose a safe location outside your home where family gathers.",
                              priority: .critical),
                ChecklistItem(icon: "phone.fill", title: "Emergency Contact List",
                              description: "Written list of family, neighbors, emergency services.",
                              priority: .critical),
                ChecklistItem(icon: "person.line.dotted.person.fill", title: "Out-of-Area Contact",
                              description: "Choose a relative in another city as communication hub.",
                              priority: .critical),
                ChecklistItem(icon: "person.3.fill", title: "Assign Family Roles",
                              description: "Each member knows their job: gas, kit, children.",
                              priority: .important),
                ChecklistItem(icon: "arrow.down.to.line", title: "Practice Drop, Cover, Hold",
                              description: "Drill with every family member. Practice quarterly.",
                              priority: .important),
                ChecklistItem(icon: "message.fill", title: "Know Text, Don't Call",
                              description: "Teach family to text during emergencies. Less bandwidth.",
                              priority: .important),
                ChecklistItem(icon: "heart.fill", title: "Include Special Needs",
                              description: "Plan for elderly, disabled, or infant family members.",
                              priority: .important),
                ChecklistItem(icon: "pawprint.fill", title: "Plan for Pets",
                              description: "Include pet food, carrier, leash, and vet records.",
                              priority: .recommended),
                ChecklistItem(icon: "mappin.slash", title: "Alternative Meeting Point",
                              description: "Second meeting point farther from home as backup.",
                              priority: .recommended),
                ChecklistItem(icon: "stopwatch.fill", title: "Practice Evacuation Drill",
                              description: "Run a full family drill at least twice a year.",
                              priority: .recommended)
            ]
        )
    }
}
