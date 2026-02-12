import SwiftUI

// MARK: - Seismic Risk Level

enum SeismicRiskLevel: Int, CaseIterable, Sendable {
    case veryLow = 0
    case low = 1
    case moderate = 2
    case high = 3
    case veryHigh = 4

    var label: String {
        switch self {
        case .veryLow: return "Very Low"
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .veryHigh: return "Very High"
        }
    }

    var color: Color {
        switch self {
        case .veryLow: return .green
        case .low: return .blue
        case .moderate: return .yellow
        case .high: return .orange
        case .veryHigh: return .red
        }
    }

    var icon: String {
        switch self {
        case .veryLow: return "checkmark.shield.fill"
        case .low: return "shield.fill"
        case .moderate: return "exclamationmark.shield.fill"
        case .high: return "exclamationmark.triangle.fill"
        case .veryHigh: return "bolt.shield.fill"
        }
    }

    var description: String {
        switch self {
        case .veryLow:
            return "Earthquakes are rare in this area. Basic awareness is still recommended."
        case .low:
            return "Minor earthquakes may occur occasionally. Know the basics of Drop, Cover, and Hold On."
        case .moderate:
            return "Earthquakes happen periodically. Have an emergency plan and kit ready."
        case .high:
            return "Significant earthquakes are likely. Regular drills and a fully stocked emergency kit are essential."
        case .veryHigh:
            return "Major earthquakes are expected. Structural reinforcement, constant preparedness, and community planning are critical."
        }
    }

    var safetyTips: [String] {
        switch self {
        case .veryLow:
            return [
                "Learn the basics of Drop, Cover, and Hold On.",
                "Know your building's emergency exits.",
                "Keep a small first-aid kit at home."
            ]
        case .low:
            return [
                "Prepare a basic emergency kit with water and food for 3 days.",
                "Identify safe spots in each room of your home.",
                "Practice Drop, Cover, and Hold On with your family."
            ]
        case .moderate:
            return [
                "Secure heavy furniture and appliances to walls.",
                "Keep emergency supplies in your car and workplace.",
                "Establish a family communication plan.",
                "Know how to shut off gas and water."
            ]
        case .high:
            return [
                "Conduct earthquake drills at home and work regularly.",
                "Store emergency supplies for at least 7 days.",
                "Have your building's structure inspected.",
                "Keep shoes and a flashlight near your bed.",
                "Learn basic first aid and CPR."
            ]
        case .veryHigh:
            return [
                "Retrofit your home if it was built before modern seismic codes.",
                "Maintain a 14-day supply of food, water, and medicine.",
                "Participate in community earthquake preparedness programs.",
                "Have multiple evacuation routes planned.",
                "Keep important documents in a waterproof, portable container.",
                "Install automatic gas shut-off valves."
            ]
        }
    }
}

// MARK: - Historical Earthquake

struct HistoricalEarthquake: Identifiable, Sendable {
    let id = UUID()
    let year: Int
    let magnitude: Double
    let location: String
    let description: String
}

// MARK: - Seismic State

struct SeismicState: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let zone: String
    let riskLevel: SeismicRiskLevel
    let description: String
}

// MARK: - Seismic Country

struct SeismicCountry: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let flag: String
    let agency: String
    let states: [SeismicState]
    let historicalEarthquakes: [HistoricalEarthquake]
}

// MARK: - Seismic Zone Data

enum SeismicZoneData {
    static func allCountries() -> [SeismicCountry] {
        [mexico(), usa(), chile(), japan()]
    }

    // MARK: - Mexico (CENAPRED)

    static func mexico() -> SeismicCountry {
        // Zone A - Very Low
        let zoneAStates: [SeismicState] = [
            SeismicState(name: "Aguascalientes", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: No historical record of significant earthquakes. Minimal seismic activity."),
            SeismicState(name: "Campeche", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: Located far from major fault lines. Earthquake risk is minimal."),
            SeismicState(name: "Chihuahua", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: Stable continental crust with very low seismic activity."),
            SeismicState(name: "Coahuila", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: One of the most seismically stable regions in Mexico."),
            SeismicState(name: "Durango", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: Located on stable terrain with rare seismic events."),
            SeismicState(name: "Guanajuato", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: Central plateau region with minimal tectonic activity."),
            SeismicState(name: "Nuevo Leon", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: Northeastern location far from subduction zones."),
            SeismicState(name: "Queretaro", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: Stable geological area with very low earthquake frequency."),
            SeismicState(name: "Quintana Roo", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: Caribbean coast with minimal seismic risk from tectonic sources."),
            SeismicState(name: "San Luis Potosi", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: Interior plateau with stable geological conditions."),
            SeismicState(name: "Tabasco", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: Coastal plain with low historical seismicity."),
            SeismicState(name: "Tamaulipas", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: Gulf coast location with minimal tectonic influence."),
            SeismicState(name: "Yucatan", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: Limestone platform with very rare seismic events."),
            SeismicState(name: "Zacatecas", zone: "A", riskLevel: .veryLow,
                         description: "Zone A: Northern highland region with stable geological base."),
        ]
        // Zone B - Low/Moderate
        let zoneBStates: [SeismicState] = [
            SeismicState(name: "Baja California Sur", zone: "B", riskLevel: .moderate,
                         description: "Zone B: Near the Gulf of California rift. Moderate activity from transform faults."),
            SeismicState(name: "Hidalgo", zone: "B", riskLevel: .low,
                         description: "Zone B: Can feel distant earthquakes from the Pacific coast subduction zone."),
            SeismicState(name: "Jalisco", zone: "B", riskLevel: .moderate,
                         description: "Zone B: Proximity to the Rivera Plate creates moderate seismic risk."),
            SeismicState(name: "Mexico City", zone: "B", riskLevel: .moderate,
                         description: "Zone B: Soft lake-bed soil amplifies seismic waves from distant earthquakes significantly."),
            SeismicState(name: "Nayarit", zone: "B", riskLevel: .moderate,
                         description: "Zone B: Pacific coast proximity increases risk from subduction earthquakes."),
            SeismicState(name: "Puebla", zone: "B", riskLevel: .moderate,
                         description: "Zone B: Intraslab earthquakes beneath the state pose moderate risk."),
            SeismicState(name: "Sinaloa", zone: "B", riskLevel: .low,
                         description: "Zone B: Gulf of California influence brings occasional seismic activity."),
            SeismicState(name: "Sonora", zone: "B", riskLevel: .low,
                         description: "Zone B: Transform faulting along the Gulf of California affects this region."),
            SeismicState(name: "State of Mexico", zone: "B", riskLevel: .moderate,
                         description: "Zone B: Similar to Mexico City, soil conditions can amplify distant earthquake waves."),
            SeismicState(name: "Tlaxcala", zone: "B", riskLevel: .low,
                         description: "Zone B: Minor influence from the Trans-Mexican Volcanic Belt seismicity."),
        ]
        // Zone C - High
        let zoneCStates: [SeismicState] = [
            SeismicState(name: "Baja California", zone: "C", riskLevel: .high,
                         description: "Zone C: Major fault systems including the Cerro Prieto fault produce significant earthquakes."),
            SeismicState(name: "Chiapas", zone: "C", riskLevel: .high,
                         description: "Zone C: Triple junction of the Cocos, Caribbean, and North American plates. Very active."),
            SeismicState(name: "Colima", zone: "C", riskLevel: .high,
                         description: "Zone C: The Colima Rift and Rivera Plate subduction create frequent seismic events."),
            SeismicState(name: "Michoacan", zone: "C", riskLevel: .high,
                         description: "Zone C: Source of the devastating 1985 earthquake. Active subduction zone offshore."),
            SeismicState(name: "Morelos", zone: "C", riskLevel: .high,
                         description: "Zone C: Close to intraslab seismic sources beneath central Mexico."),
            SeismicState(name: "Veracruz", zone: "C", riskLevel: .high,
                         description: "Zone C: Long coastline exposed to subduction and volcanic seismicity."),
        ]
        // Zone D - Very High
        let zoneDStates: [SeismicState] = [
            SeismicState(name: "Guerrero", zone: "D", riskLevel: .veryHigh,
                         description: "Zone D: The Guerrero Gap is one of the most dangerous seismic zones in the world."),
            SeismicState(name: "Oaxaca", zone: "D", riskLevel: .veryHigh,
                         description: "Zone D: Frequent large earthquakes from Cocos Plate subduction. Extremely active region."),
        ]
        let allStates: [SeismicState] = zoneAStates + zoneBStates + zoneCStates + zoneDStates
        let quakes: [HistoricalEarthquake] = [
            HistoricalEarthquake(year: 1985, magnitude: 8.1, location: "Mexico City",
                                 description: "Devastated Mexico City due to soil amplification. Over 10,000 casualties. Led to major building code reforms."),
            HistoricalEarthquake(year: 2017, magnitude: 7.1, location: "Puebla",
                                 description: "Struck on the anniversary of the 1985 earthquake. 370 deaths. Collapsed buildings in Mexico City and Puebla."),
            HistoricalEarthquake(year: 2017, magnitude: 8.2, location: "Chiapas",
                                 description: "Strongest earthquake in Mexico in a century. Caused significant damage in Oaxaca and Chiapas."),
            HistoricalEarthquake(year: 1932, magnitude: 8.2, location: "Jalisco",
                                 description: "Triggered a tsunami on the Pacific coast. One of the largest earthquakes recorded in Mexico."),
            HistoricalEarthquake(year: 2012, magnitude: 7.4, location: "Guerrero",
                                 description: "Felt strongly in Mexico City. Damaged hundreds of buildings in Guerrero and Oaxaca."),
        ]
        return SeismicCountry(
            name: "Mexico",
            flag: "\u{1F1F2}\u{1F1FD}",
            agency: "CENAPRED",
            states: allStates,
            historicalEarthquakes: quakes
        )
    }

    // MARK: - USA (USGS)

    static func usa() -> SeismicCountry {
        // Very High
        let veryHighStates: [SeismicState] = [
            SeismicState(name: "Alaska", zone: "Very High", riskLevel: .veryHigh,
                         description: "Most seismically active state. Located on the Pacific Ring of Fire with frequent large earthquakes."),
            SeismicState(name: "California", zone: "Very High", riskLevel: .veryHigh,
                         description: "The San Andreas Fault and numerous other faults make this one of the highest-risk areas in the world."),
            SeismicState(name: "Hawaii", zone: "Very High", riskLevel: .veryHigh,
                         description: "Volcanic activity and tectonic movement produce frequent earthquakes, especially on the Big Island."),
        ]
        // High
        let highStates: [SeismicState] = [
            SeismicState(name: "Idaho", zone: "High", riskLevel: .high,
                         description: "The Intermountain Seismic Belt crosses Idaho. Several significant faults are present."),
            SeismicState(name: "Montana", zone: "High", riskLevel: .high,
                         description: "Hebgen Lake fault and Intermountain Seismic Belt create significant seismic hazard."),
            SeismicState(name: "Nevada", zone: "High", riskLevel: .high,
                         description: "Basin and Range Province extensional faulting produces frequent moderate earthquakes."),
            SeismicState(name: "Oregon", zone: "High", riskLevel: .high,
                         description: "Cascadia Subduction Zone threatens with potential M9+ megaquake. Very high long-term risk."),
            SeismicState(name: "Utah", zone: "High", riskLevel: .high,
                         description: "Wasatch Fault runs through the most populated area. High risk for a major event."),
            SeismicState(name: "Washington", zone: "High", riskLevel: .high,
                         description: "Cascadia Subduction Zone and Seattle Fault create very high seismic hazard."),
            SeismicState(name: "Wyoming", zone: "High", riskLevel: .high,
                         description: "Yellowstone area and Teton Fault contribute to elevated seismic risk."),
        ]
        // Moderate
        let moderateStates: [SeismicState] = [
            SeismicState(name: "Arkansas", zone: "Moderate", riskLevel: .moderate,
                         description: "New Madrid Seismic Zone in the northeast part of the state poses moderate risk."),
            SeismicState(name: "Connecticut", zone: "Moderate", riskLevel: .moderate,
                         description: "Ancient fault systems can produce infrequent but notable earthquakes."),
            SeismicState(name: "Illinois", zone: "Moderate", riskLevel: .moderate,
                         description: "Southern Illinois is near the New Madrid Seismic Zone. Moderate risk in that region."),
            SeismicState(name: "Indiana", zone: "Moderate", riskLevel: .moderate,
                         description: "Wabash Valley Seismic Zone and New Madrid influence create moderate hazard."),
            SeismicState(name: "Kentucky", zone: "Moderate", riskLevel: .moderate,
                         description: "Western Kentucky sits on the New Madrid Seismic Zone with moderate to high risk."),
            SeismicState(name: "Maine", zone: "Moderate", riskLevel: .moderate,
                         description: "Occasional earthquakes from ancient geological structures in New England."),
            SeismicState(name: "Massachusetts", zone: "Moderate", riskLevel: .moderate,
                         description: "Historical earthquakes include the 1755 Cape Ann event. Moderate ongoing risk."),
            SeismicState(name: "Missouri", zone: "Moderate", riskLevel: .moderate,
                         description: "New Madrid Seismic Zone produced some of the largest earthquakes in US history in 1811-1812."),
            SeismicState(name: "New Hampshire", zone: "Moderate", riskLevel: .moderate,
                         description: "New England seismicity produces occasional small to moderate earthquakes."),
            SeismicState(name: "New Jersey", zone: "Moderate", riskLevel: .moderate,
                         description: "Ramapo Fault and proximity to the Newark Basin create moderate seismic hazard."),
            SeismicState(name: "New York", zone: "Moderate", riskLevel: .moderate,
                         description: "Historical seismicity along the Ramapo Fault and in the Adirondacks."),
            SeismicState(name: "Oklahoma", zone: "Moderate", riskLevel: .moderate,
                         description: "Induced seismicity from wastewater injection has dramatically increased earthquake rates."),
            SeismicState(name: "Rhode Island", zone: "Moderate", riskLevel: .moderate,
                         description: "Part of the New England seismic region with occasional minor events."),
            SeismicState(name: "South Carolina", zone: "Moderate", riskLevel: .moderate,
                         description: "The 1886 Charleston earthquake (M7.3) demonstrated significant seismic potential."),
            SeismicState(name: "Tennessee", zone: "Moderate", riskLevel: .moderate,
                         description: "Western Tennessee is in the New Madrid Seismic Zone with moderate earthquake risk."),
            SeismicState(name: "Vermont", zone: "Moderate", riskLevel: .moderate,
                         description: "Northern Appalachian seismicity produces small earthquakes periodically."),
        ]
        // Low
        let lowStates: [SeismicState] = [
            SeismicState(name: "Alabama", zone: "Low", riskLevel: .low,
                         description: "Low seismic activity, but northern Alabama has some historical earthquake records."),
            SeismicState(name: "Arizona", zone: "Low", riskLevel: .low,
                         description: "Minor seismic activity from Basin and Range faulting in the western part."),
            SeismicState(name: "Colorado", zone: "Low", riskLevel: .low,
                         description: "Occasional small earthquakes, mostly in the western mountainous regions."),
            SeismicState(name: "Georgia", zone: "Low", riskLevel: .low,
                         description: "Low seismicity with rare minor earthquakes in the northern part of the state."),
            SeismicState(name: "Mississippi", zone: "Low", riskLevel: .low,
                         description: "Northeastern corner near the New Madrid zone has some risk. Rest is very low."),
            SeismicState(name: "Nebraska", zone: "Low", riskLevel: .low,
                         description: "Stable interior with very infrequent minor seismic events."),
            SeismicState(name: "New Mexico", zone: "Low", riskLevel: .low,
                         description: "Rio Grande Rift produces occasional small to moderate earthquakes."),
            SeismicState(name: "North Carolina", zone: "Low", riskLevel: .low,
                         description: "Western mountains have some seismic activity. Overall risk is low."),
            SeismicState(name: "Virginia", zone: "Low", riskLevel: .low,
                         description: "The 2011 M5.8 earthquake showed that even low-risk areas can have surprises."),
        ]
        // Very Low
        let veryLowStates: [SeismicState] = [
            SeismicState(name: "Delaware", zone: "Very Low", riskLevel: .veryLow,
                         description: "Very stable Atlantic coastal plain with minimal seismic activity."),
            SeismicState(name: "Florida", zone: "Very Low", riskLevel: .veryLow,
                         description: "One of the least seismically active states. Thick sedimentary layers dampen any activity."),
            SeismicState(name: "Iowa", zone: "Very Low", riskLevel: .veryLow,
                         description: "Stable interior craton with very rare and minor seismic events."),
            SeismicState(name: "Kansas", zone: "Very Low", riskLevel: .veryLow,
                         description: "Generally very low risk, though some induced seismicity has occurred in recent years."),
            SeismicState(name: "Louisiana", zone: "Very Low", riskLevel: .veryLow,
                         description: "Gulf coastal plain with minimal natural seismic activity."),
            SeismicState(name: "Maryland", zone: "Very Low", riskLevel: .veryLow,
                         description: "Stable mid-Atlantic region with very infrequent minor earthquakes."),
            SeismicState(name: "Michigan", zone: "Very Low", riskLevel: .veryLow,
                         description: "Stable craton with extremely rare seismic events."),
            SeismicState(name: "Minnesota", zone: "Very Low", riskLevel: .veryLow,
                         description: "Canadian Shield influence provides very stable geological conditions."),
            SeismicState(name: "North Dakota", zone: "Very Low", riskLevel: .veryLow,
                         description: "One of the least seismically active areas in the US."),
            SeismicState(name: "Ohio", zone: "Very Low", riskLevel: .veryLow,
                         description: "Stable interior with very rare minor earthquakes."),
            SeismicState(name: "Pennsylvania", zone: "Very Low", riskLevel: .veryLow,
                         description: "Occasional very minor earthquakes. Generally very stable geology."),
            SeismicState(name: "South Dakota", zone: "Very Low", riskLevel: .veryLow,
                         description: "Stable Great Plains geology with extremely rare seismic events."),
            SeismicState(name: "Texas", zone: "Very Low", riskLevel: .veryLow,
                         description: "Mostly very stable, though western Texas has occasional minor activity."),
            SeismicState(name: "Washington D.C.", zone: "Very Low", riskLevel: .veryLow,
                         description: "Located on stable mid-Atlantic geology with very low seismic risk."),
            SeismicState(name: "West Virginia", zone: "Very Low", riskLevel: .veryLow,
                         description: "Appalachian geology is generally stable with very rare seismic events."),
            SeismicState(name: "Wisconsin", zone: "Very Low", riskLevel: .veryLow,
                         description: "Stable craton with minimal seismic activity."),
        ]
        let allStates: [SeismicState] = veryHighStates + highStates + moderateStates + lowStates + veryLowStates
        let quakes: [HistoricalEarthquake] = [
            HistoricalEarthquake(year: 1906, magnitude: 7.9, location: "San Francisco, California",
                                 description: "Ruptured 477 km of the San Andreas Fault. Fires destroyed 80% of the city. Over 3,000 deaths."),
            HistoricalEarthquake(year: 1964, magnitude: 9.2, location: "Prince William Sound, Alaska",
                                 description: "Second-largest earthquake ever recorded. Generated a devastating tsunami across the Pacific."),
            HistoricalEarthquake(year: 1994, magnitude: 6.7, location: "Northridge, California",
                                 description: "Caused $20 billion in damage. Led to major advances in earthquake engineering."),
            HistoricalEarthquake(year: 1989, magnitude: 6.9, location: "Loma Prieta, California",
                                 description: "Collapsed the Cypress freeway structure and a Bay Bridge section. Occurred during the World Series."),
            HistoricalEarthquake(year: 2011, magnitude: 5.8, location: "Mineral, Virginia",
                                 description: "Felt from Georgia to Maine. Showed that eastern US earthquakes propagate much farther than western ones."),
        ]
        return SeismicCountry(
            name: "United States",
            flag: "\u{1F1FA}\u{1F1F8}",
            agency: "USGS",
            states: allStates,
            historicalEarthquakes: quakes
        )
    }

    // MARK: - Chile (SENAPRED / NCh433)

    static func chile() -> SeismicCountry {
        // Zone 3 - Very High
        let zone3States: [SeismicState] = [
            SeismicState(name: "Arica y Parinacota", zone: "3", riskLevel: .veryHigh,
                         description: "Zone 3: Northernmost region on the Nazca-South American plate boundary. Extremely high seismic activity."),
            SeismicState(name: "Tarapaca", zone: "3", riskLevel: .veryHigh,
                         description: "Zone 3: Major subduction zone earthquakes are frequent in this northern coastal region."),
            SeismicState(name: "Antofagasta", zone: "3", riskLevel: .veryHigh,
                         description: "Zone 3: Active seismic gap. Site of the 1995 M8.0 earthquake."),
            SeismicState(name: "Atacama", zone: "3", riskLevel: .veryHigh,
                         description: "Zone 3: Coastal subduction produces frequent large earthquakes in this arid region."),
            SeismicState(name: "Coquimbo", zone: "3", riskLevel: .veryHigh,
                         description: "Zone 3: Site of the 2015 M8.3 Illapel earthquake. Very active subduction zone."),
            SeismicState(name: "Valparaiso", zone: "3", riskLevel: .veryHigh,
                         description: "Zone 3: Dense population and proximity to the subduction zone create very high risk."),
            SeismicState(name: "O'Higgins", zone: "3", riskLevel: .veryHigh,
                         description: "Zone 3: Central Chile subduction zone produces large earthquakes regularly."),
            SeismicState(name: "Maule", zone: "3", riskLevel: .veryHigh,
                         description: "Zone 3: Epicentral region of the devastating 2010 M8.8 earthquake."),
            SeismicState(name: "Nuble", zone: "3", riskLevel: .veryHigh,
                         description: "Zone 3: Located in the rupture zone of the 2010 earthquake. Very high long-term risk."),
            SeismicState(name: "Biobio", zone: "3", riskLevel: .veryHigh,
                         description: "Zone 3: Southern end of the 2010 rupture zone. Major population center at risk."),
            SeismicState(name: "La Araucania", zone: "3", riskLevel: .veryHigh,
                         description: "Zone 3: Active subduction and volcanic arc create significant seismic hazard."),
        ]
        // Zone 2 - High
        let zone2States: [SeismicState] = [
            SeismicState(name: "Metropolitana", zone: "2", riskLevel: .high,
                         description: "Zone 2: Santiago and surroundings. Amplified shaking from basin effects increases risk."),
            SeismicState(name: "Los Rios", zone: "2", riskLevel: .high,
                         description: "Zone 2: Near the 1960 Valdivia earthquake epicenter. High long-term seismic risk."),
            SeismicState(name: "Los Lagos", zone: "2", riskLevel: .high,
                         description: "Zone 2: Southern Chile subduction zone. The 1960 M9.5 earthquake originated nearby."),
        ]
        // Zone 1 - Moderate
        let zone1States: [SeismicState] = [
            SeismicState(name: "Aysen", zone: "1", riskLevel: .moderate,
                         description: "Zone 1: Patagonian region with moderate seismicity from the Chile Triple Junction."),
            SeismicState(name: "Magallanes", zone: "1", riskLevel: .moderate,
                         description: "Zone 1: Southernmost region. Scotia-South American plate boundary produces moderate seismicity."),
        ]
        let allStates: [SeismicState] = zone3States + zone2States + zone1States
        let quakes: [HistoricalEarthquake] = [
            HistoricalEarthquake(year: 1960, magnitude: 9.5, location: "Valdivia",
                                 description: "The most powerful earthquake ever recorded. Generated a Pacific-wide tsunami. Reshaped Chile's coastline."),
            HistoricalEarthquake(year: 2010, magnitude: 8.8, location: "Maule",
                                 description: "Triggered a devastating tsunami. 525 deaths. Led to major improvements in Chile's early warning system."),
            HistoricalEarthquake(year: 2014, magnitude: 8.2, location: "Iquique",
                                 description: "Struck northern Chile's seismic gap. Relatively low casualties due to Chile's strict building codes."),
            HistoricalEarthquake(year: 2015, magnitude: 8.3, location: "Illapel",
                                 description: "Generated a tsunami with waves up to 4.5 meters. Efficient evacuation saved many lives."),
            HistoricalEarthquake(year: 1939, magnitude: 8.3, location: "Chillan",
                                 description: "Deadliest earthquake in Chilean history with approximately 28,000 casualties. Led to creation of building codes."),
        ]
        return SeismicCountry(
            name: "Chile",
            flag: "\u{1F1E8}\u{1F1F1}",
            agency: "SENAPRED",
            states: allStates,
            historicalEarthquakes: quakes
        )
    }

    // MARK: - Japan (HERP)

    static func japan() -> SeismicCountry {
        // Very High
        let veryHighStates: [SeismicState] = [
            SeismicState(name: "Aichi", zone: "Very High", riskLevel: .veryHigh,
                         description: "Directly in the path of the anticipated Nankai Trough megaquake. Extremely high long-term risk."),
            SeismicState(name: "Hyogo", zone: "Very High", riskLevel: .veryHigh,
                         description: "Site of the 1995 Great Hanshin earthquake. Active faults and Nankai Trough proximity."),
            SeismicState(name: "Kanagawa", zone: "Very High", riskLevel: .veryHigh,
                         description: "Sagami Trough and multiple active faults create extremely high seismic hazard for this Tokyo-adjacent prefecture."),
            SeismicState(name: "Kochi", zone: "Very High", riskLevel: .veryHigh,
                         description: "Directly facing the Nankai Trough. Expected to experience severe shaking and tsunami in a megaquake."),
            SeismicState(name: "Mie", zone: "Very High", riskLevel: .veryHigh,
                         description: "Located above the Nankai Trough rupture zone. Very high probability of a major earthquake."),
            SeismicState(name: "Osaka", zone: "Very High", riskLevel: .veryHigh,
                         description: "The 2018 Osaka earthquake and Nankai Trough risk make this a very high hazard area."),
            SeismicState(name: "Shizuoka", zone: "Very High", riskLevel: .veryHigh,
                         description: "Tokai earthquake gap and Nankai Trough create extreme seismic risk. Mount Fuji adds volcanic hazard."),
            SeismicState(name: "Tokyo", zone: "Very High", riskLevel: .veryHigh,
                         description: "Capital city sits at the junction of three tectonic plates. A major direct-hit earthquake is statistically overdue."),
            SeismicState(name: "Wakayama", zone: "Very High", riskLevel: .veryHigh,
                         description: "Southern coast directly exposed to Nankai Trough megaquake and resulting tsunami."),
        ]
        // High
        let highStates: [SeismicState] = [
            SeismicState(name: "Chiba", zone: "High", riskLevel: .high,
                         description: "Frequent earthquakes from the Pacific Plate subduction. Boso Peninsula is particularly active."),
            SeismicState(name: "Ehime", zone: "High", riskLevel: .high,
                         description: "Nankai Trough influence and Median Tectonic Line fault create high seismic risk."),
            SeismicState(name: "Hokkaido", zone: "High", riskLevel: .high,
                         description: "Multiple subduction zones and the Hidaka collision zone produce frequent earthquakes."),
            SeismicState(name: "Ibaraki", zone: "High", riskLevel: .high,
                         description: "Frequent earthquakes from the Japan Trench subduction zone. Heavily affected in 2011."),
            SeismicState(name: "Miyagi", zone: "High", riskLevel: .high,
                         description: "Epicentral region of the 2011 Tohoku earthquake. Japan Trench creates persistent high risk."),
            SeismicState(name: "Nagano", zone: "High", riskLevel: .high,
                         description: "Itoigawa-Shizuoka Tectonic Line and numerous active faults create high inland seismic risk."),
            SeismicState(name: "Nara", zone: "High", riskLevel: .high,
                         description: "Median Tectonic Line and proximity to Nankai Trough create significant hazard."),
            SeismicState(name: "Niigata", zone: "High", riskLevel: .high,
                         description: "Site of major earthquakes in 2004 and 2007. Active reverse faults in the region."),
            SeismicState(name: "Oita", zone: "High", riskLevel: .high,
                         description: "Beppu-Shimabara Graben and Nankai Trough influence create high seismic hazard."),
            SeismicState(name: "Shiga", zone: "High", riskLevel: .high,
                         description: "Active faults near Lake Biwa and Nankai Trough proximity increase risk."),
            SeismicState(name: "Tokushima", zone: "High", riskLevel: .high,
                         description: "Directly above the Nankai Trough. Median Tectonic Line fault also crosses the prefecture."),
        ]
        // Moderate
        let moderateStates: [SeismicState] = [
            SeismicState(name: "Aomori", zone: "Moderate", riskLevel: .moderate,
                         description: "Japan Trench subduction produces regular moderate earthquakes in this northern prefecture."),
            SeismicState(name: "Fukui", zone: "Moderate", riskLevel: .moderate,
                         description: "Site of the 1948 Fukui earthquake. Active faults present inland."),
            SeismicState(name: "Fukuoka", zone: "Moderate", riskLevel: .moderate,
                         description: "The 2005 Fukuoka earthquake revealed previously unknown offshore faults. Moderate ongoing risk."),
            SeismicState(name: "Fukushima", zone: "Moderate", riskLevel: .moderate,
                         description: "Affected by the 2011 earthquake. Japan Trench proximity maintains moderate seismic hazard."),
            SeismicState(name: "Gifu", zone: "Moderate", riskLevel: .moderate,
                         description: "Nobi Fault system and other active inland faults create moderate seismic risk."),
            SeismicState(name: "Gunma", zone: "Moderate", riskLevel: .moderate,
                         description: "Inland location with some active faults. Moderate seismic risk from surrounding sources."),
            SeismicState(name: "Hiroshima", zone: "Moderate", riskLevel: .moderate,
                         description: "Moderate seismicity from the Philippine Sea Plate and inland fault systems."),
            SeismicState(name: "Ishikawa", zone: "Moderate", riskLevel: .moderate,
                         description: "The 2024 Noto Peninsula earthquake demonstrated the active fault risk in this region."),
            SeismicState(name: "Iwate", zone: "Moderate", riskLevel: .moderate,
                         description: "Japan Trench earthquakes affect this Pacific coast prefecture. 2011 tsunami was devastating."),
            SeismicState(name: "Kagawa", zone: "Moderate", riskLevel: .moderate,
                         description: "Nankai Trough influence and Median Tectonic Line proximity create moderate hazard."),
            SeismicState(name: "Kagoshima", zone: "Moderate", riskLevel: .moderate,
                         description: "Volcanic seismicity from Sakurajima and tectonic earthquakes from the Nankai Trough."),
            SeismicState(name: "Kumamoto", zone: "Moderate", riskLevel: .moderate,
                         description: "The 2016 Kumamoto earthquakes caused severe damage. Active fault systems are present."),
            SeismicState(name: "Kyoto", zone: "Moderate", riskLevel: .moderate,
                         description: "Historical capital with active faults nearby. Nankai Trough also poses risk."),
            SeismicState(name: "Miyazaki", zone: "Moderate", riskLevel: .moderate,
                         description: "Hyuga-nada offshore earthquakes and Nankai Trough influence create moderate risk."),
            SeismicState(name: "Nagasaki", zone: "Moderate", riskLevel: .moderate,
                         description: "Moderate seismicity from the Shimabara Graben and regional tectonic activity."),
            SeismicState(name: "Okayama", zone: "Moderate", riskLevel: .moderate,
                         description: "Nankai Trough proximity and Median Tectonic Line create moderate seismic hazard in western Honshu."),
            SeismicState(name: "Okinawa", zone: "Moderate", riskLevel: .moderate,
                         description: "Ryukyu Trench subduction produces regular moderate earthquakes and tsunami risk."),
            SeismicState(name: "Saga", zone: "Moderate", riskLevel: .moderate,
                         description: "Western Kyushu tectonic activity creates moderate seismic hazard."),
            SeismicState(name: "Saitama", zone: "Moderate", riskLevel: .moderate,
                         description: "Feels strong shaking from nearby plate boundary earthquakes. Some local active faults."),
            SeismicState(name: "Tochigi", zone: "Moderate", riskLevel: .moderate,
                         description: "Inland seismicity and influence from the Japan Trench create moderate risk."),
            SeismicState(name: "Toyama", zone: "Moderate", riskLevel: .moderate,
                         description: "Active faults in the Hokuriku region produce periodic moderate earthquakes."),
            SeismicState(name: "Yamaguchi", zone: "Moderate", riskLevel: .moderate,
                         description: "Western Honshu with moderate seismic activity from regional fault systems."),
            SeismicState(name: "Yamanashi", zone: "Moderate", riskLevel: .moderate,
                         description: "Mount Fuji area and active faults create moderate seismic and volcanic risk."),
        ]
        // Low
        let lowStates: [SeismicState] = [
            SeismicState(name: "Akita", zone: "Low", riskLevel: .low,
                         description: "Northern Honshu with relatively lower seismicity compared to the Pacific side."),
            SeismicState(name: "Shimane", zone: "Low", riskLevel: .low,
                         description: "San'in Coast has lower seismicity. The 2000 Tottori earthquake was a notable exception."),
            SeismicState(name: "Tottori", zone: "Low", riskLevel: .low,
                         description: "Generally low seismicity, though the 2000 Tottori earthquake (M7.3) was significant."),
            SeismicState(name: "Yamagata", zone: "Low", riskLevel: .low,
                         description: "Sea of Japan side of northern Honshu with relatively lower seismic activity."),
        ]
        let allStates: [SeismicState] = veryHighStates + highStates + moderateStates + lowStates
        let quakes: [HistoricalEarthquake] = [
            HistoricalEarthquake(year: 2011, magnitude: 9.1, location: "Tohoku",
                                 description: "Triggered a massive tsunami. Caused the Fukushima nuclear disaster. Over 18,000 deaths."),
            HistoricalEarthquake(year: 1995, magnitude: 6.9, location: "Kobe",
                                 description: "Great Hanshin earthquake destroyed much of Kobe. 6,434 deaths. Revolutionized Japanese seismic engineering."),
            HistoricalEarthquake(year: 1923, magnitude: 7.9, location: "Kanto",
                                 description: "Great Kanto earthquake devastated Tokyo and Yokohama. Fires caused most of the 105,000+ deaths."),
            HistoricalEarthquake(year: 2016, magnitude: 7.0, location: "Kumamoto",
                                 description: "Two large earthquakes in two days. Severe damage to Kumamoto Castle and surrounding infrastructure."),
            HistoricalEarthquake(year: 2024, magnitude: 7.5, location: "Noto Peninsula",
                                 description: "Struck on New Year's Day. Caused severe damage, landslides, and fires in the Ishikawa Prefecture."),
        ]
        return SeismicCountry(
            name: "Japan",
            flag: "\u{1F1EF}\u{1F1F5}",
            agency: "HERP",
            states: allStates,
            historicalEarthquakes: quakes
        )
    }
}
