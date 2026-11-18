import SwiftUI

// The parts of look 04 in use, for the invented product of the look's
// accepted entry: an energy diary for someone pacing a recovery. Each screen
// is built only from the look's parts, one answer leads it, and nothing on it
// names a part or a state. `parts.md` says which part is which and where it
// is in code.

struct SoftPartsScreen: View {
    /// The screen to open: `today` (the default), `today-waiting`,
    /// `today-failed`, `empty`, `loading`, `offline`, `checkin`, `moment`,
    /// `moment-waiting`, `moment-failed`, `circle`, `invite`, `invite-error`,
    /// `invite-busy`.
    var screen: String?

    var body: some View {
        NavigationStack {
            switch screen {
            case "moment": SoftMoment(checkin: .walk, form: .loaded(.sample(SoftCheckin.walkPicture)))
            case "moment-waiting": SoftMoment(checkin: .walk, form: .waiting)
            case "moment-failed": SoftMoment(checkin: .walk, form: .failed)
            case "circle", "invite", "invite-error", "invite-busy": SoftCircle(opens: screen)
            default: SoftToday(opens: screen)
            }
        }
        // The hue is "yours", and so is what you can press.
        .tint(SoftLook.accent)
        .fontDesign(.rounded)
    }
}

// MARK: Sample content

private struct SoftCheckin: Identifiable {
    let id: Int
    /// 0 to 4, as in the entry. Neither end is better.
    let level: Int
    let time: String
    var note: String?
    var picture: String?

    var word: String { EnergyDay.words[level] }

    static let walkPicture = "bicycle-by-a-bridge"
    static let walk = SoftCheckin(
        id: 2, level: 1, time: "7:40 AM",
        note: "Walked to the bridge and back before breakfast. Slow, and I sat down halfway.",
        picture: walkPicture)
    static let sample = [
        SoftCheckin(id: 1, level: 0, time: "6:15 AM"),
        walk,
        SoftCheckin(id: 3, level: 1, time: "8:20 AM", note: "Two phone calls in a row. Lay down after the second."),
        SoftCheckin(id: 4, level: 2, time: "9:12 AM"),
    ]

    /// Compared with the person's own usual, in plain words, as the entry
    /// does. Never with a target and never with other people.
    var comparison: String {
        let usual = 2
        if level == usual { return "about your usual for a Tuesday morning" }
        return level < usual ? "lower than your usual for a Tuesday morning" : "higher than your usual for a Tuesday morning"
    }
}

// MARK: Today

/// The latest answer leads, as the large mark and its word. Every earlier
/// answer is one row that starts with the same mark, small.
private struct SoftToday: View {
    private enum Phase { case loaded, loading, offline }

    @State private var checkins: [SoftCheckin]
    @State private var phase: Phase
    @State private var isCheckingIn: Bool
    @State private var isTrying = false
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _checkins = State(initialValue: screen == "empty" ? [] : SoftCheckin.sample)
        _phase = State(initialValue: screen == "loading" ? .loading : screen == "offline" ? .offline : .loaded)
        _isCheckingIn = State(initialValue: screen == "checkin")
    }

    private var hasAnswer: Bool { phase != .loading && !checkins.isEmpty }

    var body: some View {
        Group {
            if checkins.isEmpty { empty } else { list }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // The soft light is there while an answer leads, as in the entry.
        .background {
            SoftGround(glow: hasAnswer ? 1 : 0)
                .ignoresSafeArea()
                .animation(.smooth(duration: 1.4), value: hasAnswer)
        }
        .navigationTitle("Today")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SoftCircle(opens: nil)
                } label: {
                    Label("Circle", systemImage: "person.2")
                }
            }
        }
        .sheet(isPresented: $isCheckingIn) {
            SoftCheckinSheet { level in
                let nextID = (checkins.map(\.id).max() ?? 0) + 1
                withAnimation(.smooth(duration: 0.45)) {
                    checkins.append(SoftCheckin(id: nextID, level: level, time: "9:41 AM"))
                }
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 0) {
                if phase == .offline {
                    SoftNotice(
                        title: isTrying ? "Trying…" : "Not saved to your account",
                        message: "Today’s answers are kept on this iPhone.") {
                        Task { await retry() }
                    }
                    .padding(.bottom, SoftLook.groupGap)
                }
                if phase == .loading {
                    SoftGhostLead()
                    SoftGroup {
                        ForEach(0..<3, id: \.self) { _ in SoftGhostRow() }
                    }
                    .padding(.top, 32)
                } else if let lead = checkins.last {
                    SoftLead(level: lead.level, word: lead.word, detail: "\(lead.time) · \(lead.comparison)")
                    if checkins.count > 1 {
                        SoftGroup {
                            ForEach(checkins.dropLast()) { checkin in
                                row(checkin)
                            }
                        }
                        .padding(.top, 32)
                    }
                }
            }
            .padding(.horizontal, SoftLook.margin)
            .padding(.top, phase == .offline ? 8 : 24)
            .padding(.bottom, 24)
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if phase != .loading {
                checkInButton
                    .padding(.horizontal, SoftLook.margin)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    .background {
                        // The warm end of the fade, coming in with no line.
                        LinearGradient(
                            stops: [.init(color: SoftLook.ground2.opacity(0), location: 0), .init(color: SoftLook.ground2, location: 0.25)],
                            startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea(edges: .bottom)
                    }
            }
        }
    }

    private var empty: some View {
        VStack(spacing: 0) {
            SoftEmptyDrawing()
            Text("No check-in yet today")
                .font(SoftLook.emptyTitle)
                .foregroundStyle(SoftLook.ink)
                .padding(.top, 8)
            checkInButton
                .frame(maxWidth: 260)
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 80)
    }

    private var checkInButton: some View {
        Button("Check in") { isCheckingIn = true }
            .buttonStyle(SoftMainButtonStyle())
    }

    /// An answer with a note opens it, and says so by what its row ends
    /// with: the picture kept with the note, or a note's glyph.
    @ViewBuilder private func row(_ checkin: SoftCheckin) -> some View {
        if checkin.note != nil {
            NavigationLink {
                SoftMoment(checkin: checkin, form: checkin.picture.map(form))
            } label: {
                SoftRow(name: checkin.word, detail: checkin.time) {
                    SoftRowMark(level: checkin.level)
                } end: {
                    SoftPicture(form: checkin.picture.map(form))
                }
            }
            .buttonStyle(SoftPressStyle())
        } else {
            SoftRow(name: checkin.word, detail: checkin.time) {
                SoftRowMark(level: checkin.level)
            } end: {}
        }
    }

    private func form(_ picture: String) -> PictureForm {
        switch opens {
        case "today-waiting": .waiting
        case "today-failed": .failed
        default: .loaded(.sample(picture))
        }
    }

    private func retry() async {
        isTrying = true
        try? await Task.sleep(for: .seconds(2.5))
        isTrying = false
    }
}

/// The entry's question, as a sheet: five choices of equal standing, and a
/// main button that is a surface until one is chosen.
private struct SoftCheckinSheet: View {
    let save: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var picked: Int?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach((0..<EnergyDay.words.count).reversed(), id: \.self) { level in
                        SoftChoiceRow(name: EnergyDay.words[level], isOn: level == picked) {
                            picked = level
                        } lead: {
                            SoftLevelMark(level: level)
                                .frame(width: 28, height: 28)
                        }
                    }
                }
                .padding(.horizontal, SoftLook.margin)
                .padding(.top, 8)
            }
            .safeAreaInset(edge: .bottom) {
                Button("Save check-in") {
                    guard let picked else { return }
                    save(picked)
                    dismiss()
                }
                .buttonStyle(SoftMainButtonStyle())
                .disabled(picked == nil)
                .padding(.horizontal, SoftLook.margin)
                .padding(.bottom, 8)
            }
            .navigationTitle("How’s your energy?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
        }
        .tint(SoftLook.accent)
        .fontDesign(.rounded)
        .presentationBackground { SoftLook.backdrop }
    }
}

// MARK: One answer, with its note and its picture

private struct SoftMoment: View {
    let checkin: SoftCheckin
    /// `nil` when no picture was kept with the note.
    let form: PictureForm?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SoftLead(level: checkin.level, word: checkin.word, detail: checkin.time)
                if let note = checkin.note {
                    Text(note)
                        .font(SoftLook.row)
                        .foregroundStyle(SoftLook.ink)
                        .padding(.horizontal, SoftLook.inset)
                        .padding(.top, 32)
                }
                if let form {
                    SoftPicture(form: form, shape: 4.0 / 3)
                        .padding(.top, SoftLook.groupGap)
                }
            }
            .padding(.horizontal, SoftLook.margin)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            SoftGround(glow: 1).ignoresSafeArea()
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: Circle: people, another company's logo, the app's own mark

private struct SoftPerson: Identifiable {
    var id: String { name }
    let name: String
    var face: SampleFace.Person?
    var sees: String
    var isInvited = false

    static let sample = [
        SoftPerson(name: "Mina", face: .mina, sees: "The whole week"),
        SoftPerson(name: "Jonas", sees: "Today only"),
    ]
}

/// The people who may read the diary. Nobody here has a hue: it is the
/// diary owner's alone.
private struct SoftCircle: View {
    private enum Link { case none, linking, linked }

    @State private var people = SoftPerson.sample
    @State private var link = Link.none
    @State private var isInviting: Bool
    private let opens: String?

    init(opens screen: String?) {
        opens = screen
        _isInviting = State(initialValue: screen?.hasPrefix("invite") == true)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SoftGroup {
                    ForEach(people) { person in
                        SoftRow(name: person.name, detail: person.isInvited ? "Invited" : nil) {
                            if let face = person.face {
                                SoftPersonMark(photo: SampleFace(person: face))
                            } else {
                                SoftPersonMark(initial: String(person.name.prefix(1)).uppercased())
                            }
                        } end: {
                            Text(person.sees)
                                .font(SoftLook.detail)
                                .foregroundStyle(SoftLook.ink2)
                        }
                    }
                    Button {
                        isInviting = true
                    } label: {
                        SoftRow(name: "Invite someone") {
                            SoftPersonMark(initial: nil)
                        } end: {}
                    }
                    .buttonStyle(SoftPressStyle())
                }

                SoftGroup {
                    SoftGroupHead(title: "Apps that read your check-ins")
                    SoftRow(name: "Northline") {
                        SoftLogoTile { SampleLogo(company: .northline) }
                    } end: {
                        linked
                    }
                    SoftRow(name: "Tempo") {
                        SoftLogoTile { SampleLogo(company: .tempo) }
                    } end: {
                        if link == .linked {
                            linked
                        } else {
                            Button(link == .linking ? "Linking…" : "Link") { Task { await connect() } }
                                .buttonStyle(SoftTextButtonStyle())
                                .allowsHitTesting(link == .none)
                        }
                    }
                }
                .padding(.top, SoftLook.groupGap)

                // The app's own mark belongs here and on the first run, not in a bar.
                HStack(spacing: 12) {
                    SoftAppMark()
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Pace")
                            .font(SoftLook.rowStrong)
                            .foregroundStyle(SoftLook.ink)
                        Text("Version 2.1")
                            .font(SoftLook.detail)
                            .foregroundStyle(SoftLook.ink2)
                    }
                }
                .padding(.horizontal, SoftLook.inset)
                .padding(.top, SoftLook.groupGap)
            }
            .padding(.horizontal, SoftLook.margin)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SoftLook.backdrop.ignoresSafeArea())
        .scrollEdgeEffectStyle(.hard, for: .top)
        .navigationTitle("Circle")
        .toolbarTitleDisplayMode(.inlineLarge)
        .sheet(isPresented: $isInviting) {
            SoftInviteSheet(opens: opens) { email, sees in
                withAnimation(.smooth(duration: 0.45)) {
                    people.append(SoftPerson(name: email, sees: sees, isInvited: true))
                }
            }
        }
    }

    private var linked: some View {
        Text("Linked")
            .font(SoftLook.detail)
            .foregroundStyle(SoftLook.ink2)
    }

    private func connect() async {
        link = .linking
        try? await Task.sleep(for: .seconds(2.5))
        link = .linked
    }
}

/// One field leads the sheet. The button's words say where the action stands.
private struct SoftInviteSheet: View {
    let send: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var email: String
    @State private var sees = SoftInviteSheet.reach[0]
    @State private var notesToo = false
    @State private var error: String?
    @State private var isSending: Bool
    private let staysBusy: Bool

    private static let reach = ["Today only", "The whole week"]
    private static let reason = "An email address needs an @, like ana@example.com"

    init(opens screen: String?, send: @escaping (String, String) -> Void) {
        self.send = send
        staysBusy = screen == "invite-busy"
        _email = State(initialValue: screen == "invite-error" ? "ana.example.com" : screen == "invite-busy" ? "ana@example.com" : "")
        _error = State(initialValue: screen == "invite-error" ? Self.reason : nil)
        _isSending = State(initialValue: screen == "invite-busy")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SoftField(name: "Their email", text: $email, error: error)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SoftGroupHead(title: "They can see")
                        .padding(.horizontal, SoftLook.inset)
                        .padding(.top, SoftLook.groupGap)
                    VStack(spacing: 8) {
                        ForEach(Self.reach, id: \.self) { option in
                            SoftChoiceRow(name: option, isOn: option == sees) { sees = option }
                        }
                    }
                    Toggle("Notes too", isOn: $notesToo)
                        .font(SoftLook.row)
                        .foregroundStyle(SoftLook.ink)
                        .tint(SoftLook.accent)
                        .padding(.horizontal, SoftLook.inset)
                        .frame(minHeight: SoftLook.rowMin)
                        .padding(.top, 12)
                }
                .padding(.horizontal, SoftLook.margin)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button(isSending ? "Sending…" : "Send invite", action: submit)
                    .buttonStyle(SoftMainButtonStyle(isBusy: isSending))
                    .disabled(email.isEmpty)
                    .allowsHitTesting(!isSending)
                    .padding(.horizontal, SoftLook.margin)
                    .padding(.bottom, 8)
            }
            .navigationTitle("Invite someone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onChange(of: email) { error = nil }
        }
        .tint(SoftLook.accent)
        .fontDesign(.rounded)
        .presentationBackground { SoftLook.backdrop }
    }

    private func submit() {
        guard !isSending else { return }
        let address = email.trimmingCharacters(in: .whitespaces)
        let parts = address.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty, parts[1].contains(".") else {
            error = Self.reason
            return
        }
        isSending = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !staysBusy else { return }
            send(address, sees)
            dismiss()
        }
    }
}

#Preview {
    SoftPartsScreen()
}
