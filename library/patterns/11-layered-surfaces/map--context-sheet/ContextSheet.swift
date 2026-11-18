import MapKit
import SwiftUI

// Pattern: context with a resizable detail sheet
// Direction 11 Layered Surfaces · kind: map · look: LayerLook.swift
// Sample product (invented): a finder for public drinking-water refill points.

struct RefillPoint: Identifiable, Equatable {
    let id: Int
    var name: String
    var latitude: Double
    var longitude: Double
    var distance: String
    var walk: String
    var isWorking: Bool
    var checked: String
    var features: [String]
    var hours: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

private extension RefillPoint {
    /// The two facts needed to decide whether to go. The distance carries the
    /// weight; the rest of the line is second-level.
    var fact: Text {
        Text("\(Text(distance).fontWeight(.semibold).foregroundStyle(LayerLook.ink)) · \(walk)")
    }
}

struct ContextSheetScreen: View {
    @State private var phase: Phase<[RefillPoint]>
    @State private var selectedID: Int?
    @State private var reportedIDs: Set<Int>
    @State private var camera = MapCameraPosition.region(.park)
    @State private var isReporting = false

    // The resting height is measured, not hard-coded: see `restingHeight`.
    @State private var headerHeight = 120.0
    @State private var barHeight = 0.0
    @State private var screenHeight = 800.0
    /// Whether the person has pulled the sheet up to its full height.
    @State private var isLarge = false
    /// False until the sheet has taken its first measured height, which it
    /// does at once. Later changes of height are animated.
    @State private var hasSettled = false

    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(phase: Phase<[RefillPoint]>, selectedID: Int? = nil, reportedIDs: Set<Int> = []) {
        _phase = State(initialValue: phase)
        _selectedID = State(initialValue: selectedID)
        _reportedIDs = State(initialValue: reportedIDs)
    }

    private var points: [RefillPoint] {
        if case .loaded(let points) = phase { points } else { [] }
    }

    private var selected: RefillPoint? {
        points.first { $0.id == selectedID }
    }

    /// Tall enough for the header and the pinned action at the current text
    /// size, but never more than about three fifths of the screen, so the map
    /// stays in view. Past that the header scrolls and the action stays pinned.
    private var restingHeight: Double {
        min(headerHeight + barHeight + 32, screenHeight * 0.62)
    }

    var body: some View {
        Map(position: $camera, selection: $selectedID) {
            ForEach(points) { point in
                // A point that can't be used changes its glyph as well as its
                // colour, so the two kinds differ without colour.
                Marker(point.name, systemImage: isWorking(point) ? "drop.fill" : "exclamationmark", coordinate: point.coordinate)
                    .tint(isWorking(point) ? LayerLook.pin : LayerLook.pinOff)
                    .tag(point.id)
            }
        }
        // Keeps the selected marker, and the map's own attribution, above the
        // sheet instead of underneath it. The room follows the sheet's height
        // frame by frame, so the map glides with it.
        .modifier(MapRoom(height: restingHeight))
        .animation(hasSettled ? .snappy(duration: 0.3) : nil, value: restingHeight)
        .onGeometryChange(for: Double.self) { $0.size.height } action: { screenHeight = $0 }
        .onChange(of: selectedID) {
            guard let selected else { return }
            withAnimation {
                camera = .region(MKCoordinateRegion(center: selected.coordinate, span: MKCoordinateRegion.park.span))
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(600))
            hasSettled = true
        }
        .sheet(isPresented: .constant(true)) {
            sheet
                // The sheet's controls are ink. Colour stays with the map.
                .tint(LayerLook.ink)
                // The sheet follows its content from one resting height to
                // another, and the map stays usable while it rests.
                .modifier(RestingDetent(height: restingHeight, isLarge: $isLarge))
                .animation(hasSettled ? .snappy(duration: 0.3) : nil, value: restingHeight)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
        }
    }

    private var sheet: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                    .onGeometryChange(for: Double.self) { $0.size.height } action: { headerHeight = $0 }

                if let selected {
                    // Everything below the header belongs to the pulled-up sheet,
                    // so the resting sheet never ends on a half-cut line.
                    VStack(alignment: .leading, spacing: 20) {
                        if dynamicTypeSize.isAccessibilitySize { reportButton(for: selected) }
                        PointDetails(point: selected)
                    }
                    .opacity(isLarge ? 1 : 0)
                    .animation(.default, value: isLarge)
                }
            }
            .foregroundStyle(LayerLook.ink)
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        // The main action is pinned, so it is on screen at every text size and
        // at both sheet heights.
        .safeAreaBar(edge: .bottom) {
            bar
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .onGeometryChange(for: Double.self) { $0.size.height } action: { barHeight = $0 }
        }
    }

    /// Identity and the facts needed to decide. Visible while the sheet rests.
    @ViewBuilder private var header: some View {
        switch phase {
        case .loading:
            HStack {
                ProgressView()
                Text("Finding refill points near you…")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .empty:
            // The button below says what to do next, so there is no sentence
            // here repeating it.
            SheetMessage(title: "No refill points within 2 km")
        case .failed(let message, _):
            SheetMessage(title: "Couldn't load refill points", cause: message)
        case .loaded(let points):
            if let selected {
                PointHeader(point: selected, isReported: reportedIDs.contains(selected.id)) {
                    selectedID = nil
                }
            } else {
                NearbyList(points: points, isWorking: isWorking) { selectedID = $0.id }
            }
        }
    }

    /// One main action per state. A second action sits beside it only when both
    /// fit on one line at ordinary text sizes.
    @ViewBuilder private var bar: some View {
        switch phase {
        case .empty:
            wideButton("Search a wider area") { phase = .loaded(.sample) }
        case .failed:
            wideButton("Try again") { phase = .loaded(.sample) }
        case .loaded:
            if let selected {
                if dynamicTypeSize.isAccessibilitySize {
                    directionsButton(to: selected)
                } else {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 8) {
                            directionsButton(to: selected)
                            reportButton(for: selected).fixedSize()
                        }
                        .lineLimit(1)
                        VStack(spacing: 8) {
                            directionsButton(to: selected)
                            reportButton(for: selected)
                        }
                    }
                }
            } else {
                Color.clear.frame(height: 0)
            }
        case .loading:
            Color.clear.frame(height: 0)
        }
    }

    private func wideButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).frame(maxWidth: .infinity)
        }
        .buttonStyle(LayerButtonStyle(kind: .main))
    }

    private func directionsButton(to point: RefillPoint) -> some View {
        Button {
            if let url = URL(string: "maps://?daddr=\(point.latitude),\(point.longitude)&dirflg=w") {
                openURL(url)
            }
        } label: {
            Label("Directions", systemImage: "figure.walk")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(LayerButtonStyle(kind: .main))
    }

    private func reportButton(for point: RefillPoint) -> some View {
        Button {
            isReporting = true
        } label: {
            Label("Report a problem", systemImage: "exclamationmark.bubble")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(LayerButtonStyle(kind: .second))
        .disabled(reportedIDs.contains(point.id))
        .confirmationDialog("What's wrong with this refill point?", isPresented: $isReporting, titleVisibility: .visible) {
            Button("It isn't working") { reportedIDs.insert(point.id) }
            Button("It's dirty or blocked") { reportedIDs.insert(point.id) }
        }
    }

    private func isWorking(_ point: RefillPoint) -> Bool {
        point.isWorking && !reportedIDs.contains(point.id)
    }
}

/// Gives the sheet a resting height that can be animated. SwiftUI changes a
/// sheet's detents in a single frame, however the change is made. An
/// animatable value hands the sheet a new height every frame instead, and
/// that reads as a glide.
private struct RestingDetent: ViewModifier, Animatable {
    var height: Double
    @Binding var isLarge: Bool

    var animatableData: Double {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        let resting = PresentationDetent.height(height)
        content
            .presentationDetents([resting, .large], selection: Binding(
                get: { isLarge ? .large : resting },
                set: { isLarge = $0 == .large }))
            .presentationBackgroundInteraction(.enabled(upThrough: resting))
    }
}

/// The room the map keeps clear for the sheet, animatable for the same
/// reason: a new padding every frame, not one jump.
private struct MapRoom: ViewModifier, Animatable {
    var height: Double

    var animatableData: Double {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        content.safeAreaPadding(.bottom, height)
    }
}

private struct PointHeader: View {
    let point: RefillPoint
    let isReported: Bool
    let close: () -> Void
    @ScaledMetric(relativeTo: .footnote) private var disc = 32.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(point.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    point.fact
                        .font(.subheadline)
                        .foregroundStyle(LayerLook.ink2)
                }
                Spacer()
                Button(action: close) {
                    Image(systemName: "xmark")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .frame(width: disc, height: disc)
                        .background(LayerLook.control, in: .circle)
                        // The disc is small; the target around it is not.
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back to nearby points")
                .padding([.top, .trailing], -6)
            }
            status
        }
    }

    /// The result of an action replaces the status it changed. The badge, the
    /// greyed button and the pin already show what happened, so no sentence
    /// is added to say it again.
    @ViewBuilder private var status: some View {
        if isReported {
            StatusBadge(text: "Problem reported", tone: .warning)
        } else if point.isWorking {
            StatusBadge(text: "Working · checked \(point.checked)", tone: .ok)
        } else {
            StatusBadge(text: "Reported not working · \(point.checked)", tone: .warning)
        }
    }
}

private struct PointDetails: View {
    let point: RefillPoint

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("At this point")
                    .font(.headline)
                ForEach(point.features, id: \.self) { feature in
                    Label {
                        Text(feature)
                    } icon: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(LayerLook.ink2)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("When it runs")
                    .font(.headline)
                Text(point.hours)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct NearbyList: View {
    let points: [RefillPoint]
    let isWorking: (RefillPoint) -> Bool
    let select: (RefillPoint) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("^[\(points.count) refill point](inflect: true) nearby")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            ForEach(points) { point in
                Button {
                    select(point)
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        // The same hue and glyph as the point's pin on the map.
                        Image(systemName: isWorking(point) ? "drop.fill" : "exclamationmark.circle.fill")
                            .foregroundStyle(isWorking(point) ? LayerLook.pin : LayerLook.pinOff)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(point.name)
                            (isWorking(point) ? point.fact : Text("\(point.fact) · reported not working"))
                                .font(.subheadline)
                                .foregroundStyle(LayerLook.ink2)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .frame(minHeight: 44)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                Rectangle()
                    .fill(LayerLook.rule)
                    .frame(height: 1)
            }
        }
    }
}

/// Empty and failed states inside the sheet. The action is in the pinned bar
/// and the map behind stays visible. `cause` is for something the screen
/// cannot show by itself, such as being offline.
private struct SheetMessage: View {
    let title: String
    var cause: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            if let cause {
                Text(cause)
                    .font(.subheadline)
                    .foregroundStyle(LayerLook.ink2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension MKCoordinateRegion {
    static let park = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.0297, longitude: 121.5358),
        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
    )
}

extension [RefillPoint] {
    /// Invented sample data placed around a real park. Not real refill points.
    static let sample: [RefillPoint] = [
        RefillPoint(id: 1, name: "North gate fountain", latitude: 25.0331, longitude: 121.5352,
                    distance: "350 m", walk: "5 min walk", isWorking: true, checked: "2 days ago",
                    features: ["Bottle filler", "Step-free access", "Dog bowl at ground level"],
                    hours: "Always on. Shut off for cleaning on the first Monday of each month."),
        RefillPoint(id: 2, name: "Playground refill point", latitude: 25.0302, longitude: 121.5339,
                    distance: "520 m", walk: "7 min walk", isWorking: true, checked: "today",
                    features: ["Bottle filler", "Low spout for children"],
                    hours: "6 AM to 10 PM."),
        RefillPoint(id: 3, name: "Pond-side tap", latitude: 25.0288, longitude: 121.5371,
                    distance: "700 m", walk: "9 min walk", isWorking: false, checked: "yesterday",
                    features: ["Hand tap only"],
                    hours: "Always on."),
        RefillPoint(id: 4, name: "Amphitheatre fountain", latitude: 25.0269, longitude: 121.5350,
                    distance: "900 m", walk: "12 min walk", isWorking: true, checked: "5 days ago",
                    features: ["Bottle filler", "Step-free access"],
                    hours: "Always on."),
    ]
}
