import SwiftUI
import PhotosUI
import Vision
import UIKit

// MARK: - Vision Classification (Module-Level Free Function)

// IMPORTANT: This function MUST remain at module level, NOT inside any @MainActor class.
// Vision framework classification callbacks run on background threads.
// Placing this inside a @MainActor context causes Swift 6 to inject
// swift_task_isCurrentExecutor(MainActor) which crashes on the Vision callback thread.
func classifyRoomImage(_ image: UIImage, topK: Int = 20) async throws -> [(identifier: String, confidence: Float)] {
    guard let cgImage = image.cgImage else { return [] }
    // Use VNClassifyImageRequest WITHOUT a completion handler to avoid double-resume crash.
    // When espresso model loading fails, Vision calls the completion handler with an error
    // AND perform() throws the same error, causing continuation to resume twice.
    // Without a completion handler, perform() is purely synchronous:
    // success populates request.results, failure only throws -- exactly one code path.
    return try await withCheckedThrowingContinuation { continuation in
        let request = VNClassifyImageRequest()
        #if targetEnvironment(simulator)
        request.usesCPUOnly = true
        #endif
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            guard let results = request.results, !results.isEmpty else {
                continuation.resume(returning: [])
                return
            }
            let top = results.prefix(topK).map {
                (identifier: $0.identifier, confidence: $0.confidence)
            }
            continuation.resume(returning: top)
        } catch {
            continuation.resume(throwing: error)
        }
    }
}

// MARK: - Hazard Severity

enum HazardSeverity: Int, Sendable, Comparable {
    case low = 0
    case medium = 1
    case high = 2

    static func < (lhs: HazardSeverity, rhs: HazardSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }

    var icon: String {
        switch self {
        case .low: return "info.circle.fill"
        case .medium: return "exclamationmark.circle.fill"
        case .high: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Room Hazard

struct RoomHazard: Identifiable, Sendable {
    let id = UUID()
    let icon: String
    let name: String
    let recommendation: String
    let severity: HazardSeverity
    let isPositive: Bool

    init(icon: String, name: String, recommendation: String, severity: HazardSeverity, isPositive: Bool = false) {
        self.icon = icon
        self.name = name
        self.recommendation = recommendation
        self.severity = severity
        self.isPositive = isPositive
    }
}

// MARK: - Detected Hazard (with confidence)

struct DetectedHazard: Identifiable {
    let id = UUID()
    let hazard: RoomHazard
    let confidence: Float
    var confidencePercent: Int { Int(confidence * 100) }
}

// MARK: - Hazard Mapping Dictionary

// Split into smaller dictionaries to avoid Swift type checker hang (SR-4430)

private let highSeverityHazards: [String: RoomHazard] = [
    "bookcase": RoomHazard(
        icon: "books.vertical.fill", name: "Bookshelf",
        recommendation: "Anchor bookshelves to wall studs. Place heavier items on lower shelves.",
        severity: .high
    ),
    "bookshelf": RoomHazard(
        icon: "books.vertical.fill", name: "Bookshelf",
        recommendation: "Anchor bookshelves to wall studs. Place heavier items on lower shelves.",
        severity: .high
    ),
    "library": RoomHazard(
        icon: "books.vertical.fill", name: "Bookshelf",
        recommendation: "Anchor bookshelves to wall studs. Place heavier items on lower shelves.",
        severity: .high
    ),
    "window_shade": RoomHazard(
        icon: "window.vertical.open", name: "Window",
        recommendation: "Stay away from windows during earthquakes. Apply safety film to prevent shattering.",
        severity: .high
    ),
    "window_screen": RoomHazard(
        icon: "window.vertical.open", name: "Window",
        recommendation: "Stay away from windows during earthquakes. Apply safety film to prevent shattering.",
        severity: .high
    ),
    "chandelier": RoomHazard(
        icon: "light.cylindrical.ceiling.fill", name: "Ceiling Light / Chandelier",
        recommendation: "Secure hanging fixtures with safety cables. Do not place beds directly under heavy fixtures.",
        severity: .high
    ),
    "china_cabinet": RoomHazard(
        icon: "cabinet.fill", name: "China Cabinet",
        recommendation: "Anchor to wall studs. Use child-proof latches on doors. Place heavier items lower.",
        severity: .high
    ),
    "wardrobe": RoomHazard(
        icon: "cabinet.fill", name: "Wardrobe",
        recommendation: "Anchor tall wardrobes to wall studs to prevent toppling during shaking.",
        severity: .high
    ),
    "chiffonier": RoomHazard(
        icon: "cabinet.fill", name: "Tall Dresser",
        recommendation: "Anchor tall dressers to wall studs. Keep heavy items in lower drawers.",
        severity: .high
    ),
    "chest": RoomHazard(
        icon: "cabinet.fill", name: "Chest / Cabinet",
        recommendation: "Anchor tall cabinets to wall studs to prevent them from toppling.",
        severity: .high
    ),
    "entertainment_center": RoomHazard(
        icon: "tv.fill", name: "Entertainment Center",
        recommendation: "Anchor to wall. Secure electronics with anti-tip straps.",
        severity: .high
    ),
]

private let mediumSeverityHazards: [String: RoomHazard] = [
    "television": RoomHazard(
        icon: "tv.fill", name: "Television",
        recommendation: "Secure TV to its stand with anti-tip straps. Mount flat screens with proper wall brackets.",
        severity: .medium
    ),
    "monitor": RoomHazard(
        icon: "display", name: "Monitor",
        recommendation: "Secure monitors with anti-tip straps or mount them on adjustable arms.",
        severity: .medium
    ),
    "CRT": RoomHazard(
        icon: "tv.fill", name: "CRT Television",
        recommendation: "CRT TVs are very heavy. Secure with straps or place on low, sturdy furniture.",
        severity: .medium
    ),
    "screen": RoomHazard(
        icon: "tv.fill", name: "Screen / Display",
        recommendation: "Secure screens to prevent them from falling during shaking.",
        severity: .medium
    ),
    "mirror": RoomHazard(
        icon: "rectangle.portrait.fill", name: "Mirror / Glass",
        recommendation: "Mirrors can shatter dangerously. Move away from beds and seating areas, or apply safety film.",
        severity: .medium
    ),
    "refrigerator": RoomHazard(
        icon: "refrigerator.fill", name: "Refrigerator",
        recommendation: "Anchor refrigerator to wall. Keep heavy items on lower shelves inside.",
        severity: .medium
    ),
    "stove": RoomHazard(
        icon: "oven.fill", name: "Stove / Oven",
        recommendation: "Know how to shut off gas supply. Keep a fire extinguisher accessible nearby.",
        severity: .medium
    ),
    "microwave": RoomHazard(
        icon: "microwave.fill", name: "Microwave",
        recommendation: "Secure microwaves so they cannot slide off counters during shaking.",
        severity: .medium
    ),
    "file": RoomHazard(
        icon: "doc.fill", name: "Filing Cabinet",
        recommendation: "Anchor filing cabinets to wall. Lock drawers to prevent them sliding open during shaking.",
        severity: .medium
    ),
    "safe": RoomHazard(
        icon: "lock.shield.fill", name: "Safe / Heavy Box",
        recommendation: "Place heavy safes on the ground floor. Secure to prevent shifting during earthquakes.",
        severity: .medium
    ),
    "washing_machine": RoomHazard(
        icon: "washer.fill", name: "Washing Machine",
        recommendation: "Secure appliances with anti-vibration pads and flexible connections.",
        severity: .medium
    ),
    "dishwasher": RoomHazard(
        icon: "dishwasher.fill", name: "Dishwasher",
        recommendation: "Ensure built-in appliances are properly fastened. Use latches on doors.",
        severity: .medium
    ),
    "shower_curtain": RoomHazard(
        icon: "drop.fill", name: "Bathroom",
        recommendation: "Bathrooms have slippery surfaces and exposed pipes. Anchor water heater and know shutoff valves.",
        severity: .medium
    ),
    "bathtub": RoomHazard(
        icon: "bathtub.fill", name: "Bathtub Area",
        recommendation: "Bathrooms can be slippery during shaking. Secure items on shelves and know water shutoff location.",
        severity: .medium
    ),
    "plate_rack": RoomHazard(
        icon: "cup.and.saucer.fill", name: "Dish Rack",
        recommendation: "Dishes and glassware can fall and shatter. Use cabinet latches and store heavy items low.",
        severity: .medium
    ),
    "sliding_door": RoomHazard(
        icon: "door.sliding.left.hand.open", name: "Sliding Glass Door",
        recommendation: "Glass doors can shatter during shaking. Apply safety film and stay clear during earthquakes.",
        severity: .medium
    ),
]

private let lowSeverityHazards: [String: RoomHazard] = [
    "lamp": RoomHazard(
        icon: "lamp.desk.fill", name: "Lamp",
        recommendation: "Secure lamps with museum putty or velcro strips. Use LED bulbs that do not shatter.",
        severity: .low
    ),
    "table_lamp": RoomHazard(
        icon: "lamp.desk.fill", name: "Table Lamp",
        recommendation: "Secure lamps with museum putty or velcro strips. Use LED bulbs that do not shatter.",
        severity: .low
    ),
    "vase": RoomHazard(
        icon: "cup.and.saucer.fill", name: "Decorative Items",
        recommendation: "Secure vases and pottery with museum putty. Move fragile items to lower shelves.",
        severity: .low
    ),
    "pot": RoomHazard(
        icon: "cup.and.saucer.fill", name: "Pottery / Ceramics",
        recommendation: "Secure decorative pottery with museum putty. Store on lower shelves.",
        severity: .low
    ),
    "pitcher": RoomHazard(
        icon: "cup.and.saucer.fill", name: "Glass Pitcher",
        recommendation: "Store glass items on lower shelves with secure edges to prevent breakage.",
        severity: .low
    ),
    "wine_bottle": RoomHazard(
        icon: "wineglass.fill", name: "Glass Bottles",
        recommendation: "Store bottles on low shelves with rails or in closed cabinets with latches.",
        severity: .low
    ),
    "picture_frame": RoomHazard(
        icon: "photo.fill", name: "Picture Frame",
        recommendation: "Frames can fall off walls during shaking. Use earthquake-safe hooks and avoid hanging above beds.",
        severity: .low
    ),
    "rocking_chair": RoomHazard(
        icon: "chair.fill", name: "Rocking Chair",
        recommendation: "Rocking chairs can slide and tip during earthquakes. Place on non-slip pads away from windows.",
        severity: .low
    ),
    "throne": RoomHazard(
        icon: "chair.fill", name: "Heavy Chair",
        recommendation: "Large chairs can shift during shaking. Place on non-slip pads in open areas.",
        severity: .low
    ),
    "folding_chair": RoomHazard(
        icon: "chair.fill", name: "Folding Chair",
        recommendation: "Folding chairs are unstable during earthquakes. Store folded when not in use.",
        severity: .low
    ),
]

private let positiveItemHazards: [String: RoomHazard] = [
    "desk": RoomHazard(
        icon: "desktopcomputer", name: "Sturdy Desk",
        recommendation: "A sturdy desk can be excellent cover during earthquakes. Practice Drop, Cover, Hold On.",
        severity: .low,
        isPositive: true
    ),
    "dining_table": RoomHazard(
        icon: "table.furniture.fill", name: "Dining Table",
        recommendation: "A sturdy table provides good shelter. Get under it during shaking and hold on to a leg.",
        severity: .low,
        isPositive: true
    ),
    "water_bottle": RoomHazard(
        icon: "waterbottle.fill", name: "Water Supply",
        recommendation: "Keep water bottles accessible. Store at least 1 gallon per person per day for 3 days.",
        severity: .low,
        isPositive: true
    ),
    "water_jug": RoomHazard(
        icon: "waterbottle.fill", name: "Water Jug",
        recommendation: "Large water containers are excellent for emergency storage. Keep them filled and accessible.",
        severity: .low,
        isPositive: true
    ),
    "flashlight": RoomHazard(
        icon: "flashlight.on.fill", name: "Flashlight",
        recommendation: "Excellent! Keep flashlights in multiple rooms with fresh batteries for power outages.",
        severity: .low,
        isPositive: true
    ),
    "radio": RoomHazard(
        icon: "radio.fill", name: "Radio",
        recommendation: "A battery-powered radio is essential for receiving emergency broadcasts during outages.",
        severity: .low,
        isPositive: true
    ),
    "first_aid": RoomHazard(
        icon: "cross.case.fill", name: "First Aid Kit",
        recommendation: "Keep your first aid kit stocked and accessible. Check expiration dates regularly.",
        severity: .low,
        isPositive: true
    ),
    "studio_couch": RoomHazard(
        icon: "sofa.fill", name: "Couch",
        recommendation: "A sturdy couch can provide shelter during earthquakes. Get beside it for protection from falling debris.",
        severity: .low,
        isPositive: true
    ),
    "medicine_chest": RoomHazard(
        icon: "cross.case.fill", name: "Medicine Cabinet",
        recommendation: "Having medical supplies nearby is valuable. Secure the cabinet to prevent it from opening during shaking.",
        severity: .low,
        isPositive: true
    ),
]

let hazardMapping: [String: RoomHazard] = {
    var result = highSeverityHazards
    result.merge(mediumSeverityHazards) { current, _ in current }
    result.merge(lowSeverityHazards) { current, _ in current }
    result.merge(positiveItemHazards) { current, _ in current }
    return result
}()

// MARK: - Camera Picker

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView

        init(_ parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Room Scanner View

struct RoomScannerView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showCamera = false
    @State private var isAnalyzing = false
    @State private var detectedHazards: [DetectedHazard] = []
    @State private var positiveItems: [DetectedHazard] = []
    @State private var safetyScore: Int = 100
    @State private var analysisComplete = false
    @State private var analysisError: String?
    @State private var ringProgress: Double = 0
    @State private var animatedScore: Double = 0
    @State private var showResults = false

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.1), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if analysisComplete {
                resultsView
            } else if isAnalyzing {
                analyzingView
            } else {
                welcomeView
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView(image: $selectedImage)
        }
        .onChange(of: selectedPhotoItem) { newItem in
            guard let newItem = newItem else { return }
            Task {
                await loadPhoto(from: newItem)
            }
        }
        .onChange(of: selectedImage) { newImage in
            guard let newImage = newImage, !isAnalyzing else { return }
            Task {
                await analyzeImage(newImage)
            }
        }
    }

    // MARK: - Welcome View

    private var welcomeView: some View {
        VStack(spacing: 0) {
            HStack {
                backButton
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 30)

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.cyan.opacity(0.2), Color.clear],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 70
                                )
                            )
                            .frame(width: 140, height: 140)
                            .accessibilityHidden(true)

                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .accessibilityHidden(true)

                    VStack(spacing: 8) {
                        Text("Room Safety Scanner")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)

                        Text("Take a photo of any room and on-device image analysis will identify potential earthquake hazards with personalized safety recommendations.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                    howItWorksSection

                    VStack(spacing: 12) {
                        if isCameraAvailable {
                            Button(action: {
                                showCamera = true
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(.body, weight: .semibold))
                                    Text("Take Photo")
                                        .font(.system(.callout, design: .rounded, weight: .bold))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .accessibilityHint("Double tap to open the camera and take a photo of a room")
                        }

                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            HStack(spacing: 10) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(.body, weight: .semibold))
                                Text("Choose from Library")
                                    .font(.system(.callout, design: .rounded, weight: .bold))
                            }
                            .foregroundColor(isCameraAvailable ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                isCameraAvailable
                                    ? AnyShapeStyle(Color.white.opacity(0.1))
                                    : AnyShapeStyle(
                                        LinearGradient(
                                            colors: [.orange, .yellow],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .accessibilityHint("Double tap to choose a photo from your photo library")
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 40)
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            AccessibilityAnnouncement.announceScreenChange(
                "Room Safety Scanner. Take a photo or choose one from your library to analyze earthquake hazards."
            )
        }
    }

    // MARK: - How It Works Section

    private var howItWorksSection: some View {
        VStack(spacing: 12) {
            Text("How It Works")
                .font(.system(.footnote, design: .rounded, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            howItWorksStep(number: 1, icon: "camera.fill", text: "Take a photo of any room in your home")
            howItWorksStep(number: 2, icon: "brain", text: "AI analyzes objects for earthquake risks")
            howItWorksStep(number: 3, icon: "shield.checkered", text: "Get a safety score and recommendations")
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 20)
    }

    private func howItWorksStep(number: Int, icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.cyan.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(.caption, weight: .semibold))
                    .foregroundColor(.cyan)
            }
            .accessibilityHidden(true)

            Text(text)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            Spacer()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(number): \(text)")
    }

    // MARK: - Analyzing View

    private var analyzingView: some View {
        VStack(spacing: 28) {
            Spacer()

            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 2)
                    )
                    .overlay(
                        ZStack {
                            Color.black.opacity(0.4)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                        }
                    )
                    .accessibilityLabel("Selected photo being analyzed")
            }

            VStack(spacing: 8) {
                Text("Analyzing Your Room...")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundColor(.white)

                Text("Identifying potential earthquake hazards")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.gray)
            }

            if let error = analysisError {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(.title2))
                        .foregroundColor(.orange)

                    Text(error)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button(action: {
                        resetScanner()
                    }) {
                        Text("Try Again")
                            .font(.system(.callout, design: .rounded, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityHint("Double tap to return to the scanner and try again")
                }
            }

            Spacer()
        }
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Results View

    private var resultsView: some View {
        VStack(spacing: 0) {
            HStack {
                backButton
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 12)

                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .accessibilityLabel("Analyzed room photo")
                    }

                    if showResults {
                        safetyScoreRing
                            .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                    }

                    if !detectedHazards.isEmpty {
                        hazardListSection
                    }

                    if !positiveItems.isEmpty {
                        positiveItemsSection
                    }

                    if detectedHazards.isEmpty && positiveItems.isEmpty {
                        noHazardsSection
                    }

                    aboutAnalysisSection

                    actionButtons

                    Spacer().frame(height: 40)
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            startResultsAnimation()
        }
    }

    // MARK: - Safety Score Ring

    private var safetyScoreRing: some View {
        VStack(spacing: 12) {
            Text("Room Safety Score")
                .font(.system(.footnote, design: .rounded, weight: .bold))
                .foregroundColor(.gray)
                .accessibilityAddTraits(.isHeader)

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        LinearGradient(
                            colors: scoreGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(Int(animatedScore))")
                        .font(.system(.largeTitle, design: .rounded, weight: .black))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.white)
                    Text("out of 100")
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 150, height: 150)

            Text(scoreMessage)
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundColor(scoreGradientColors.first ?? .white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Room safety score: \(safetyScore) out of 100. \(scoreMessage)")
        .accessibilityAddTraits(.isImage)
    }

    private var scoreGradientColors: [Color] {
        if safetyScore >= 80 { return [.green, .mint] }
        if safetyScore >= 60 { return [.yellow, .orange] }
        if safetyScore >= 40 { return [.orange, .red] }
        return [.red, .pink]
    }

    private var scoreMessage: String {
        if safetyScore >= 90 {
            return "Excellent! Your room is well-prepared for earthquakes."
        } else if safetyScore >= 70 {
            return "Good! A few improvements will make your room safer."
        } else if safetyScore >= 50 {
            return "Several hazards found. Follow the recommendations below."
        } else {
            return "Significant hazards detected. Take action to improve safety."
        }
    }

    // MARK: - Hazard List Section

    private var hazardListSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Detected Hazards")
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(detectedHazards.count)")
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Capsule())
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Detected Hazards: \(detectedHazards.count)")
            .accessibilityAddTraits(.isHeader)

            ForEach(detectedHazards) { hazard in
                hazardCard(hazard)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Positive Items Section

    private var positiveItemsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                Text("Safety Assets")
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(positiveItems.count)")
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.15))
                    .clipShape(Capsule())
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Safety Assets: \(positiveItems.count)")
            .accessibilityAddTraits(.isHeader)

            ForEach(positiveItems) { item in
                positiveCard(item)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Hazard Card

    private func hazardCard(_ detected: DetectedHazard) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(detected.hazard.severity.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: detected.hazard.icon)
                    .font(.system(.body, weight: .semibold))
                    .foregroundColor(detected.hazard.severity.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(detected.hazard.name)
                        .font(.system(.footnote, design: .rounded, weight: .bold))
                        .foregroundColor(.white)

                    severityBadge(detected.hazard.severity)

                    confidenceBadge(detected.confidencePercent)
                }

                Text(detected.hazard.recommendation)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(detected.hazard.severity.color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    detected.hazard.severity.color.opacity(differentiateWithoutColor ? 0.3 : 0),
                    lineWidth: 1
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(detected.hazard.name), \(detected.hazard.severity.label) severity, \(detected.confidencePercent) percent confidence. \(detected.hazard.recommendation)")
    }

    // MARK: - Positive Card

    private func positiveCard(_ detected: DetectedHazard) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: detected.hazard.icon)
                    .font(.system(.body, weight: .semibold))
                    .foregroundColor(.green)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(detected.hazard.name)
                        .font(.system(.footnote, design: .rounded, weight: .bold))
                        .foregroundColor(.white)

                    Text("Helpful")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.15))
                        .clipShape(Capsule())

                    confidenceBadge(detected.confidencePercent)
                }

                Text(detected.hazard.recommendation)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.green.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.green.opacity(differentiateWithoutColor ? 0.3 : 0),
                    lineWidth: 1
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(detected.hazard.name), helpful item, \(detected.confidencePercent) percent confidence. \(detected.hazard.recommendation)")
    }

    // MARK: - Severity Badge

    private func severityBadge(_ severity: HazardSeverity) -> some View {
        HStack(spacing: 3) {
            if differentiateWithoutColor {
                Image(systemName: severity.icon)
                    .font(.system(.caption2))
            }
            Text(severity.label)
                .font(.system(.caption2, design: .rounded, weight: .bold))
        }
        .foregroundColor(severity.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(severity.color.opacity(0.15))
        .clipShape(Capsule())
    }

    // MARK: - Confidence Badge

    private func confidenceBadge(_ percent: Int) -> some View {
        Text("\(percent)%")
            .font(.system(.caption2, design: .rounded, weight: .bold))
            .foregroundColor(.white.opacity(0.5))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
    }

    // MARK: - No Hazards Section

    private var noHazardsSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .accessibilityHidden(true)

            Text("No Significant Hazards Detected")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: 8) {
                tipItem(icon: "sofa.fill", text: "Anchor heavy furniture to wall studs")
                tipItem(icon: "drop.fill", text: "Store emergency water (1 gal/person/day)")
                tipItem(icon: "flashlight.on.fill", text: "Keep flashlights in every room")
                tipItem(icon: "cross.case.fill", text: "Maintain a stocked first aid kit")
            }
            .padding(16)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 20)
    }

    private func tipItem(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(.caption, weight: .semibold))
                .foregroundColor(.green)
                .frame(width: 20)
            Text(text)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            Spacer()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }

    // MARK: - About Analysis Section

    private var aboutAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "brain")
                    .foregroundColor(.cyan)
                Text("About the Analysis")
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .accessibilityAddTraits(.isHeader)

            Text("This scanner uses Apple's Vision framework (VNClassifyImageRequest) to identify objects by analyzing the overall scene composition. The confidence percentage shows how certain the model is about each detection. Higher confidence means the object is more clearly present in the image.")
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 20)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                resetScanner()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.viewfinder")
                    Text("Scan Another Room")
                        .font(.system(.callout, design: .rounded, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityHint("Double tap to scan another room for earthquake hazards")

            Button(action: {
                withAnimation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.7)) {
                    gameState.currentPhase = .result
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                    Text("Back to Results")
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityHint("Double tap to return to results")
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Back Button

    private var backButton: some View {
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
    }

    // MARK: - Logic

    private func loadPhoto(from item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else {
            analysisError = "Could not load the selected photo. Please try another image."
            return
        }
        selectedImage = uiImage
    }

    private func analyzeImage(_ image: UIImage) async {
        isAnalyzing = true
        analysisComplete = false
        analysisError = nil
        detectedHazards = []
        positiveItems = []
        safetyScore = 100
        showResults = false

        do {
            let results = try await classifyRoomImage(image, topK: 15)

            var foundHazards: [DetectedHazard] = []
            var foundPositive: [DetectedHazard] = []
            var seenNames: Set<String> = []

            for result in results where result.confidence > 0.15 {
                if let hazard = hazardMapping[result.identifier] {
                    guard !seenNames.contains(hazard.name) else { continue }
                    seenNames.insert(hazard.name)

                    let detected = DetectedHazard(hazard: hazard, confidence: result.confidence)
                    if hazard.isPositive {
                        foundPositive.append(detected)
                    } else {
                        foundHazards.append(detected)
                    }
                }
            }

            foundHazards.sort { $0.hazard.severity > $1.hazard.severity }

            detectedHazards = foundHazards
            positiveItems = foundPositive

            var score = 100
            for item in foundHazards {
                let conf = Double(item.confidence)
                switch item.hazard.severity {
                case .high: score -= Int(15.0 * conf)
                case .medium: score -= Int(8.0 * conf)
                case .low: score -= Int(3.0 * conf)
                }
            }
            for item in foundPositive {
                score += Int(5.0 * Double(item.confidence))
            }
            safetyScore = max(0, min(100, score))

            isAnalyzing = false
            analysisComplete = true
            gameState.markRoomScannerUsed()

            AccessibilityAnnouncement.announceScreenChange(
                "Analysis complete. Room safety score: \(safetyScore) out of 100. \(foundHazards.count) hazards detected. \(foundPositive.count) safety assets found."
            )
        } catch {
            isAnalyzing = false
            analysisError = "Analysis failed. Please try again with a different photo."
        }
    }

    private func resetScanner() {
        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.3)) {
            selectedPhotoItem = nil
            selectedImage = nil
            isAnalyzing = false
            analysisComplete = false
            analysisError = nil
            detectedHazards = []
            positiveItems = []
            safetyScore = 100
            ringProgress = 0
            animatedScore = 0
            showResults = false
        }
    }

    private func startResultsAnimation() {
        if reduceMotion {
            showResults = true
            ringProgress = Double(safetyScore) / 100.0
            animatedScore = Double(safetyScore)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showResults = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 1.0)) {
                ringProgress = Double(safetyScore) / 100.0
            }
            let target = Double(safetyScore)
            let steps = 25
            for i in 0...steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) / Double(steps)) {
                    animatedScore = target * Double(i) / Double(steps)
                }
            }
        }
    }
}
