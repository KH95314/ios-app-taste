import SwiftUI

// Pattern: a day in colour blocks
// Direction 10 Color-Blocked Structure · kind: timeline · look: BlockLook.swift
// Sample product (invented): a volunteer's shift plan at an animal shelter.

/// A category. Its fill is how the day is read at a glance, and its icon is
/// what carries the same meaning without colour.
enum ShiftKind: String, CaseIterable, Identifiable {
    case feed, walk, clean, care, rest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .feed: "Feeding"
        case .walk: "Walk"
        case .clean: "Cleaning"
        case .care: "Vet and care"
        case .rest: "Break"
        }
    }

    var symbol: String {
        switch self {
        case .feed: "fork.knife"
        case .walk: "pawprint.fill"
        case .clean: "bubbles.and.sparkles.fill"
        case .care: "stethoscope"
        case .rest: "cup.and.saucer.fill"
        }
    }

    var fill: Color {
        switch self {
        case .feed: BlockLook.feed
        case .walk: BlockLook.walk
        case .clean: BlockLook.clean
        case .care: BlockLook.care
        case .rest: BlockLook.rest
        }
    }
}

struct ShiftBlock: Identifiable, Equatable {
    let id: Int
    var kind: ShiftKind
    /// Minutes after midnight.
    var start: Int
    var minutes: Int
    var title: String
    /// Where, or with whom.
    var detail = ""
    var isDone = false

    var end: Int { start + minutes }
}

struct DayPlan: Equatable {
    var blocks: [ShiftBlock]
    /// Minutes after midnight. The sample passes a fixed time so that its
    /// screenshots are stable. A real app reads the clock, for example in a
    /// `TimelineView` that ticks every minute.
    var now: Int?
}

struct ShiftDay: Identifiable {
    let id: Int
    let name: String
    let short: String
    let number: Int

    static let week: [ShiftDay] = [
        ShiftDay(id: 0, name: "Monday", short: "Mon", number: 12),
        ShiftDay(id: 1, name: "Tuesday", short: "Tue", number: 13),
        ShiftDay(id: 2, name: "Wednesday", short: "Wed", number: 14),
        ShiftDay(id: 3, name: "Thursday", short: "Thu", number: 15),
        ShiftDay(id: 4, name: "Friday", short: "Fri", number: 16),
        ShiftDay(id: 5, name: "Saturday", short: "Sat", number: 17),
        ShiftDay(id: 6, name: "Sunday", short: "Sun", number: 18),
    ]
}

struct DayBlocksScreen: View {
    @State private var phase: Phase<DayPlan>
    @State private var selectedDay: Int
    @State private var isAdding = false
    @State private var doneCount = 0
    /// The sample has one planned day. It is kept here while another day is shown.
    @State private var planned: (day: Int, phase: Phase<DayPlan>)

    init(phase: Phase<DayPlan>, day: Int = 5) {
        _phase = State(initialValue: phase)
        _selectedDay = State(initialValue: day)
        _planned = State(initialValue: (day, phase))
    }

    private var day: ShiftDay { ShiftDay.week[selectedDay] }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BlockLook.ground)
                // The day and the week stay in reach while the blocks scroll
                // under them. The header is solid, so a block never shows
                // through the title.
                .safeAreaInset(edge: .top, spacing: 0) {
                    DayHeader(selection: selectedDay, select: select)
                }
                .navigationTitle(day.name)
                .toolbarVisibility(.hidden, for: .navigationBar)
                .toolbar {
                    if showsAddButton {
                        ToolbarSpacer(.flexible, placement: .bottomBar)
                        ToolbarItem(placement: .bottomBar) {
                            Button { isAdding = true } label: { AddBlockFace() }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Add a block")
                                .disabled(!canAdd)
                        }
                        .sharedBackgroundVisibility(.hidden)
                    }
                }
                .sheet(isPresented: $isAdding) { AddBlockSheet(add: add) }
                .sensoryFeedback(.success, trigger: doneCount)
        }
        // Every control is ink. No control ever takes a category colour.
        .tint(BlockLook.ink)
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            PlaceholderDay()
        case .empty:
            ScrollsIfNeeded {
                ContentUnavailableView {
                    Label("Nothing planned for \(day.name)", systemImage: "calendar")
                } actions: {
                    Button("Add a block") { isAdding = true }
                        .buttonStyle(BlockInkButtonStyle())
                        .padding(.top, 8)
                    Button("Copy last \(day.name)") { phase = .loaded(.sample) }
                        .buttonStyle(BlockTextButtonStyle())
                }
            }
        case .loaded(let plan):
            timeline(plan, notice: nil)
        case .failed(let message, let stale?):
            timeline(stale, notice: message)
        case .failed(let message, nil):
            ScrollsIfNeeded {
                ContentUnavailableView {
                    Label("Couldn't load \(day.name)", systemImage: "wifi.slash")
                } description: {
                    // The system's grey for this line is about 3.5:1. The look's
                    // second ink holds 4.5:1.
                    Text(message)
                        .foregroundStyle(BlockLook.ink2)
                } actions: {
                    Button("Try again", action: retry)
                        .buttonStyle(BlockInkButtonStyle())
                }
            }
        }
    }

    private func timeline(_ plan: DayPlan, notice: String?) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BlockLook.gap) {
                if let notice {
                    BlockNotice(title: "You're offline", message: notice, retry: retry)
                        .padding(.bottom, 8)
                }
                ForEach(plan.blocks) { block in
                    if plan.gapBeforeNow == block.id, let now = plan.now {
                        NowBetweenBlocks(now: now)
                    }
                    BlockRow(block: block, now: plan.now) { toggle(block) }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
    }

    private var plan: DayPlan? {
        switch phase {
        case .loaded(let plan), .failed(_, let plan?): plan
        default: nil
        }
    }

    private var showsAddButton: Bool {
        if case .empty = phase { false } else { true }
    }

    private var canAdd: Bool {
        switch phase {
        case .loading, .failed(_, nil): false
        default: true
        }
    }

    private func store(_ plan: DayPlan) {
        if case .failed(let message, _) = phase {
            phase = .failed(message: message, stale: plan)
        } else {
            phase = .loaded(plan)
        }
    }

    private func toggle(_ block: ShiftBlock) {
        guard var plan, let index = plan.blocks.firstIndex(of: block) else { return }
        plan.blocks[index].isDone.toggle()
        if plan.blocks[index].isDone { doneCount += 1 }
        withAnimation { store(plan) }
    }

    private func add(_ title: String, kind: ShiftKind, minutes: Int) {
        var plan = plan ?? DayPlan(blocks: [], now: nil)
        let start = plan.blocks.map(\.end).max() ?? 9 * 60
        let nextID = (plan.blocks.map(\.id).max() ?? 0) + 1
        plan.blocks.append(ShiftBlock(id: nextID, kind: kind, start: start, minutes: minutes, title: title))
        withAnimation { store(plan) }
    }

    /// Sample only: every other day of the week is unplanned.
    private func select(_ day: Int) {
        guard day != selectedDay else { return }
        if selectedDay == planned.day { planned.phase = phase }
        selectedDay = day
        phase = day == planned.day ? planned.phase : .empty
    }

    /// Sample only: a real app would refetch here.
    private func retry() {
        phase = .loaded(plan ?? .sample)
    }
}

// MARK: - Choosing the day

/// The day's name over seven days in a row. At the accessibility text sizes
/// seven columns cannot hold a date each, so the header becomes the one day
/// with a step either side, and that line is the title.
private struct DayHeader: View {
    let selection: Int
    let select: (Int) -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if typeSize.isAccessibilitySize {
                stepper
            } else {
                Text(ShiftDay.week[selection].name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(BlockLook.ink)
                    .padding(.horizontal, 4)
                    .accessibilityAddTraits(.isHeader)
                strip
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BlockLook.ground)
        .overlay(alignment: .bottom) {
            Rectangle().fill(BlockLook.rule).frame(height: 1)
        }
    }

    private var strip: some View {
        HStack(spacing: 4) {
            ForEach(ShiftDay.week) { day in
                let isOn = day.id == selection
                Button { select(day.id) } label: {
                    VStack(spacing: 0) {
                        Text(day.short.prefix(1))
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(isOn ? BlockLook.ground : BlockLook.ink2)
                        Text(day.number, format: .number)
                            .font(.body)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                            .foregroundStyle(isOn ? BlockLook.ground : BlockLook.ink)
                    }
                    .frame(maxWidth: .infinity, minHeight: 56)
                    // The selected day is ink, like every other control.
                    .background(isOn ? BlockLook.ink : .clear, in: .rect(cornerRadius: BlockLook.radius))
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(day.name) \(day.number)")
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
    }

    private var stepper: some View {
        HStack {
            Button("Previous day", systemImage: "chevron.backward") { select(selection - 1) }
                .disabled(selection == 0)
            Spacer(minLength: 8)
            Text("\(ShiftDay.week[selection].name) \(ShiftDay.week[selection].number)")
                .font(.headline)
                .foregroundStyle(BlockLook.ink)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 8)
            Button("Next day", systemImage: "chevron.forward") { select(selection + 1) }
                .disabled(selection == ShiftDay.week.count - 1)
        }
        .labelStyle(.iconOnly)
        .font(.headline)
        .frame(minHeight: 44)
        .padding(.horizontal, 4)
    }
}

// MARK: - One item of the day

private struct BlockRow: View {
    let block: ShiftBlock
    let now: Int?
    let toggle: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .footnote) private var gutter = 62.0
    @State private var textHeight = 0.0
    @State private var faceHeight = 0.0

    private var isCompact: Bool { typeSize.isAccessibilitySize }

    /// How far through this block the day is, if it is the current one.
    private var elapsed: Double? {
        guard let now, !block.isDone, block.kind != .rest, (block.start..<block.end).contains(now) else { return nil }
        return Double(now - block.start) / Double(block.minutes)
    }

    /// The now line moves through the space under the text and never crosses it.
    private var nowY: Double? {
        guard let elapsed, !isCompact else { return nil }
        let top = 12 + textHeight + 10
        return top + max(0, faceHeight - top - 12) * elapsed
    }

    var body: some View {
        if isCompact {
            face
        } else {
            HStack(alignment: .top, spacing: 8) {
                Text(BlockTime.clock(block.start))
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .foregroundStyle(BlockLook.ink2)
                    .frame(width: gutter, alignment: .trailing)
                    .padding(.top, 14)
                face
            }
            .overlay(alignment: .topLeading) {
                if let nowY, let now {
                    // The time beside the line, in ink, level with it.
                    Text(BlockTime.clock(now))
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .foregroundStyle(BlockLook.ground)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(BlockLook.ink, in: .capsule)
                        .fixedSize()
                        // A frame with no height, so the label is centred on
                        // the same line the block draws.
                        .frame(width: gutter + 6, height: 0, alignment: .trailing)
                        .offset(y: nowY)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    @ViewBuilder private var face: some View {
        if block.isDone {
            doneFace
        } else if block.kind == .rest {
            restFace
        } else {
            blockFace
        }
    }

    private var blockFace: some View {
        HStack(alignment: .top, spacing: 4) {
            VStack(alignment: .leading, spacing: 2) {
                if isCompact {
                    Text(compactTime)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
                Text(block.title)
                    .font(.title3)
                    .fontWeight(.bold)
                // How long comes first: the block's height only supports it.
                Label(detail, systemImage: block.kind.symbol)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .accessibilityLabel("\(block.kind.title), \(detail)")
            }
            .padding(.vertical, 12)
            .onGeometryChange(for: Double.self) { $0.size.height - 24 } action: { textHeight = $0 }
            Spacer(minLength: 0)
            Button(action: toggle) {
                Label("Mark as done", systemImage: "circle")
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(minWidth: 44, minHeight: 48)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 16)
        .padding(.trailing, 4)
        // A current block keeps room under its text for the now line.
        .padding(.bottom, elapsed != nil && !isCompact ? 28 : 0)
        .frame(maxWidth: .infinity, minHeight: BlockTime.height(for: block.minutes), alignment: .topLeading)
        // Solid white on every fill. Never dimmed to show that a block is later.
        .foregroundStyle(BlockLook.onBlock)
        .background(block.kind.fill, in: .rect(cornerRadius: BlockLook.radius))
        .onGeometryChange(for: Double.self) { $0.size.height } action: { faceHeight = $0 }
        .overlay(alignment: .top) {
            if let nowY {
                Rectangle()
                    .fill(BlockLook.onBlock)
                    .frame(height: 2)
                    .offset(y: nowY - 1)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(elapsed == nil ? "" : "Happening now")
    }

    /// A break is neutral and short: it is not a kind of work.
    private var restFace: some View {
        Label(isCompact ? "\(compactTime) · \(detail)" : detail, systemImage: block.kind.symbol)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(BlockLook.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .background(BlockLook.rest, in: .rect(cornerRadius: BlockLook.radius))
    }

    /// A finished item gives up its colour and its height, so what is left to
    /// do takes the space. The tick is the sign; the strike-through supports it.
    private var doneFace: some View {
        HStack(spacing: 0) {
            Button(action: toggle) {
                Label("Mark as not done", systemImage: "checkmark")
                    .labelStyle(.iconOnly)
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            // Only the name is struck through. The time is still a fact.
            if isCompact {
                Text("\(Text(block.title).strikethrough()), \(BlockTime.clock(block.start))")
            } else {
                Text(block.title).strikethrough()
            }
        }
        .foregroundStyle(BlockLook.ink2)
        .padding(.leading, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityValue("Done")
    }

    private var detail: String {
        let length = BlockTime.length(block.minutes)
        if block.kind == .rest { return "\(block.title) · \(length)" }
        return block.detail.isEmpty ? length : "\(length) · \(block.detail)"
    }

    private var compactTime: String {
        guard let now, elapsed != nil else { return BlockTime.clock(block.start) }
        return "\(BlockTime.clock(block.start)) · now \(BlockTime.clock(now))"
    }
}

/// Now, when it falls between two blocks.
private struct NowBetweenBlocks: View {
    let now: Int

    var body: some View {
        HStack(spacing: 8) {
            Text("Now \(BlockTime.clock(now))")
                .font(.footnote)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(BlockLook.ground)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(BlockLook.ink, in: .capsule)
            Rectangle().fill(BlockLook.ink).frame(height: 2)
        }
        .padding(.vertical, 6)
    }
}

/// Placeholders are neutral. Until the data arrives nothing has a category,
/// so nothing gets a category colour.
private struct PlaceholderDay: View {
    var body: some View {
        ScrollView {
            VStack(spacing: BlockLook.gap) {
                ForEach([44.0, 108, 132, 84, 84], id: \.self) { height in
                    RoundedRectangle(cornerRadius: BlockLook.radius)
                        .fill(BlockLook.rest)
                        .frame(height: height)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
        }
        .disabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading the plan")
    }
}

/// The add button is ink for the same reason the selected day is.
private struct AddBlockFace: View {
    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric private var size = 52.0

    var body: some View {
        Image(systemName: "plus")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(isEnabled ? BlockLook.ground : BlockLook.ink2)
            .frame(width: size, height: size)
            .background(isEnabled ? BlockLook.ink : BlockLook.rest, in: .circle)
            .contentShape(.circle)
    }
}

private struct AddBlockSheet: View {
    let add: (String, ShiftKind, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var kind = ShiftKind.walk
    @State private var minutes = 30
    @FocusState private var isFocused: Bool

    private var trimmed: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                TextField("What is it?", text: $title, axis: .vertical)
                    .focused($isFocused)
                Picker("Kind", selection: $kind) {
                    ForEach(ShiftKind.allCases) { kind in
                        Label(kind.title, systemImage: kind.symbol).tag(kind)
                    }
                }
                Picker("Length", selection: $minutes) {
                    ForEach([15, 30, 45, 60, 90], id: \.self) { minutes in
                        Text(BlockTime.length(minutes)).tag(minutes)
                    }
                }
            }
            .navigationTitle("New block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        add(trimmed, kind, minutes)
                        dismiss()
                    }
                    .disabled(trimmed.isEmpty)
                }
            }
            .onAppear { isFocused = true }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Times and sample data

enum BlockTime {
    /// A clock time in the reader's own format, 12- or 24-hour.
    static func clock(_ minutes: Int) -> String {
        let date = Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: .now) ?? .now
        return date.formatted(date: .omitted, time: .shortened)
    }

    static func length(_ minutes: Int) -> String {
        Duration.seconds(minutes * 60).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }

    /// A longer block is taller, within limits: never shorter than its text,
    /// and never so tall that an afternoon fills the screen.
    static func height(for minutes: Int) -> Double {
        min(max(36 + Double(minutes) * 1.6, 64), 200)
    }
}

extension DayPlan {
    /// The block that now falls just before, when no block contains it.
    var gapBeforeNow: Int? {
        guard let now, !blocks.contains(where: { ($0.start..<$0.end).contains(now) && !$0.isDone }) else { return nil }
        return blocks.first { $0.start > now }?.id
    }

    static let sample = DayPlan(blocks: [
        ShiftBlock(id: 1, kind: .feed, start: 7 * 60 + 30, minutes: 30, title: "Morning feed", detail: "kennels A–C", isDone: true),
        ShiftBlock(id: 2, kind: .walk, start: 8 * 60, minutes: 45, title: "Walk Biscuit and Pru", detail: "river loop"),
        ShiftBlock(id: 3, kind: .clean, start: 9 * 60, minutes: 60, title: "Deep-clean kennel 4", detail: "with Tomas"),
        ShiftBlock(id: 4, kind: .care, start: 10 * 60 + 15, minutes: 30, title: "Vet round", detail: "Dr Osei, kennels A–C"),
        ShiftBlock(id: 5, kind: .rest, start: 11 * 60, minutes: 20, title: "Break"),
        ShiftBlock(id: 6, kind: .feed, start: 11 * 60 + 30, minutes: 30, title: "Midday feed", detail: "puppies first"),
        ShiftBlock(id: 7, kind: .walk, start: 12 * 60, minutes: 30, title: "Walk Otis", detail: "yard"),
        ShiftBlock(id: 8, kind: .clean, start: 12 * 60 + 30, minutes: 30, title: "Laundry", detail: "blankets and towels"),
    ], now: 8 * 60 + 27)

    /// Fifty minutes later: the walk is ticked off and the next block is under way.
    static let afterWalk: DayPlan = {
        var plan = sample
        plan.blocks[1].isDone = true
        plan.now = 9 * 60 + 20
        return plan
    }()
}
