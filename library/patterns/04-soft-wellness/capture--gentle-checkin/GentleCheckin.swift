import SwiftUI

// Pattern: a check-in without a score
// Direction 04 Soft Wellness · kind: capture · look: SoftLook.swift
// Sample product (invented): an energy diary for someone pacing a recovery.

struct EnergyEntry: Identifiable, Equatable {
    let id: Int
    /// 0 to 4. Neither end is better; they are different days.
    var level: Int
    var time: String
}

struct EnergyDay: Equatable {
    static let words = ["Empty", "Low", "Steady", "Good", "Full"]

    /// When this check-in is for. The sample keeps it as words so that its
    /// screenshots are stable; a real app formats a date.
    var when: String
    var time: String
    /// Check-ins made earlier today.
    var earlier: [EnergyEntry]
    /// The person's own usual level at this time, once there is enough
    /// history to know it.
    var usualLevel: Int?
    var usualLabel = ""
    /// The check-in just saved, if there is one.
    var saved: EnergyEntry?
    var note = ""

    /// A value is compared with the person's own usual, in plain words. Never
    /// with a target and never with other people.
    func comparison(for level: Int) -> String? {
        guard let usualLevel else { return nil }
        if level == usualLevel { return "about your usual for \(usualLabel)" }
        return level < usualLevel ? "lower than your usual for \(usualLabel)" : "higher than your usual for \(usualLabel)"
    }
}

struct GentleCheckinScreen: View {
    @State private var phase: Phase<EnergyDay>
    @State private var picked: Int?
    @State private var isWritingNote = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    init(phase: Phase<EnergyDay>, picked: Int? = nil) {
        _phase = State(initialValue: phase)
        _picked = State(initialValue: picked)
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Once an answer is saved, a soft light gathers behind it.
                .background {
                    SoftGround(glow: isSaved ? 1 : 0)
                        .ignoresSafeArea()
                        .animation(.smooth(duration: 1.4), value: isSaved)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back", systemImage: "chevron.backward") { dismiss() }
                    }
                }
                .sheet(isPresented: $isWritingNote) {
                    NoteSheet(note: day?.note ?? "") { note in
                        change { $0.note = note }
                    }
                }
                // Choosing and saving are felt, softly. Nothing celebrates.
                .sensoryFeedback(.selection, trigger: picked)
                .sensoryFeedback(.impact(flexibility: .soft), trigger: day?.saved)
        }
        .tint(SoftLook.ink)
        .fontDesign(.rounded)
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            picker(.placeholder)
                .redacted(reason: .placeholder)
                .disabled(true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Loading today")
        case .empty:
            // A first check-in: the same question, with no history under it.
            picker(.first)
        case .loaded(let day):
            if day.saved == nil { picker(day) } else { summary(day, notice: nil) }
        case .failed(let message, let stale?):
            if stale.saved == nil { picker(stale) } else { summary(stale, notice: message) }
        case .failed(let message, nil):
            ScrollsIfNeeded {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.slash")
                        .font(.largeTitle)
                        .foregroundStyle(SoftLook.ink2)
                        .accessibilityHidden(true)
                    Text("Couldn't open your diary")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(SoftLook.ink)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(SoftLook.ink2)
                    Button("Try again", action: retry)
                        .buttonStyle(SoftButtonStyle())
                        .padding(.top, 12)
                }
                .multilineTextAlignment(.center)
                .padding(32)
            }
        }
    }

    // MARK: Choosing

    private func picker(_ day: EnergyDay) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("How’s your energy?")
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .foregroundStyle(SoftLook.ink)
                    .accessibilityAddTraits(.isHeader)
                WhenRow(when: day.when, setWhen: setWhen)
                // Five choices of equal standing. The one chosen is marked
                // the same way whichever it is.
                VStack(spacing: 8) {
                    ForEach((0..<EnergyDay.words.count).reversed(), id: \.self) { level in
                        ChoiceRow(level: level, isOn: level == picked) { picked = level }
                    }
                }
                .padding(.top, 12)
                if typeSize.isAccessibilitySize {
                    noteButton(day)
                        .padding(.top, 12)
                }
                if !day.earlier.isEmpty {
                    TodaySoFar(entries: day.earlier)
                        .padding(.top, 24)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomBar {
                // At the largest text sizes only the main button stays pinned.
                if !typeSize.isAccessibilitySize { noteButton(day) }
                Button("Save check-in", action: save)
                    .buttonStyle(SoftButtonStyle())
                    .disabled(picked == nil)
            }
        }
    }

    private func noteButton(_ day: EnergyDay) -> some View {
        // The title says whether there is a note. No "Note added" follows.
        Button(day.note.isEmpty ? "Add a note" : "Edit note", systemImage: "note.text") { isWritingNote = true }
            .buttonStyle(SoftTextButtonStyle())
            .frame(maxWidth: .infinity)
    }

    // MARK: Saved

    private func summary(_ day: EnergyDay, notice: String?) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                if let notice {
                    SoftNotice(title: "Not saved to your account", message: notice, retry: retry)
                        .padding(.bottom, 24)
                }
                if let saved = day.saved {
                    SavedAnswer(entry: saved, comparison: day.comparison(for: saved.level))
                    TodaySoFar(entries: day.earlier + [saved])
                        .padding(16)
                        .background(SoftLook.surface, in: .rect(cornerRadius: SoftLook.radius))
                        .padding(.top, 32)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, notice == nil ? 32 : 8)
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomBar {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        changeButton
                        doneButton
                    }
                    VStack(spacing: 8) {
                        doneButton
                        changeButton
                    }
                }
            }
        }
    }

    private var changeButton: some View {
        Button("Change", action: reopen)
            .buttonStyle(SoftButtonStyle(kind: .quiet))
    }

    private var doneButton: some View {
        Button("Done") { dismiss() }
            .buttonStyle(SoftButtonStyle())
    }

    // MARK: State

    private var day: EnergyDay? {
        switch phase {
        case .loaded(let day), .failed(_, let day?): day
        case .empty: .first
        default: nil
        }
    }

    private func change(_ edit: (inout EnergyDay) -> Void) {
        guard var day else { return }
        edit(&day)
        if case .failed(let message, _) = phase {
            phase = .failed(message: message, stale: day)
        } else {
            phase = .loaded(day)
        }
    }

    private var isSaved: Bool { day?.saved != nil }

    private func save() {
        guard let picked else { return }
        withAnimation(.smooth(duration: 0.45)) {
            change { day in
                let nextID = (day.earlier.map(\.id).max() ?? 0) + 1
                day.saved = EnergyEntry(id: nextID, level: picked, time: day.time)
            }
        }
    }

    /// Back to the question with the saved answer still chosen.
    private func reopen() {
        picked = day?.saved?.level
        withAnimation(.smooth(duration: 0.45)) {
            change { $0.saved = nil }
        }
    }

    /// Sample only: a real app keeps a date and formats it.
    private func setWhen(_ when: String, time: String) {
        change { day in
            day.when = when
            day.time = time
        }
    }

    /// Sample only: a real app would sync or refetch here.
    private func retry() {
        phase = .loaded(day ?? .sample)
    }
}

// MARK: - Parts

/// When the check-in is for, and a way to move it. People often log a
/// feeling a while after it.
private struct WhenRow: View {
    let when: String
    let setWhen: (String, String) -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                whenText
                changeMenu
            }
            VStack(alignment: .leading, spacing: 0) {
                whenText
                changeMenu
            }
        }
    }

    private var whenText: some View {
        Text(when)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(SoftLook.ink2)
    }

    private var changeMenu: some View {
        Menu {
            Button("Now") { setWhen("Tuesday, 9:12 AM", "9:12 AM") }
            Button("An hour ago") { setWhen("Tuesday, 8:12 AM", "8:12 AM") }
        } label: {
            Text("Change")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(SoftLook.accent)
                .frame(minHeight: 44)
                .contentShape(.rect)
        }
        .accessibilityLabel("Change the time")
    }
}

private struct ChoiceRow: View {
    let level: Int
    let isOn: Bool
    let choose: () -> Void
    @ScaledMetric(relativeTo: .title3) private var mark = 28.0

    var body: some View {
        Button(action: choose) {
            HStack(spacing: 12) {
                SoftLevelMark(level: level)
                    .frame(width: mark, height: mark)
                Text(EnergyDay.words[level])
                    .font(.system(.title3, design: .rounded, weight: .medium))
                    .foregroundStyle(SoftLook.ink)
                Spacer(minLength: 8)
                if isOn {
                    // The tick, not the tint, is the sign that this is chosen.
                    Image(systemName: "checkmark")
                        .font(.system(.footnote, weight: .bold))
                        .foregroundStyle(SoftLook.onAccent)
                        .frame(width: mark, height: mark)
                        .background(SoftLook.accent, in: .circle)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
            .background(isOn ? SoftLook.tint : SoftLook.surface, in: .rect(cornerRadius: SoftLook.radius))
            .overlay {
                if isOn {
                    RoundedRectangle(cornerRadius: SoftLook.radius)
                        .strokeBorder(SoftLook.accent, lineWidth: 2)
                }
            }
            .contentShape(.rect(cornerRadius: SoftLook.radius))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(EnergyDay.words[level])
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

/// The answer, kept as a word. The comparison is the one thing the mark and
/// the word cannot show. There is no praise and no score.
private struct SavedAnswer: View {
    let entry: EnergyEntry
    let comparison: String?
    @ScaledMetric(relativeTo: .largeTitle) private var mark = 96.0
    /// The level pours into the ring once, as the answer arrives.
    @State private var hasArrived = false

    var body: some View {
        VStack(spacing: 0) {
            SoftLevelMark(level: entry.level, lineWidth: 6, poured: hasArrived ? 1 : 0)
                .frame(width: min(mark, 140), height: min(mark, 140))
                .scaleEffect(hasArrived ? 1 : 0.82)
                .onAppear {
                    withAnimation(.spring(duration: 0.9, bounce: 0.28).delay(0.2)) { hasArrived = true }
                }
            Text(EnergyDay.words[entry.level])
                .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                .foregroundStyle(SoftLook.ink)
                .padding(.top, 16)
            Text(comparison.map { "\(entry.time) · \($0)" } ?? entry.time)
                .font(.body)
                .foregroundStyle(SoftLook.ink2)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

private struct TodaySoFar: View {
    let entries: [EnergyEntry]
    @ScaledMetric(relativeTo: .body) private var mark = 22.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Today so far")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(SoftLook.ink2)
                .accessibilityAddTraits(.isHeader)
            ForEach(entries) { entry in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    SoftLevelMark(level: entry.level)
                        .frame(width: mark, height: mark)
                        .alignmentGuide(.firstTextBaseline) { $0[.bottom] - mark * 0.18 }
                    // The word and the time share a line when they fit. When
                    // they don't, the time goes under the word; neither is
                    // ever broken in the middle.
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            word(for: entry)
                            Spacer(minLength: 8)
                            time(for: entry)
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            word(for: entry)
                            time(for: entry)
                        }
                    }
                }
                .frame(minHeight: 36)
                .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func word(for entry: EnergyEntry) -> some View {
        Text(EnergyDay.words[entry.level])
            .foregroundStyle(SoftLook.ink)
            .lineLimit(1)
    }

    private func time(for entry: EnergyEntry) -> some View {
        Text(entry.time)
            .font(.subheadline)
            .fontWeight(.medium)
            .monospacedDigit()
            .foregroundStyle(SoftLook.ink2)
            .lineLimit(1)
    }
}

/// The buttons at the bottom edge. Its ground is the warm end of the fade,
/// coming in gradually so there is no line where the bar begins.
private struct BottomBar<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 4) { content }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .background {
                LinearGradient(
                    stops: [.init(color: SoftLook.ground2.opacity(0), location: 0), .init(color: SoftLook.ground2, location: 0.25)],
                    startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(edges: .bottom)
            }
            // A pinned bar stops growing before the content does. Past this
            // size "Save check-in" took two lines and a third of a small
            // phone, and one choice was left in view.
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }
}

private struct NoteSheet: View {
    @State var note: String
    let save: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                TextField("Anything worth remembering", text: $note, axis: .vertical)
                    .lineLimit(3...8)
                    .focused($isFocused)
            }
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        save(note.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                }
            }
            .onAppear { isFocused = true }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Sample data

extension EnergyDay {
    static let sample = EnergyDay(
        when: "Tuesday, 9:12 AM", time: "9:12 AM",
        earlier: [EnergyEntry(id: 1, level: 1, time: "7:40 AM")],
        usualLevel: 2, usualLabel: "a Tuesday morning")

    /// The sample just after "Steady" was saved.
    static let checkedIn: EnergyDay = {
        var day = sample
        day.saved = EnergyEntry(id: 2, level: 2, time: "9:12 AM")
        return day
    }()

    /// Before any history: nothing earlier today, and no usual to compare with.
    static let first = EnergyDay(when: "Tuesday, 9:12 AM", time: "9:12 AM", earlier: [])

    static let placeholder = EnergyDay(
        when: "Weekday, 0:00 AM", time: "0:00 AM",
        earlier: [EnergyEntry(id: 1, level: 0, time: "0:00 AM")])
}
