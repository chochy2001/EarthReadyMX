import SwiftUI

struct SeismicZoneView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    @State private var countries: [SeismicCountry] = SeismicZoneData.allCountries()
    @State private var selectedCountry: SeismicCountry?
    @State private var selectedState: SeismicState?
    @State private var searchText: String = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.03, green: 0.08, blue: 0.05), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if let state = selectedState {
                stateDetailView(state: state)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                mainListView
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(
            reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.8),
            value: selectedState?.id
        )
        .onAppear {
            if selectedCountry == nil {
                selectedCountry = countries.first
            }
            AccessibilityAnnouncement.announceScreenChange(
                "Seismic Zones. Explore earthquake risk levels across different countries and regions."
            )
        }
    }

    // MARK: - Main List View

    private var mainListView: some View {
        VStack(spacing: 0) {
            headerSection
            countrySelector
                .padding(.top, 8)
            searchBar
                .padding(.top, 12)
                .padding(.horizontal, 20)

            ScrollView {
                LazyVStack(spacing: 8) {
                    if let country = selectedCountry {
                        riskLegend
                            .padding(.top, 12)
                            .padding(.horizontal, 20)

                        ForEach(filteredStates(for: country)) { state in
                            StateRow(
                                state: state,
                                countryFlag: country.flag,
                                differentiateWithoutColor: differentiateWithoutColor
                            ) {
                                if reduceMotion {
                                    selectedState = state
                                    gameState.markSeismicZonesVisited()
                                } else {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        selectedState = state
                                    }
                                    gameState.markSeismicZonesVisited()
                                }
                            }
                        }

                        if filteredStates(for: country).isEmpty {
                            noResultsView
                                .padding(.top, 40)
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: 700)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Button(action: {
                withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.currentPhase = .result
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundColor(.orange)
            }
            .accessibilityLabel("Back")
            .accessibilityHint("Return to results screen")

            Spacer()

            Image(systemName: "globe.americas.fill")
                .font(.system(.title2))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .overlay(
            Text("Seismic Zones")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader),
            alignment: .center
        )
    }

    // MARK: - Country Selector

    private var countrySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(countries) { country in
                    CountryCard(
                        country: country,
                        isSelected: selectedCountry?.id == country.id,
                        differentiateWithoutColor: differentiateWithoutColor
                    ) {
                        if reduceMotion {
                            selectedCountry = country
                            selectedState = nil
                            searchText = ""
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedCountry = country
                                selectedState = nil
                                searchText = ""
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(.callout))
                .foregroundColor(.gray)

            TextField("Search states or regions", text: $searchText)
                .font(.system(.callout, design: .rounded))
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .accessibilityLabel("Search states or regions")

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(.callout))
                        .foregroundColor(.gray)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Risk Legend

    private var riskLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Risk Levels")
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundColor(.gray)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: 6) {
                ForEach(SeismicRiskLevel.allCases, id: \.rawValue) { level in
                    HStack(spacing: 3) {
                        Circle()
                            .fill(level.color)
                            .frame(width: 8, height: 8)
                        Text(level.label)
                            .font(.system(.caption2, design: .rounded, weight: .medium))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(level.label) risk")

                    if level.rawValue < SeismicRiskLevel.allCases.count - 1 {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - No Results

    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(.largeTitle))
                .foregroundColor(.gray.opacity(0.5))
                .accessibilityHidden(true)
            Text("No results found")
                .font(.system(.callout, design: .rounded, weight: .medium))
                .foregroundColor(.gray)
            Text("Try a different search term")
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.gray.opacity(0.6))
        }
    }

    // MARK: - State Detail View

    private func stateDetailView(state: SeismicState) -> some View {
        let country = selectedCountry ?? countries[0]

        return VStack(spacing: 0) {
            // Detail header
            HStack {
                Button(action: {
                    if reduceMotion {
                        selectedState = nil
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedState = nil
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(.footnote, weight: .semibold))
                        Text("Back")
                            .font(.system(.callout, design: .rounded, weight: .medium))
                    }
                    .foregroundColor(.orange)
                }
                .accessibilityLabel("Go back to state list")

                Spacer()

                Text("\(country.flag) \(country.name)")
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            ScrollView {
                VStack(spacing: 16) {
                    // State name and zone badge
                    stateHeaderCard(state: state, country: country)
                        .padding(.top, 12)

                    // Risk level indicator
                    riskLevelCard(state: state)

                    // Safety tips
                    safetyTipsCard(state: state)

                    // Low risk exploration banner
                    if state.riskLevel == .veryLow || state.riskLevel == .low {
                        explorationBanner(country: country)
                    }

                    // Historical earthquakes
                    historicalEarthquakesCard(country: country)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: 700)
        .frame(maxWidth: .infinity)
    }

    // MARK: - State Header Card

    private func stateHeaderCard(state: SeismicState, country: SeismicCountry) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Text(country.flag)
                    .font(.system(size: 40))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(state.name)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                        .accessibilityAddTraits(.isHeader)

                    Text("\(country.name) \u{2022} \(country.agency)")
                        .font(.system(.footnote, design: .rounded, weight: .medium))
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            // Zone badge
            HStack(spacing: 8) {
                Image(systemName: state.riskLevel.icon)
                    .font(.system(.callout))
                    .foregroundColor(state.riskLevel.color)

                Text(zoneBadgeText(state: state))
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundColor(state.riskLevel.color)

                Spacer()

                Text(state.riskLevel.label + " Risk")
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(state.riskLevel.color.opacity(0.25))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(state.riskLevel.color.opacity(0.4), lineWidth: 1)
                    )
            }

            Text(state.description)
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(state.riskLevel.color.opacity(0.2), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: - Risk Level Card

    private func riskLevelCard(state: SeismicState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk Assessment")
                .font(.system(.callout, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            // Risk bar
            HStack(spacing: 4) {
                ForEach(SeismicRiskLevel.allCases, id: \.rawValue) { level in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                level.rawValue <= state.riskLevel.rawValue
                                    ? level.color
                                    : Color.white.opacity(0.08)
                            )
                            .frame(height: level.rawValue <= state.riskLevel.rawValue ? 28 : 20)
                            .animation(
                                reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.7),
                                value: state.riskLevel
                            )

                        if differentiateWithoutColor {
                            Text(level == state.riskLevel ? "\u{25C6}" : "\u{25C7}")
                                .font(.system(.caption2))
                                .foregroundColor(level == state.riskLevel ? level.color : .gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(
                        "\(level.label): \(level.rawValue <= state.riskLevel.rawValue ? "Active" : "Inactive")"
                    )
                }
            }

            // Risk labels
            HStack {
                Text("Very Low")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Text("Very High")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundColor(.gray)
            }

            Text(state.riskLevel.description)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }

    // MARK: - Safety Tips Card

    private func safetyTipsCard(state: SeismicState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(.callout))
                    .foregroundColor(.orange)
                    .accessibilityHidden(true)
                Text("Safety Recommendations")
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .accessibilityAddTraits(.isHeader)
            }

            ForEach(Array(state.riskLevel.safetyTips.enumerated()), id: \.offset) { index, tip in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundColor(.orange)
                        .frame(width: 20, height: 20)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(Circle())

                    Text(tip)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Tip \(index + 1): \(tip)")
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Exploration Banner

    private func explorationBanner(country: SeismicCountry) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(.title3))
                .foregroundColor(.cyan)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Want to Learn More?")
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                Text("Explore high-risk zones in \(country.name) to understand the full earthquake experience and why preparedness matters everywhere.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.cyan.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: - Historical Earthquakes Card

    private func historicalEarthquakesCard(country: SeismicCountry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(.callout))
                    .foregroundColor(.yellow)
                    .accessibilityHidden(true)
                Text("Historical Earthquakes")
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .accessibilityAddTraits(.isHeader)
            }

            ForEach(country.historicalEarthquakes) { quake in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("M\(String(format: "%.1f", quake.magnitude))")
                            .font(.system(.footnote, design: .rounded, weight: .black))
                            .foregroundColor(magnitudeColor(quake.magnitude))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(magnitudeColor(quake.magnitude).opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 6))

                        Text("\(String(quake.year)) \u{2022} \(quake.location)")
                            .font(.system(.footnote, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()
                    }

                    Text(quake.description)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(
                    "Year \(quake.year), magnitude \(String(format: "%.1f", quake.magnitude)), \(quake.location). \(quake.description)"
                )
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Helpers

    private func filteredStates(for country: SeismicCountry) -> [SeismicState] {
        if searchText.isEmpty {
            return country.states
        }
        let query = searchText.lowercased()
        return country.states.filter { state in
            state.name.lowercased().contains(query)
                || state.zone.lowercased().contains(query)
                || state.riskLevel.label.lowercased().contains(query)
        }
    }

    private func zoneBadgeText(state: SeismicState) -> String {
        guard let country = selectedCountry else { return state.zone }
        switch country.agency {
        case "CENAPRED":
            return "Zone \(state.zone)"
        case "SENAPRED":
            return "Zone \(state.zone)"
        default:
            return state.zone
        }
    }

    private func magnitudeColor(_ magnitude: Double) -> Color {
        if magnitude >= 9.0 { return .red }
        if magnitude >= 8.0 { return .orange }
        if magnitude >= 7.0 { return .yellow }
        return .green
    }
}

// MARK: - Country Card

private struct CountryCard: View {
    let country: SeismicCountry
    let isSelected: Bool
    let differentiateWithoutColor: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(country.flag)
                    .font(.system(size: 30))
                    .accessibilityHidden(true)

                Text(country.name)
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundColor(isSelected ? .white : .gray)
                    .lineLimit(1)

                Text(country.agency)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundColor(isSelected ? .orange : .gray.opacity(0.6))
            }
            .frame(width: 80)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? Color.orange.opacity(0.12)
                    : Color.white.opacity(0.06)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color.orange.opacity(0.6) : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(country.name), \(country.agency)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to view seismic zones in \(country.name)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - State Row

private struct StateRow: View {
    let state: SeismicState
    let countryFlag: String
    let differentiateWithoutColor: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(state.riskLevel.color)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Group {
                            if differentiateWithoutColor {
                                Text(riskSymbol)
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(state.name)
                        .font(.system(.callout, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Zone \(state.zone) \u{2022} \(state.riskLevel.label) Risk")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(.caption))
                    .foregroundColor(.gray)
                    .accessibilityHidden(true)
            }
            .padding(14)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(state.name), \(state.riskLevel.label) risk, Zone \(state.zone)")
        .accessibilityHint("Double tap to view details")
    }

    private var riskSymbol: String {
        switch state.riskLevel {
        case .veryLow: return "1"
        case .low: return "2"
        case .moderate: return "3"
        case .high: return "4"
        case .veryHigh: return "5"
        }
    }
}
