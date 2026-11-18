import SwiftUI

// Pattern: one action, asked and answered
// Direction 03 Data Precision · kind: flow · look: DataLook.swift
// Sample product (invented): repeat prescriptions. The list leads with the
// one medicine that needs something and keeps the rest to a line each. A
// sheet holds that medicine's facts and the one action, asking the pharmacy
// for a refill.
//
// The sample's clock is Tuesday, November 17, 2026, at 9:41 AM. Every date on
// the screen is worked out from that day by hand and written in.

/// Where one request stands. The list and the sheet both draw from this one
/// value, so they cannot disagree about it.
enum RefillStep: Equatable {
    case ready
    case asking
    /// The answer is yes.
    case requested(ready: String)
    /// The service answered, and the answer is no. `onRow` is the same
    /// reason in the words the list has room for.
    case refused(reason: String, onRow: String)
    /// Nothing was asked: the request never reached the service.
    case unsent(cause: String)
}

/// What the sample's service says to the next request.
enum RefillAnswer {
    case yes, no, unreachable
}

struct Medicine: Identifiable, Equatable {
    var id: String { name }
    /// The name as the list gives it, with its form.
    var name: String
    /// The form alone, for the head of the sheet.
    var form: String
    /// The name without the form, for the title of the sheet.
    var title: String
    var daysLeft: Int
    var runsOut: String
    var lastCollected: String
    var refillsLeft: Int
    var refillsOf: Int
    var pharmacy: String
    /// How long the pharmacy takes, as it would say before being asked.
    var readyIn: String
    var step = RefillStep.ready

    var isRequested: Bool {
        if case .requested = step { true } else { false }
    }

    /// Whether the list offers to ask: not after a yes, and not after a no.
    var offersRequest: Bool {
        switch step {
        case .ready, .asking, .unsent: isLow
        case .requested, .refused: false
        }
    }

    /// A week of supply or less, and no refill on its way.
    var isLow: Bool { daysLeft <= 7 && !isRequested }

    /// It leads the list: it needs something, or something is on its way.
    var leads: Bool { isLow || isRequested }

    /// The one line the list gives a medicine that leads.
    var leadWords: String {
        if case .requested(let ready) = step { return "Refill ready \(ready)" }
        return daysLeft <= 0 ? "Runs out today" : daysLeft == 1 ? "Runs out tomorrow" : "Runs out in \(daysLeft) days"
    }

    /// The state of the supply. A refusal or a failure to send is not one:
    /// the medicine is as low as it was.
    var supplyState: DataState? {
        isRequested ? .ok : isLow ? .warn : nil
    }

    var supplyNote: String {
        if case .requested(let ready) = step { return "refill ready \(ready)" }
        return isLow ? "runs out \(runsOut)" : "until \(runsOut)"
    }
}

/// The line the list keeps under a row: a request on its way, or an answer
/// that left the medicine as it was.
enum RowNote: Equatable {
    case asking
    case said(String, symbol: String)
}

struct MedicineList: Equatable {
    /// When the list is from: "9:41 AM", "just now".
    var updatedAt: String
    var medicines: [Medicine]
    /// False for a saved copy, which makes no claim about now.
    var isCurrent = true
}

/// Which medicine the sheet is for.
private struct OpenSheet: Identifiable {
    let id: Medicine.ID
}

struct RefillRequestScreen: View {
    @State private var phase: Phase<MedicineList>
    @State private var open: OpenSheet?
    @State private var answers: [RefillAnswer]
    @State private var yesCount = 0
    @State private var noCount = 0
    @State private var unsentCount = 0
    private let delay: Duration

    /// `open` starts with the sheet for that medicine showing. `answers` is
    /// what the sample's service says to each request in turn; when it runs
    /// out the answer is yes.
    init(phase: Phase<MedicineList>, open: Medicine.ID? = nil, answers: [RefillAnswer] = [],
         delay: Duration = .seconds(1.2)) {
        _phase = State(initialValue: phase)
        _open = State(initialValue: open.map(OpenSheet.init))
        _answers = State(initialValue: answers)
        self.delay = delay
    }

    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DataLook.ground)
                .navigationTitle("Medicines")
                .navigationBarTitleDisplayMode(.inline)
        }
        // Controls are ink. Colour on these screens always means a state.
        .tint(DataLook.ink)
        // The sheet is handed the medicine it is for. Presenting with a flag
        // and looking the medicine up from a second piece of state opened an
        // empty sheet: the content was built before that state had changed.
        .sheet(item: $open) { open in
            // Looked up each time, so the sheet shows the request as it is now.
            if let medicine = list?.medicines.first(where: { $0.id == open.id }) {
                RefillSheet(medicine: medicine) {
                    request(medicine.id)
                } close: {
                    self.open = nil
                }
            }
        }
        .sensoryFeedback(.success, trigger: yesCount)
        .sensoryFeedback(.warning, trigger: noCount)
        .sensoryFeedback(.error, trigger: unsentCount)
    }

    @ViewBuilder private var content: some View {
        switch phase {
        case .loading:
            page(.placeholder, notice: nil)
                .redacted(reason: .placeholder)
                .disabled(true)
        case .empty:
            ScrollsIfNeeded {
                ContentUnavailableView {
                    Label("No repeat medicines", systemImage: "pills")
                } description: {
                    // Where a medicine comes from is not something this
                    // screen can show any other way.
                    Text("A medicine appears here once your practice puts it on repeat.")
                        .foregroundStyle(DataLook.ink2)
                } actions: {
                    Button("Check again") { phase = .loaded(.sample) }
                        .buttonStyle(DataInkButtonStyle())
                }
            }
        case .loaded(let list):
            page(list, notice: nil)
        case .failed(let message, let stale?):
            page(stale, notice: message)
        case .failed(let message, nil):
            ScrollsIfNeeded {
                ContentUnavailableView {
                    Label("Couldn't load your medicines", systemImage: "wifi.slash")
                } description: {
                    Text(message)
                        .foregroundStyle(DataLook.ink2)
                } actions: {
                    Button("Try again", action: retry)
                        .buttonStyle(DataInkButtonStyle())
                }
            }
        }
    }

    private func page(_ list: MedicineList, notice: String?) -> some View {
        let rows = rows(of: list)
        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let notice {
                    DataNotice(title: notice, retry: retry)
                    // How old the list is cannot be seen any other way.
                    Text("List saved at \(list.updatedAt)")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(DataLook.ink2)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                }
                // One run of rows, each with its own identity, so a medicine
                // that starts to lead is the same row in a new place and not
                // one row fading out over another fading in.
                ForEach(rows) { row in
                    if row.medicine.leads {
                        LeadRow(medicine: row.medicine, note: row.note, isCurrent: list.isCurrent) {
                            open = OpenSheet(id: row.medicine.id)
                        }
                    } else {
                        if let head = row.head {
                            DataGroupHead(title: head)
                        }
                        Button {
                            open = OpenSheet(id: row.medicine.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 0) {
                                // One quiet figure. The date it stands for is in the sheet.
                                DataRow(name: row.medicine.name, figure: "\(row.medicine.daysLeft) days",
                                        nameWraps: true, isQuiet: true)
                                if let note = row.note {
                                    RowNoteLine(note: note)
                                        .padding(.bottom, 10)
                                        .transition(.afterTheGlide)
                                }
                            }
                            .contentShape(.rect)
                        }
                        .buttonStyle(DataRowPressStyle())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 24)
            // A line or a button that comes or goes does it with a glide, so
            // the rows below are never in another place from one frame to the
            // next. Words that change in place change at once.
            .animation(.easeInOut(duration: 0.25), value: rows.map(\.shape))
        }
        .scrollEdgeEffectStyle(.hard, for: .top)
        .refreshable { await refresh() }
    }

    private struct ListRow: Identifiable {
        let medicine: Medicine
        /// Set on the first row in supply.
        var head: String?
        var note: RowNote?
        var id: Medicine.ID { medicine.id }

        /// What decides the row's height: whether it leads, has a button, has a note.
        var shape: [Bool] { [medicine.leads, medicine.offersRequest, note != nil] }
    }

    /// The ones that lead come first, soonest to run out at the top. The rest
    /// follow under one head.
    private func rows(of list: MedicineList) -> [ListRow] {
        let leading = list.medicines.filter(\.leads).sorted { $0.daysLeft < $1.daysLeft }
        let supplied = list.medicines.filter { !$0.leads }.sorted { $0.daysLeft < $1.daysLeft }
        return leading.map { ListRow(medicine: $0, note: note(for: $0)) }
            + supplied.enumerated().map { index, medicine in
                ListRow(medicine: medicine, head: index == 0 ? "In supply" : nil, note: note(for: medicine))
            }
    }

    private func note(for medicine: Medicine) -> RowNote? {
        switch medicine.step {
        // A medicine that leads says so on its button. For the others the
        // sheet's button says so while the sheet is up.
        case .asking: medicine.leads || open?.id == medicine.id ? nil : .asking
        case .refused(_, let onRow): .said(onRow, symbol: "nosign")
        case .unsent: .said("Refill not sent", symbol: "wifi.slash")
        default: nil
        }
    }

    private var list: MedicineList? {
        switch phase {
        case .loaded(let list), .failed(_, let list?): list
        default: nil
        }
    }

    /// Changes one medicine in place, whichever phase holds the list.
    private func change(_ id: Medicine.ID, _ edit: (inout Medicine) -> Void) {
        guard var list, let index = list.medicines.firstIndex(where: { $0.id == id }) else { return }
        edit(&list.medicines[index])
        switch phase {
        case .failed(let message, _): phase = .failed(message: message, stale: list)
        default: phase = .loaded(list)
        }
    }

    /// Sample only. A real app sends the request and reads the reply; here
    /// the reply is the next one the screen was given, after a short wait.
    private func request(_ id: Medicine.ID) {
        let answer: RefillAnswer
        if case .failed = phase {
            // The list itself could not be fetched, so nothing can be sent.
            answer = .unreachable
        } else {
            answer = answers.isEmpty ? .yes : answers.removeFirst()
        }
        change(id) { $0.step = .asking }
        Task {
            try? await Task.sleep(for: delay)
            switch answer {
            case .yes:
                change(id) {
                    $0.step = .requested(ready: "Thu, Nov 19")
                    $0.refillsLeft -= 1
                }
                yesCount += 1
            case .no:
                change(id) {
                    $0.step = .refused(reason: "A review with Dr Okafor is due first",
                                       onRow: "A review is due before a refill")
                }
                noCount += 1
            case .unreachable:
                change(id) { $0.step = .unsent(cause: "Can't reach the pharmacy") }
                unsentCount += 1
            }
        }
    }

    /// Sample only: pulling the list down fetches it again. A saved copy is
    /// replaced by the current list.
    private func refresh() async {
        try? await Task.sleep(for: .seconds(0.8))
        if case .failed = phase { retry() }
    }

    /// Sample only: a real app would fetch the list again here.
    private func retry() {
        phase = .loaded(.sample)
    }
}

extension AnyTransition {
    /// For a line that arrives while the rows below make room for it: it
    /// shows once they have moved, and it leaves at once. Nothing is ever
    /// drawn over anything else.
    static var afterTheGlide: AnyTransition {
        .asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.12).delay(0.25)), removal: .identity)
    }
}

/// In ink, not in a state colour: it is about the request, not the medicine.
private struct RowNoteLine: View {
    let note: RowNote

    var body: some View {
        HStack(spacing: 6) {
            switch note {
            case .asking:
                ProgressView().controlSize(.mini)
                Text("Sending the request…")
            case .said(let words, let symbol):
                Image(systemName: symbol)
                Text(words)
            }
        }
        .font(.footnote)
        .fontWeight(.medium)
        .foregroundStyle(DataLook.ink)
    }
}

/// The one medicine the screen is about: its name, its state in words, and
/// the way to act on it. Everything else on the list is quieter than this.
private struct LeadRow: View {
    let medicine: Medicine
    let note: RowNote?
    /// False for a saved copy, which loses the state colour with the claim.
    let isCurrent: Bool
    let open: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: open) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(medicine.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DataLook.ink)
                        .multilineTextAlignment(.leading)
                    Label(medicine.leadWords, systemImage: isCurrent ? (medicine.supplyState?.symbol ?? "clock") : "clock")
                        // The look's figure style: the state is the figure, in words.
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(isCurrent ? (medicine.supplyState?.color ?? DataLook.ink2) : DataLook.ink2)
                        // The words change at once. Inside the list's glide
                        // they would fade, old over new.
                        .animation(nil, value: medicine.step)
                    if let note {
                        RowNoteLine(note: note)
                            .padding(.top, 2)
                            .transition(.afterTheGlide)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(DataRowPressStyle())

            if medicine.offersRequest {
                // It opens the sheet, where the facts are and the request is sent.
                Button(action: open) {
                    HStack(spacing: 8) {
                        if medicine.step == .asking {
                            ProgressView().tint(DataLook.ground)
                        }
                        Text(medicine.step == .asking ? "Sending…" : "Request a refill")
                    }
                }
                .buttonStyle(DataInkButtonStyle(isBusy: medicine.step == .asking))
                .padding(.top, 14)
                .animation(nil, value: medicine.step)
                // Gone at once, so the rows below never pass over it.
                .transition(.identity)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 12)
    }
}

/// One medicine and the one thing to do about it. The sheet is as tall as
/// its content and never changes height: an answer takes the place of a line
/// that was already there.
private struct RefillSheet: View {
    let medicine: Medicine
    let request: () -> Void
    let close: () -> Void
    /// Close to the real height, so the sheet does not jump as it arrives.
    @State private var height = 470.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(medicine.form).dataHead()
                Spacer()
                Button("Close", systemImage: "xmark", action: close)
                    .labelStyle(.iconOnly)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(DataLook.ink)
                    .frame(width: 44, height: 44, alignment: .trailing)
                    .contentShape(.rect)
            }
            Text(medicine.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(DataLook.ink)
                .padding(.bottom, 12)

            // The answer "yes" has no message. It is these two rows changing
            // where they stand.
            DataRow(name: "Supply left", figure: "\(medicine.daysLeft) days", comparison: medicine.supplyNote,
                    state: medicine.supplyState, nameWraps: true)
            DataRow(name: "Last collected", figure: medicine.lastCollected, nameWraps: true)
            DataRow(name: "Refills left", figure: "\(medicine.refillsLeft) of \(medicine.refillsOf)", nameWraps: true)
            DataRow(name: "Collect from", figure: medicine.pharmacy, nameWraps: true)
            Rectangle().fill(DataLook.rule).frame(height: 1)

            answer
                .font(.footnote)
                // Room for two lines, kept whether or not there is an answer.
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .leading)

            Button(action: act) {
                HStack(spacing: 8) {
                    if medicine.step == .asking {
                        ProgressView().tint(DataLook.ground)
                    }
                    Text(buttonWords)
                }
            }
            .buttonStyle(DataWideButtonStyle(isBusy: medicine.step == .asking))
            .disabled(medicine.step == .asking)
            // The words change at once. A fade would show two labels at a time.
            .animation(nil, value: medicine.step)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .fixedSize(horizontal: false, vertical: true)
        .onGeometryChange(for: Double.self) { $0.size.height } action: { height = $0 }
        .presentationDetents([.height(height)])
        .presentationDragIndicator(.hidden)
        // The look's one ground. A sheet is not a second surface colour.
        .presentationBackground(DataLook.ground)
        .tint(DataLook.ink)
    }

    /// The line above the button. Before the answer it carries the one fact
    /// the rows do not: how long a refill takes.
    @ViewBuilder private var answer: some View {
        switch medicine.step {
        case .ready, .asking:
            Text("Ready to collect in \(medicine.readyIn)")
                .fontWeight(.medium)
                .foregroundStyle(DataLook.ink2)
        case .requested:
            // Nothing to say, and the room is kept: an empty view here would
            // take the line away and the sheet would shrink.
            Color.clear
        case .refused(let reason, _):
            Label(reason, systemImage: "nosign")
                .fontWeight(.semibold)
                .foregroundStyle(DataLook.ink)
        case .unsent(let cause):
            // Never the refusal's words: nothing was asked, and the same
            // button sends it again.
            Label("Not sent. \(cause)", systemImage: "wifi.slash")
                .fontWeight(.semibold)
                .foregroundStyle(DataLook.ink)
        }
    }

    private var buttonWords: String {
        switch medicine.step {
        case .ready, .unsent: "Send request"
        case .asking: "Sending…"
        case .requested, .refused: "Done"
        }
    }

    private func act() {
        switch medicine.step {
        case .ready, .unsent: request()
        case .requested, .refused: close()
        case .asking: break
        }
    }
}

extension Medicine {
    static let salbutamol = Medicine(
        name: "Salbutamol 100 micrograms inhaler", form: "Inhaler", title: "Salbutamol 100 micrograms",
        daysLeft: 3, runsOut: "Fri, Nov 20", lastCollected: "Wed, Oct 21", refillsLeft: 2, refillsOf: 5,
        pharmacy: "Harbour Road Pharmacy", readyIn: "about 2 days")

    static let metformin = Medicine(
        name: "Metformin 500 mg tablets", form: "Tablets", title: "Metformin 500 mg",
        daysLeft: 12, runsOut: "Sun, Nov 29", lastCollected: "Sun, Nov 1", refillsLeft: 4, refillsOf: 6,
        pharmacy: "Harbour Road Pharmacy", readyIn: "about 2 days")

    static let levothyroxine = Medicine(
        name: "Levothyroxine 50 micrograms tablets", form: "Tablets", title: "Levothyroxine 50 micrograms",
        daysLeft: 24, runsOut: "Fri, Dec 11", lastCollected: "Fri, Oct 16", refillsLeft: 3, refillsOf: 6,
        pharmacy: "Harbour Road Pharmacy", readyIn: "about 2 days")

    static let atorvastatin = Medicine(
        name: "Atorvastatin 20 mg tablets", form: "Tablets", title: "Atorvastatin 20 mg",
        daysLeft: 41, runsOut: "Mon, Dec 28", lastCollected: "Mon, Nov 2", refillsLeft: 5, refillsOf: 6,
        pharmacy: "Harbour Road Pharmacy", readyIn: "about 2 days")
}

extension MedicineList {
    /// One medicine is running low and nothing has been asked.
    static let sample = MedicineList(
        updatedAt: "9:41 AM", medicines: [.salbutamol, .metformin, .levothyroxine, .atorvastatin])

    /// The sample with the first medicine's request at the given step.
    static func sample(_ step: RefillStep) -> MedicineList {
        var list = sample
        list.medicines[0].step = step
        if case .requested = step { list.medicines[0].refillsLeft -= 1 }
        return list
    }

    static let requested = sample(.requested(ready: "Thu, Nov 19"))

    static let refused = sample(.refused(
        reason: "A review with Dr Okafor is due first", onRow: "A review is due before a refill"))

    static let unsent = sample(.unsent(cause: "Can't reach the pharmacy"))

    /// Nothing is low: the inhaler was collected yesterday.
    static let calm: MedicineList = {
        var list = sample
        list.medicines[0].daysLeft = 29
        list.medicines[0].runsOut = "Wed, Dec 16"
        list.medicines[0].lastCollected = "Mon, Nov 16"
        list.medicines[0].refillsLeft = 1
        return list
    }()

    /// The copy saved before the pharmacy became unreachable.
    static let saved: MedicineList = {
        var list = sample
        list.updatedAt = "8:12 AM"
        list.isCurrent = false
        return list
    }()

    /// Shapes for the loading state. It claims no state, so it has no colour.
    static let placeholder = MedicineList(
        updatedAt: "0:00 AM",
        medicines: (1...4).map {
            Medicine(name: "Medicine name \($0) and strength", form: "Form", title: "Medicine name",
                     daysLeft: 10 * $0, runsOut: "Day, Mon 00", lastCollected: "Day, Mon 00",
                     refillsLeft: 0, refillsOf: 0, pharmacy: "Pharmacy", readyIn: "a while")
        },
        isCurrent: false)
}
