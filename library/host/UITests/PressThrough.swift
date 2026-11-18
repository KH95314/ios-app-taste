import XCTest

// Presses through the main operations of each entry, one test an entry, so
// that a recording shows what a screenshot cannot: a crash, a jump, a control
// that does nothing.
//
// A step that cannot find its control is logged and skipped, so one missing
// label does not hide the steps after it. Every step prints a line that
// starts with "TOUR" and carries the clock time, which is how a recording is
// lined up with the steps.

final class PressThrough: XCTestCase {
    private var pattern = ""

    @MainActor private func open(_ pattern: String, state: String = "loaded", variant: String? = nil, settle: TimeInterval = 2.5) -> XCUIApplication {
        self.pattern = pattern
        let app = XCUIApplication()
        app.launchArguments = ["-pattern", pattern, "-state", state] + (variant.map { ["-variant", $0] } ?? [])
        app.launch()
        Thread.sleep(forTimeInterval: settle)
        return app
    }

    @MainActor private func log(_ app: XCUIApplication, _ step: String, _ result: String) {
        let running = app.state == .runningForeground ? "running" : "NOT-RUNNING(\(app.state.rawValue))"
        print("TOUR \(Date().timeIntervalSince1970) | \(pattern) | \(step) | \(result) | \(running)")
    }

    /// Runs one step, then waits so the recording can show what it did.
    @MainActor private func step(_ app: XCUIApplication, _ name: String, wait: TimeInterval = 1.4, _ action: () -> Bool) {
        log(app, name, "begin")
        let done = action()
        Thread.sleep(forTimeInterval: wait)
        log(app, name, done ? "done" : "MISSING")
    }

    private enum Match { case exact, prefix, contains }

    @MainActor private func button(_ app: XCUIApplication, _ label: String, _ match: Match = .exact, index: Int = 0) -> XCUIElement {
        let format = switch match {
        case .exact: "label == %@"
        case .prefix: "label BEGINSWITH %@"
        case .contains: "label CONTAINS %@"
        }
        return app.buttons.matching(NSPredicate(format: format, label)).element(boundBy: index)
    }

    @MainActor private func press(_ app: XCUIApplication, _ label: String, _ match: Match = .exact, index: Int = 0) -> Bool {
        let element = button(app, label, match, index: index)
        guard element.waitForExistence(timeout: 2), element.isHittable else { return false }
        element.tap()
        return true
    }

    @MainActor private func point(_ app: XCUIApplication, _ x: Double, _ y: Double) -> XCUICoordinate {
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: x, dy: y))
    }

    @MainActor private func drag(_ app: XCUIApplication, from: (Double, Double), to: (Double, Double), hold: TimeInterval = 0.15) -> Bool {
        point(app, from.0, from.1).press(forDuration: hold, thenDragTo: point(app, to.0, to.1), withVelocity: .slow, thenHoldForDuration: 0.2)
        return true
    }

    @MainActor private func finish(_ app: XCUIApplication) {
        log(app, "end", "done")
        XCTAssertEqual(app.state, .runningForeground, "\(pattern) is not running at the end of its tour")
    }

    // MARK: - The eleven

    @MainActor func testSectionedList() {
        let app = open("sectioned-list")
        step(app, "mark the first chore done") { press(app, "Mark as done") }
        step(app, "mark another done") { press(app, "Mark as done", index: 1) }
        step(app, "mark one not done") { press(app, "Mark as not done") }
        step(app, "open the add sheet") { press(app, "Add chore") }
        step(app, "type a title") {
            let field = app.textViews.firstMatch.exists ? app.textViews.firstMatch : app.textFields.firstMatch
            guard field.exists else { return false }
            field.tap()
            app.typeText("Buy stamps")
            return true
        }
        step(app, "add it", wait: 2) { press(app, "Add") }
        step(app, "scroll down") { app.swipeUp(); return true }
        step(app, "scroll up") { app.swipeDown(); return true }
        finish(app)
    }

    @MainActor func testExplainedMetric() {
        let app = open("explained-metric")
        step(app, "set a reminder") { press(app, "Remind me in 10 minutes") }
        step(app, "cancel the reminder") { press(app, "Cancel reminder") }
        step(app, "open today's history", wait: 2) { press(app, "Today", .prefix) }
        step(app, "go back", wait: 1.8) {
            let back = app.navigationBars.buttons.element(boundBy: 0)
            guard back.exists else { return false }
            back.tap()
            return true
        }
        step(app, "scroll down") { app.swipeUp(); return true }
        step(app, "scroll up") { app.swipeDown(); return true }
        finish(app)
    }

    @MainActor func testContextSheet() {
        let app = open("context-sheet", settle: 6)
        step(app, "open the report choices") { press(app, "Report a problem") }
        step(app, "report it not working", wait: 1.8) { press(app, "It isn't working") }
        step(app, "back to nearby points", wait: 1.8) { press(app, "Back to nearby points") }
        step(app, "choose another point", wait: 1.8) { press(app, "Playground refill point", .prefix) }
        step(app, "pull the sheet up", wait: 1.8) {
            let grabber = app.buttons["Sheet Grabber"]
            guard grabber.exists else { return false }
            grabber.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                .press(forDuration: 0.15, thenDragTo: point(app, 201, 150), withVelocity: .slow, thenHoldForDuration: 0.2)
            return true
        }
        step(app, "pull the sheet down", wait: 1.8) {
            let grabber = app.buttons["Sheet Grabber"]
            guard grabber.exists else { return false }
            grabber.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                .press(forDuration: 0.15, thenDragTo: point(app, 201, 700), withVelocity: .slow, thenHoldForDuration: 0.2)
            return true
        }
        step(app, "back to nearby points again", wait: 1.8) { press(app, "Back to nearby points") }
        finish(app)
    }

    @MainActor func testLongRead() {
        let app = open("long-read")
        step(app, "bookmark") { press(app, "Bookmark") }
        step(app, "open the text size menu") { press(app, "Text size") }
        step(app, "larger text") { press(app, "Larger text") }
        step(app, "scroll down") { app.swipeUp(velocity: .slow); return true }
        step(app, "scroll down again") { app.swipeUp(velocity: .slow); return true }
        step(app, "tap the page") { point(app, 388, 600).tap(); return true }
        step(app, "tap the page again") { point(app, 388, 600).tap(); return true }
        step(app, "press and hold a paragraph", wait: 1.6) { point(app, 150, 330).press(forDuration: 1.0); return true }
        step(app, "highlight it", wait: 1.6) { press(app, "Highlight") || press(app, "Remove highlight") }
        step(app, "scroll back up") { app.swipeDown(velocity: .fast); return true }
        finish(app)
    }

    /// The long read alone, one scroll and nothing else.
    @MainActor func testLongReadScrollOnly() {
        let app = open("long-read")
        step(app, "scroll down once", wait: 3) { app.swipeUp(velocity: .slow); return true }
        finish(app)
    }

    /// The long read, starting part-way through with the tools hidden.
    @MainActor func testLongReadMidway() {
        let app = open("long-read", variant: "reading")
        step(app, "scroll down once", wait: 3) { app.swipeUp(velocity: .slow); return true }
        step(app, "scroll back up", wait: 3) { app.swipeDown(velocity: .slow); return true }
        finish(app)
    }

    @MainActor func testDayBlocks() {
        let app = open("day-blocks")
        step(app, "tick the current block") { press(app, "Mark as done") }
        step(app, "untick the first block") { press(app, "Mark as not done") }
        step(app, "go to Monday", wait: 1.8) { press(app, "Monday 12") }
        step(app, "back to Saturday", wait: 1.8) { press(app, "Saturday 17") }
        step(app, "open the add sheet") { press(app, "Add a block") }
        step(app, "type a title") {
            let field = app.textViews.firstMatch.exists ? app.textViews.firstMatch : app.textFields.firstMatch
            guard field.exists else { return false }
            field.tap()
            app.typeText("Trim nails")
            return true
        }
        step(app, "add it", wait: 2) { press(app, "Add") }
        step(app, "scroll down") { app.swipeUp(velocity: .slow); return true }
        step(app, "scroll up") { app.swipeDown(); return true }
        finish(app)
    }

    @MainActor func testServiceStatus() {
        let app = open("service-status")
        step(app, "chart: 7 days") { press(app, "7 days") }
        step(app, "chart: 30 days") { press(app, "30 days") }
        step(app, "chart: 24 hours") { press(app, "24 hours") }
        step(app, "check now", wait: 2.5) { press(app, "Check now") }
        step(app, "scroll down") { app.swipeUp(velocity: .slow); return true }
        step(app, "scroll up") { app.swipeDown(); return true }
        finish(app)
    }

    @MainActor func testAudioTake() {
        let app = open("audio-take")
        step(app, "record", wait: 2.5) { press(app, "Record") }
        step(app, "mark") { press(app, "Mark") }
        step(app, "pause") { press(app, "Pause") }
        step(app, "resume") { press(app, "Resume") }
        step(app, "drag the gain ruler") { drag(app, from: (127, 723), to: (270, 723)) }
        step(app, "stop and save", wait: 2.5) { press(app, "Stop and save") }
        step(app, "play the take") { press(app, "Play", .prefix) }
        finish(app)
    }

    @MainActor func testPlainDraft() {
        let app = open("plain-draft", settle: 3)
        step(app, "type") { app.typeText(" And more."); return true }
        step(app, "heading") { press(app, "Heading") }
        step(app, "bold") { press(app, "Bold") }
        step(app, "type in bold") { app.typeText("loud"); return true }
        step(app, "list") { press(app, "List") }
        step(app, "undo") { press(app, "Undo") }
        step(app, "redo") { press(app, "Redo") }
        step(app, "hide the keyboard", wait: 1.8) { press(app, "Hide keyboard") }
        step(app, "tap the text to edit again", wait: 1.8) { point(app, 200, 300).tap(); return true }
        step(app, "done", wait: 1.8) { press(app, "Done") }
        finish(app)
    }

    @MainActor func testFlyerCanvas() {
        let app = open("flyer-canvas")
        step(app, "select the headline") { press(app, "PLANT SWAP") }
        step(app, "size up") { press(app, "Add") }
        step(app, "size down") { press(app, "Remove") }
        step(app, "resize by a corner") { drag(app, from: (282, 390), to: (306, 414)) }
        step(app, "move it") { drag(app, from: (170, 330), to: (200, 372)) }
        step(app, "undo") { press(app, "Undo") }
        step(app, "undo again") { press(app, "Undo") }
        step(app, "redo") { press(app, "Redo") }
        step(app, "open the colour menu") { press(app, "Colour") }
        step(app, "coral") { press(app, "Coral") }
        step(app, "add a shape") { press(app, "Shape") }
        step(app, "open the layers", wait: 1.8) { press(app, "Layers") }
        step(app, "close the layers", wait: 1.8) { press(app, "Done") }
        step(app, "open the paper menu") { press(app, "Paper") }
        step(app, "mint") { press(app, "Mint") }
        step(app, "tap the board to deselect") { point(app, 201, 170).tap(); return true }
        step(app, "add text", wait: 1.8) { press(app, "Text") }
        step(app, "leave the text sheet if there is one", wait: 1.6) { press(app, "Cancel") || press(app, "Done") }
        step(app, "export", wait: 3) { press(app, "Export") }
        step(app, "close the share sheet", wait: 2) {
            if press(app, "Close") { return true }
            point(app, 201, 300).press(forDuration: 0.1, thenDragTo: point(app, 201, 860))
            return true
        }
        finish(app)
    }

    @MainActor func testPictureWall() {
        let app = open("picture-wall")
        step(app, "reserve the lead print") { press(app, "Reserve", .prefix) }
        step(app, "cancel it") { press(app, "Cancel", .prefix) }
        step(app, "choose another print") { press(app, "Night Swim", .contains) }
        step(app, "swipe the row") { drag(app, from: (340, 720), to: (70, 720)) }
        step(app, "filter: colour") { press(app, "Colour") }
        step(app, "filter: black and white") { press(app, "Black and white") }
        step(app, "show all prints") { press(app, "Show all prints") }
        step(app, "scroll down") { app.swipeUp(velocity: .slow); return true }
        step(app, "scroll up") { app.swipeDown(); return true }
        finish(app)
    }

    @MainActor func testTideScene() {
        let app = open("tide-scene")
        step(app, "drag ahead to the evening", wait: 1.6) { drag(app, from: (24, 797), to: (190, 797)) }
        step(app, "drag on into the night", wait: 1.6) { drag(app, from: (190, 797), to: (330, 797)) }
        step(app, "tap a point on the ruler", wait: 1.6) { point(app, 110, 797).tap(); return true }
        step(app, "back to now", wait: 1.8) { press(app, "Back to now") }
        finish(app)
    }

    // MARK: - The flow entry

    @MainActor private func sees(_ app: XCUIApplication, _ words: String, within seconds: TimeInterval = 3) -> Bool {
        let match = NSPredicate(format: "label CONTAINS %@", words)
        return app.staticTexts.containing(match).firstMatch.waitForExistence(timeout: seconds)
            || app.buttons.containing(match).firstMatch.exists
    }

    /// The answer is yes. The lead and the sheet change where they stand.
    @MainActor func testRefillRequest() {
        let app = open("refill-request")
        XCTAssertTrue(sees(app, "Runs out in 3 days"))
        step(app, "press the one button on the list", wait: 1.8) { press(app, "Request a refill") }
        XCTAssertTrue(sees(app, "Ready to collect in about 2 days"))
        step(app, "send the request", wait: 3) { press(app, "Send request") }
        XCTAssertTrue(sees(app, "1 of 5"), "the count of refills did not drop")
        XCTAssertFalse(button(app, "Send request").exists, "the sheet still offers to send")
        step(app, "close with Done", wait: 1.8) { press(app, "Done") }
        XCTAssertTrue(sees(app, "Refill ready Thu, Nov 19"))
        XCTAssertFalse(button(app, "Request a refill").exists, "the list still offers to ask")
        step(app, "open a medicine in supply", wait: 1.8) { press(app, "Metformin", .prefix) }
        XCTAssertTrue(sees(app, "4 of 6"))
        step(app, "close it with the mark", wait: 1.8) { press(app, "Close") }
        step(app, "pull the list down", wait: 2.5) { app.swipeDown(); return true }
        finish(app)
    }

    /// The answer is no. The reason is given, and it stays on the list.
    @MainActor func testRefillRequestRefused() {
        let app = open("refill-request", variant: "says-no")
        step(app, "press the one button on the list", wait: 1.8) { press(app, "Request a refill") }
        step(app, "send the request", wait: 3) { press(app, "Send request") }
        XCTAssertTrue(sees(app, "A review with Dr Okafor is due first"))
        XCTAssertTrue(sees(app, "2 of 5"), "a refusal used up a refill")
        step(app, "close with Done", wait: 1.8) { press(app, "Done") }
        XCTAssertTrue(sees(app, "A review is due before a refill"))
        XCTAssertTrue(sees(app, "Runs out in 3 days"))
        XCTAssertFalse(button(app, "Request a refill").exists, "the list offers to ask again after a no")
        step(app, "open it again by its name", wait: 1.8) { press(app, "Salbutamol", .prefix) }
        XCTAssertTrue(sees(app, "A review with Dr Okafor is due first"))
        step(app, "close it", wait: 1.8) { press(app, "Done") }
        finish(app)
    }

    /// Could not be sent, then sent. The same button sends it again.
    @MainActor func testRefillRequestUnsent() {
        let app = open("refill-request", variant: "offline")
        step(app, "press the one button on the list", wait: 1.8) { press(app, "Request a refill") }
        step(app, "send the request", wait: 3) { press(app, "Send request") }
        XCTAssertTrue(sees(app, "Not sent. Can't reach the pharmacy"))
        step(app, "send it again", wait: 3) { press(app, "Send request") }
        XCTAssertTrue(sees(app, "1 of 5"))
        step(app, "close with Done", wait: 1.8) { press(app, "Done") }
        XCTAssertTrue(sees(app, "Refill ready Thu, Nov 19"))
        finish(app)
    }

    /// A saved copy: nothing can be sent, the list says so afterwards, and trying again brings the list back.
    @MainActor func testRefillRequestSavedCopy() {
        let app = open("refill-request", state: "error")
        XCTAssertTrue(sees(app, "List saved at 8:12 AM"))
        step(app, "press the one button on the list", wait: 1.8) { press(app, "Request a refill") }
        step(app, "send the request", wait: 3) { press(app, "Send request") }
        XCTAssertTrue(sees(app, "Not sent. Can't reach the pharmacy"))
        step(app, "close it with the mark", wait: 1.8) { press(app, "Close") }
        XCTAssertTrue(sees(app, "Refill not sent"))
        step(app, "try the list again", wait: 1.8) { press(app, "Try again") }
        XCTAssertFalse(button(app, "Try again").exists, "the notice is still there")
        XCTAssertTrue(sees(app, "Runs out in 3 days"))
        finish(app)
    }

    /// The sheet is closed while the request is on its way. The button on
    /// the list says so, and then the list shows the answer.
    @MainActor func testRefillRequestClosedWhileAsking() {
        let app = open("refill-request", variant: "slow")
        step(app, "press the one button on the list", wait: 1.8) { press(app, "Request a refill") }
        step(app, "send the request", wait: 0.2) { press(app, "Send request") }
        step(app, "close before the answer", wait: 0.8) { press(app, "Close") }
        XCTAssertTrue(sees(app, "Sending"), "the list does not say a request is on its way")
        XCTAssertTrue(sees(app, "Refill ready Thu, Nov 19", within: 10))
        step(app, "let it settle", wait: 1.5) { true }
        finish(app)
    }

    /// Closed while asking, and the request does not get through. The list
    /// says so and offers to ask again.
    @MainActor func testRefillRequestClosedThenNotSent() {
        let app = open("refill-request", variant: "slow-offline")
        step(app, "press the one button on the list", wait: 1.8) { press(app, "Request a refill") }
        step(app, "send the request", wait: 0.2) { press(app, "Send request") }
        step(app, "close before the answer", wait: 0.8) { press(app, "Close") }
        XCTAssertTrue(sees(app, "Sending"))
        XCTAssertTrue(sees(app, "Refill not sent", within: 10))
        step(app, "ask again from the list", wait: 1.8) { press(app, "Request a refill") }
        XCTAssertTrue(sees(app, "Not sent. Can't reach the pharmacy"))
        step(app, "close it", wait: 1.5) { press(app, "Close") }
        finish(app)
    }

    // MARK: - The parts of three looks, in use

    @MainActor private func tap(_ app: XCUIApplication, id: String, index: Int = 0) -> Bool {
        let element = app.buttons.matching(identifier: id).element(boundBy: index)
        guard element.waitForExistence(timeout: 2), element.isHittable else { return false }
        element.tap()
        return true
    }

    /// Types at the end of what a field holds. A field whose text is set at
    /// the right needs its tap at the right, or the cursor lands before the text.
    @MainActor private func type(_ app: XCUIApplication, _ words: String, field index: Int = 0, atRight: Bool = false) -> Bool {
        let field = app.textFields.element(boundBy: index)
        guard field.waitForExistence(timeout: 2) else { return false }
        if atRight {
            field.coordinate(withNormalizedOffset: CGVector(dx: 0.97, dy: 0.5)).tap()
        } else {
            field.tap()
        }
        field.typeText(words)
        return true
    }

    /// Words anywhere on the screen: in a text, a button or a row that is a link.
    @MainActor private func shows(_ app: XCUIApplication, _ words: String, within seconds: TimeInterval = 3) -> Bool {
        app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", words)).firstMatch
            .waitForExistence(timeout: seconds)
    }

    @MainActor private func goBack(_ app: XCUIApplication) -> Bool {
        let back = app.navigationBars.buttons.element(boundBy: 0)
        guard back.waitForExistence(timeout: 2), back.isHittable else { return false }
        back.tap()
        return true
    }

    @MainActor private func flipFirstSwitch(_ app: XCUIApplication) -> Bool {
        let toggle = app.switches.firstMatch
        guard toggle.waitForExistence(timeout: 2) else { return false }
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        return true
    }

    /// Look 01. Every control that looks alive answers, and the answer can be
    /// read on the screen itself: no note beside a control says what it did.
    @MainActor func testQuietParts() {
        var app = open("quiet-parts", variant: "home")
        XCTAssertTrue(shows(app, "2 left today"))
        step(app, "tick the late chore") { tap(app, id: "tick", index: 0) }
        XCTAssertTrue(shows(app, "1 left today"), "ticking a chore did not change the sentence")
        XCTAssertFalse(shows(app, "1 overdue", within: 0.5), "the late chore is done and the sentence still says overdue")
        step(app, "choose the 14th") { press(app, "14", .contains) }
        XCTAssertTrue(shows(app, "2 on Thursday"), "choosing a day did not change the sentence")
        XCTAssertTrue(shows(app, "Pay the internet bill"), "choosing a day did not change the list")
        step(app, "back to today") { press(app, "13", .contains) }

        step(app, "open the add sheet") { press(app, "Add a chore") }
        XCTAssertTrue(button(app, "Add chore").waitForExistence(timeout: 3))
        XCTAssertFalse(button(app, "Add chore").isEnabled, "the button is on with no name typed")
        step(app, "choose Mina") { press(app, "Mina") }
        step(app, "switch repeating off") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "0")
        step(app, "type a name that is taken") { type(app, "Empty the dishwasher") }
        step(app, "try to add it") { press(app, "Add chore") }
        XCTAssertTrue(shows(app, "Already on today"), "a taken name was not refused")
        step(app, "change the name") { type(app, " again") }
        XCTAssertFalse(shows(app, "Already on today", within: 0.5), "the reason stayed after the name changed")
        step(app, "add it", wait: 0.3) { press(app, "Add chore") }
        XCTAssertTrue(shows(app, "Empty the dishwasher again", within: 6), "the new chore is not on the list")
        XCTAssertTrue(shows(app, "2 left today"), "the sentence did not count the new chore")

        app = open("quiet-parts", variant: "empty")
        XCTAssertTrue(shows(app, "No chores this week"))
        step(app, "copy last week") { press(app, "Copy last week") }
        XCTAssertTrue(shows(app, "left today"), "copying last week left the list empty")

        app = open("quiet-parts", variant: "week")
        XCTAssertTrue(shows(app, "1 of 3"))
        step(app, "tick a chore") { tap(app, id: "tick", index: 1) }
        XCTAssertTrue(shows(app, "2 of 3"), "ticking a chore did not move the count")

        app = open("quiet-parts", variant: "flat")
        step(app, "link the second account", wait: 0.2) { press(app, "Link") }
        XCTAssertTrue(button(app, "Link", .prefix).waitForNonExistence(timeout: 5), "the account did not become linked")

        app = open("quiet-parts", variant: "plants")
        step(app, "tick a plant") { tap(app, id: "tick", index: 0) }

        app = open("quiet-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        step(app, "let it settle", wait: 2.5) { true }
        XCTAssertTrue(shows(app, "offline"))
        finish(app)
    }

    /// Look 03.
    @MainActor func testDataParts() {
        var app = open("data-parts", variant: "services")
        step(app, "open the slow service", wait: 1.8) { press(app, "Billing export", .contains) }
        XCTAssertTrue(shows(app, "Slow from Singapore"), "the row did not open its service")
        step(app, "choose seven days") { press(app, "7 d") }
        XCTAssertTrue(shows(app, "7 d ago"), "the range chip changed nothing")
        step(app, "go back", wait: 1.8) { goBack(app) }

        step(app, "open the add sheet") { press(app, "Add a service") }
        // A toggle with a style of its own is still a switch to the system.
        let alerts = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", "Alert me")).firstMatch
        XCTAssertTrue(alerts.waitForExistence(timeout: 3), "no element is named Alert me")
        let before = "\(alerts.label) | \(String(describing: alerts.value))"
        step(app, "turn alerts off") { alerts.tap(); return true }
        XCTAssertNotEqual(before, "\(alerts.label) | \(String(describing: alerts.value))", "the chip did not change")
        step(app, "set a limit that is too low") {
            type(app, String(repeating: XCUIKeyboardKey.delete.rawValue, count: 3) + "50", field: 1, atRight: true)
        }
        step(app, "add with no address") { press(app, "Add service") }
        XCTAssertTrue(shows(app, "Needs an address"), "an empty address was not refused")
        XCTAssertTrue(shows(app, "Enter 100 ms or more"), "a low limit was not refused")
        step(app, "raise the limit") { type(app, "0", field: 1, atRight: true) }
        XCTAssertFalse(shows(app, "Enter 100 ms or more", within: 0.5), "the reason stayed after the figure changed")
        step(app, "type an address") { type(app, "pay.northline.example") }
        XCTAssertFalse(shows(app, "Needs an address", within: 0.5), "the reason stayed after an address was typed")
        step(app, "add it", wait: 0.3) { press(app, "Add service") }
        XCTAssertTrue(button(app, "pay.northline.example", .contains).waitForExistence(timeout: 6), "the new service is not on the list")

        app = open("data-parts", variant: "empty")
        XCTAssertTrue(shows(app, "No services yet"))
        step(app, "open the add sheet from the empty state") { press(app, "Add a service") }
        XCTAssertTrue(shows(app, "New service"), "the empty state's button opened nothing")

        app = open("data-parts", variant: "check")
        step(app, "acknowledge", wait: 0.2) { press(app, "Acknowledge") }
        XCTAssertTrue(button(app, "Acknowledged").waitForExistence(timeout: 5), "the button did not say it was done")
        XCTAssertFalse(button(app, "Acknowledged").isEnabled, "a finished action can be sent again")

        app = open("data-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Checking"))
        XCTAssertTrue(shows(app, "reach the monitor", within: 5))
        finish(app)
    }

    /// Look 05.
    @MainActor func testTactileParts() {
        var app = open("tactile-parts", variant: "today")
        XCTAssertTrue(shows(app, "of 60 min"))
        step(app, "log ten minutes", wait: 0.3) { press(app, "+10 min") }
        XCTAssertTrue(button(app, "Undo +10 min").waitForExistence(timeout: 5), "the key's action did not finish")
        XCTAssertTrue(shows(app, "50"), "the count did not move")
        step(app, "undo it") { press(app, "Undo +10 min") }
        XCTAssertTrue(shows(app, "40"))
        step(app, "open the goal", wait: 1.8) { tap(app, id: "disc") }
        XCTAssertTrue(shows(app, "Count weekends"), "the disc opened nothing")
        step(app, "switch reminders off") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "0")
        step(app, "open the daily goal", wait: 1.8) { tap(app, id: "go") }
        step(app, "choose thirty minutes") { press(app, "30 min") }
        step(app, "go back", wait: 1.8) { goBack(app) }
        XCTAssertTrue(shows(app, "30 min"), "the chosen goal is not in its row")
        step(app, "back to today", wait: 1.8) { goBack(app) }
        XCTAssertTrue(shows(app, "of 30 min"), "the chosen goal did not reach the day")

        app = open("tactile-parts", variant: "week")
        XCTAssertTrue(shows(app, "of 130 min"))
        step(app, "open the add sheet") { tap(app, id: "add") }
        let key = app.buttons.matching(identifier: "add-key").firstMatch
        XCTAssertTrue(key.waitForExistence(timeout: 3))
        XCTAssertFalse(key.isEnabled, "the key is on with no name typed")
        step(app, "type a name that is taken") { type(app, "Cello") }
        step(app, "try to add it") { tap(app, id: "add-key") }
        XCTAssertTrue(shows(app, "Cello is already here"), "a taken name was not refused")
        step(app, "change the name") { type(app, " two") }
        XCTAssertFalse(shows(app, "is already here", within: 0.5), "the reason stayed after the name changed")
        step(app, "add it") { tap(app, id: "add-key") }
        XCTAssertTrue(shows(app, "Cello two", within: 5), "the new instrument is not on the list")
        XCTAssertTrue(shows(app, "of 160 min"), "the week's total did not count it")

        app = open("tactile-parts", variant: "empty")
        step(app, "set a goal", wait: 1.8) { press(app, "Set a goal") }
        step(app, "choose forty minutes") { press(app, "40 min") }
        step(app, "go back", wait: 1.8) { goBack(app) }
        XCTAssertTrue(shows(app, "of 40 min"), "the goal did not reach the day")

        app = open("tactile-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        step(app, "let it settle", wait: 2.5) { true }
        finish(app)
    }

    /// Look 09.
    @MainActor func testMetricParts() {
        var app = open("metric-parts", variant: "home")
        step(app, "open the study", wait: 1.8) { press(app, "Study", .contains) }
        XCTAssertTrue(shows(app, "Above 1,000 ppm"), "the row did not open its room")
        step(app, "change the alert") { press(app, "Change") }
        step(app, "choose hourly") { press(app, "Hourly") }
        step(app, "switch night on") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "1")
        step(app, "make it too low") { type(app, String(repeating: XCUIKeyboardKey.delete.rawValue, count: 4) + "300") }
        step(app, "try to save") { press(app, "Save alert") }
        XCTAssertTrue(shows(app, "Enter 500 or more"), "a low limit was not refused")
        step(app, "raise it") { type(app, String(repeating: XCUIKeyboardKey.delete.rawValue, count: 3) + "900") }
        XCTAssertFalse(shows(app, "Enter 500 or more", within: 0.5), "the reason stayed after the number changed")
        step(app, "save it", wait: 0.3) { press(app, "Save alert") }
        XCTAssertTrue(shows(app, "Above 900 ppm", within: 6), "the saved limit is not in its row")
        XCTAssertTrue(shows(app, "hourly"))

        app = open("metric-parts", variant: "empty")
        step(app, "pair a sensor", wait: 0.3) { press(app, "Pair a sensor") }
        XCTAssertTrue(shows(app, "Looking nearby"))
        XCTAssertTrue(shows(app, "New sensor", within: 6), "pairing left the screen empty")

        app = open("metric-parts", variant: "household")
        step(app, "link the second maker", wait: 0.2) { press(app, "Link") }
        XCTAssertTrue(button(app, "Link", .prefix).waitForNonExistence(timeout: 5), "the maker did not become linked")

        app = open("metric-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        step(app, "let it settle", wait: 2.5) { true }
        finish(app)
    }

    /// Look 10.
    @MainActor func testBlockParts() {
        var app = open("block-parts", variant: "week")
        XCTAssertTrue(shows(app, "3 h"))
        step(app, "open the add sheet") { press(app, "Add a shift") }
        XCTAssertTrue(button(app, "Add shift").waitForExistence(timeout: 3))
        XCTAssertFalse(button(app, "Add shift").isEnabled, "the button is on with no name typed")
        step(app, "choose feeding") { press(app, "Feeding", .contains) }
        step(app, "choose one hour") { press(app, "1 h") }
        step(app, "switch every day on") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "1")
        step(app, "type a name that is taken") { type(app, "Walk Otis") }
        step(app, "try to add it") { press(app, "Add shift") }
        XCTAssertTrue(shows(app, "already on Saturday"), "a taken shift was not refused")
        step(app, "change the name") { type(app, " again") }
        XCTAssertFalse(shows(app, "already on Saturday", within: 0.5), "the reason stayed after the name changed")
        step(app, "add it", wait: 0.3) { press(app, "Add shift") }
        XCTAssertTrue(shows(app, "4 h", within: 6), "the feeding block did not grow")

        app = open("block-parts", variant: "empty")
        step(app, "open the add sheet from the empty state") { press(app, "Add a shift") }
        XCTAssertTrue(shows(app, "New shift"), "the empty state's button opened nothing")

        app = open("block-parts", variant: "team")
        XCTAssertTrue(shows(app, "Nobody yet"))
        step(app, "take the open shift") { press(app, "Take it") }
        XCTAssertTrue(shows(app, "You"), "the open shift was not taken")
        XCTAssertFalse(shows(app, "Nobody yet", within: 0.5))

        app = open("block-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        step(app, "let it settle", wait: 2.5) { true }
        finish(app)
    }

    /// Look 14.
    @MainActor func testMediaParts() {
        var app = open("media-parts", variant: "shelf")
        step(app, "open a print", wait: 1.8) { press(app, "Twilight Moon", .contains) }
        step(app, "reserve it", wait: 0.3) { press(app, "Reserve") }
        XCTAssertTrue(shows(app, "collect by Friday", within: 6), "the picture did not say it was reserved")
        XCTAssertTrue(button(app, "Cancel").exists, "the action did not turn into its way back")
        step(app, "choose the small size") { press(app, "24 × 36 cm") }
        step(app, "cancel it") { press(app, "Cancel") }
        XCTAssertTrue(button(app, "Reserve").waitForExistence(timeout: 3))
        step(app, "go back", wait: 1.8) { goBack(app) }

        step(app, "open the suggestion sheet") { press(app, "Suggest a print") }
        XCTAssertTrue(button(app, "Send suggestion").waitForExistence(timeout: 3))
        XCTAssertFalse(button(app, "Send suggestion").isEnabled, "the button is on with no title typed")
        step(app, "choose poster") { press(app, "Poster") }
        step(app, "switch telling off") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "0")
        step(app, "type a title the library has") { type(app, "Twilight Moon") }
        step(app, "try to send it") { press(app, "Send suggestion") }
        XCTAssertTrue(shows(app, "already has this one"), "a held title was not refused")
        step(app, "change the title") { type(app, " II") }
        XCTAssertFalse(shows(app, "already has this one", within: 0.5), "the reason stayed after the title changed")
        step(app, "send it", wait: 0.3) { press(app, "Send suggestion") }
        XCTAssertTrue(shows(app, "suggested today", within: 6), "the suggestion is not on the shelf")

        app = open("media-parts", variant: "empty")
        step(app, "see this week's print", wait: 1.8) { press(app, "See this week", .prefix) }
        XCTAssertTrue(shows(app, "Sudden Shower"), "the empty state's button opened nothing")

        app = open("media-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        step(app, "let it settle", wait: 2.5) { true }
        finish(app)
    }

    /// Look 02.
    @MainActor func testReadingParts() {
        var app = open("reading-parts", variant: "issue")
        XCTAssertTrue(shows(app, "The Bridge That Counts Bicycles"))
        step(app, "keep the first story") { tap(app, id: "keep", index: 0) }

        app = open("reading-parts", variant: "empty")
        step(app, "read last week's") { press(app, "Read last week", .prefix) }
        XCTAssertTrue(shows(app, "Bread, Proved Twice"), "the empty state's link opened nothing")

        app = open("reading-parts", variant: "masthead")
        step(app, "write to the editor") { press(app, "Write to the editor") }
        XCTAssertTrue(button(app, "Send").waitForExistence(timeout: 3))
        XCTAssertFalse(button(app, "Send").isEnabled, "send is on with no words")
        step(app, "choose another story") { press(app, "A Cello Older Than the Country") }
        step(app, "switch my name off") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "0")
        step(app, "type too little") { type(app, "Lovely.") }
        step(app, "try to send") { press(app, "Send") }
        XCTAssertTrue(shows(app, "ten words or more"), "a short letter was not refused")
        step(app, "write more") { type(app, " The counter on Mill Street has been wrong since March, I think.") }
        XCTAssertFalse(shows(app, "ten words or more", within: 0.5), "the reason stayed after the words changed")
        step(app, "send it", wait: 0.3) { press(app, "Send") }
        XCTAssertTrue(shows(app, "Sent", within: 6), "the letter is not on the masthead")

        app = open("reading-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        step(app, "let it settle", wait: 2.5) { true }
        finish(app)
    }

    /// Look 06.
    @MainActor func testProParts() {
        var app = open("pro-parts", variant: "takes")
        XCTAssertTrue(shows(app, "04:12"))
        step(app, "select another take") { press(app, "room_tone", .contains) }
        XCTAssertTrue(shows(app, "00:30"))
        step(app, "open export") { press(app, "Export") }
        step(app, "choose FLAC") { press(app, "FLAC") }
        step(app, "switch normalise on") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "1")
        step(app, "rename to a taken name") { type(app, String(repeating: XCUIKeyboardKey.delete.rawValue, count: 9) + "cello_take_01") }
        step(app, "try to export") { press(app, "Export", index: 1) }
        XCTAssertTrue(shows(app, "Another take has this name"), "a taken name was not refused")
        step(app, "change the name") { type(app, "b") }
        XCTAssertFalse(shows(app, "Another take has this name", within: 0.5), "the reason stayed after the name changed")
        step(app, "export it", wait: 0.3) { press(app, "Export", index: 1) }
        XCTAssertTrue(shows(app, "cello_take_01b", within: 6), "the take did not take its new name")
        XCTAssertTrue(shows(app, "FLAC"), "the take does not show its format")

        app = open("pro-parts", variant: "empty")
        step(app, "import") { press(app, "Import from the recorder") }
        XCTAssertTrue(shows(app, "cello_take_03"), "importing left the list empty")

        app = open("pro-parts", variant: "session")
        step(app, "take the second seat") { press(app, "Take it") }
        XCTAssertTrue(shows(app, "You"))

        app = open("pro-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        step(app, "let it settle", wait: 2.5) { true }
        finish(app)
    }

    /// Look 12.
    @MainActor func testFocusParts() {
        var app = open("focus-parts", variant: "drafts")
        step(app, "open the new draft sheet") { press(app, "New draft") }
        XCTAssertTrue(button(app, "Start draft").waitForExistence(timeout: 3))
        XCTAssertFalse(button(app, "Start draft").isEnabled, "the key is on with no title")
        step(app, "aim for five minutes") { press(app, "5 min") }
        step(app, "switch counting off") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "0")
        step(app, "type a title that is taken") { type(app, "Opening the book fair") }
        step(app, "try to start") { press(app, "Start draft") }
        XCTAssertTrue(shows(app, "already has this title"), "a taken title was not refused")
        step(app, "change the title") { type(app, " again", atRight: true) }
        XCTAssertFalse(shows(app, "already has this title", within: 0.5), "the reason stayed after the title changed")
        step(app, "start it", wait: 0.3) { press(app, "Start draft") }
        // The sheet takes a moment to leave; the list is read after it has.
        Thread.sleep(forTimeInterval: 3)
        XCTAssertTrue(shows(app, "Opening the book fair again", within: 6), "the new draft is not on the list")

        app = open("focus-parts", variant: "empty")
        step(app, "new draft from the empty state") { press(app, "New draft") }
        XCTAssertTrue(shows(app, "aim for"), "the empty state's key opened nothing")

        app = open("focus-parts", variant: "shared")
        step(app, "add Marek") { press(app, "add Marek", .contains) }
        XCTAssertTrue(shows(app, "Marek"))
        XCTAssertFalse(shows(app, "nobody else yet", within: 0.5))

        app = open("focus-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        step(app, "let it settle", wait: 2.5) { true }
        finish(app)
    }

    /// Look 04.
    @MainActor func testSoftParts() {
        var app = open("soft-parts", variant: "today")
        XCTAssertTrue(shows(app, "about your usual"))
        step(app, "open the check-in sheet") { press(app, "Check in") }
        XCTAssertTrue(button(app, "Save check-in").waitForExistence(timeout: 3))
        XCTAssertFalse(button(app, "Save check-in").isEnabled, "the button is on with nothing chosen")
        step(app, "choose good") { press(app, "Good", .prefix) }
        XCTAssertTrue(button(app, "Save check-in").isEnabled, "choosing did not turn the button on")
        step(app, "save it") { press(app, "Save check-in") }
        XCTAssertTrue(shows(app, "9:41 AM · higher than your usual", within: 6), "the new answer does not lead the screen")
        XCTAssertFalse(shows(app, "about your usual", within: 0.5), "the old lead kept its comparison")
        XCTAssertTrue(shows(app, "9:12 AM"), "the old lead did not become a row")
        step(app, "open an answer with a note", wait: 1.8) { press(app, "7:40 AM", .contains) }
        XCTAssertTrue(shows(app, "Walked to the bridge"), "the row did not open its note")
        step(app, "go back") { goBack(app) }

        step(app, "open the circle", wait: 1.8) { press(app, "Circle") }
        step(app, "link the second app", wait: 0.2) { press(app, "Link") }
        XCTAssertTrue(shows(app, "Linking"))
        XCTAssertTrue(button(app, "Link", .prefix).waitForNonExistence(timeout: 6), "the app did not become linked")
        step(app, "open the invite sheet") { press(app, "Invite someone", .contains) }
        XCTAssertTrue(button(app, "Send invite").waitForExistence(timeout: 3))
        XCTAssertFalse(button(app, "Send invite").isEnabled, "the button is on with no address typed")
        step(app, "choose the whole week") { press(app, "The whole week", .prefix) }
        step(app, "switch notes on") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "1")
        step(app, "type an address with no @") { type(app, "ana.example.com") }
        step(app, "try to send") { press(app, "Send invite") }
        XCTAssertTrue(shows(app, "needs an @"), "a bad address was not refused")
        step(app, "mend it") { type(app, String(repeating: XCUIKeyboardKey.delete.rawValue, count: 12) + "@example.com") }
        XCTAssertFalse(shows(app, "needs an @", within: 0.5), "the reason stayed after the address changed")
        step(app, "send it", wait: 0.3) { press(app, "Send invite") }
        XCTAssertTrue(shows(app, "Sending"))
        XCTAssertTrue(shows(app, "ana@example.com", within: 6), "the invited person is not in the circle")
        XCTAssertTrue(shows(app, "Invited"))

        app = open("soft-parts", variant: "empty")
        XCTAssertTrue(shows(app, "No check-in yet today"))
        step(app, "check in from the empty screen") { press(app, "Check in") }
        step(app, "choose low") { press(app, "Low", .prefix) }
        step(app, "save it") { press(app, "Save check-in") }
        XCTAssertTrue(shows(app, "lower than your usual", within: 6), "the first answer left the screen empty")
        XCTAssertFalse(shows(app, "No check-in yet today", within: 0.5))

        app = open("soft-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        step(app, "let it settle", wait: 2.5) { true }
        XCTAssertTrue(shows(app, "Not saved to your account"))
        finish(app)
    }

    /// Look 07.
    @MainActor func testSceneParts() {
        var app = open("scene-parts", variant: "coves")
        XCTAssertTrue(shows(app, "Rising"))
        step(app, "open Gull Rock", wait: 1.8) { press(app, "Gull Rock", .contains) }
        XCTAssertTrue(shows(app, "Alert below 1.0 m"), "the row did not open its cove")
        step(app, "change the alert") { press(app, "Change") }
        step(app, "choose two hours") { press(app, "2 h") }
        step(app, "switch night on") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "1")
        step(app, "make it too low") { type(app, String(repeating: XCUIKeyboardKey.delete.rawValue, count: 3) + "0.3", atRight: true) }
        step(app, "try to save") { press(app, "Save alert") }
        XCTAssertTrue(shows(app, "never drops below"), "a level under the lowest tide was not refused")
        step(app, "raise it") { type(app, String(repeating: XCUIKeyboardKey.delete.rawValue, count: 3) + "1.5", atRight: true) }
        XCTAssertFalse(shows(app, "never drops below", within: 0.5), "the reason stayed after the number changed")
        step(app, "save it", wait: 0.3) { press(app, "Save alert") }
        XCTAssertTrue(shows(app, "Alert below 1.5 m", within: 6), "the saved level is not in its row")
        XCTAssertTrue(shows(app, "2 h ahead"))
        step(app, "go back to the coves") { goBack(app) }
        XCTAssertTrue(shows(app, "Marram Bay"), "the way back did not reach the coves")

        app = open("scene-parts", variant: "empty")
        step(app, "find a cove", wait: 0.3) { press(app, "Find the nearest cove") }
        XCTAssertTrue(shows(app, "Looking nearby"))
        XCTAssertTrue(shows(app, "Gull Rock", within: 6), "finding left the screen empty")

        app = open("scene-parts", variant: "crew")
        step(app, "link the second buoy maker", wait: 0.2) { press(app, "Link") }
        XCTAssertTrue(button(app, "Link", .prefix).waitForNonExistence(timeout: 5), "the maker did not become linked")

        app = open("scene-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        step(app, "let it settle", wait: 2.5) { true }
        XCTAssertTrue(shows(app, "Offline"), "the notice did not come back after the try")
        finish(app)
    }

    /// Look 08.
    @MainActor func testWarmParts() {
        var app = open("warm-parts", variant: "counter")
        XCTAssertTrue(shows(app, "38 min left"))
        step(app, "open the bake that is rising", wait: 1.8) { press(app, "Country loaf", .contains) }
        XCTAssertTrue(button(app, "Next step").waitForExistence(timeout: 3), "the picture did not open its bake")
        step(app, "go back") { goBack(app) }
        step(app, "open the add sheet") { press(app, "New rise") }
        XCTAssertTrue(button(app, "Start rise").waitForExistence(timeout: 3))
        XCTAssertFalse(button(app, "Start rise").isEnabled, "the button is on with no name typed")
        step(app, "choose four hours") { press(app, "4 h") }
        step(app, "switch the alert off") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "0")
        step(app, "type a name that is taken") { type(app, "Rye starter") }
        step(app, "try to start it") { press(app, "Start rise") }
        XCTAssertTrue(shows(app, "already called Rye starter"), "a taken name was not refused")
        step(app, "change the name") { type(app, " two") }
        XCTAssertFalse(shows(app, "already called", within: 0.5), "the reason stayed after the name changed")
        step(app, "start it", wait: 0.3) { press(app, "Start rise") }
        XCTAssertTrue(shows(app, "Starting"))
        XCTAssertTrue(shows(app, "Rye starter two", within: 6), "the new jar is not on the counter")
        XCTAssertTrue(shows(app, "4 h left"), "the new jar does not say how long it has")

        app = open("warm-parts", variant: "empty")
        step(app, "open the add sheet from the empty state") { press(app, "Start a first rise") }
        step(app, "name it") { type(app, "Brioche") }
        step(app, "start it", wait: 0.3) { press(app, "Start rise") }
        XCTAssertTrue(shows(app, "2 h left", within: 6), "the first jar did not take the lead")
        XCTAssertFalse(shows(app, "Nothing rising", within: 0.5))

        app = open("warm-parts", variant: "counter")
        step(app, "open a recipe", wait: 1.8) { press(app, "Seeded rye", .contains) }
        step(app, "start the bake") { press(app, "Start this bake") }
        XCTAssertTrue(button(app, "Next step").waitForExistence(timeout: 3), "starting did not change the button")
        step(app, "finish mixing") { press(app, "Next step") }
        step(app, "finish the rise") { press(app, "Next step") }
        step(app, "finish baking") { press(app, "Next step") }
        XCTAssertTrue(button(app, "Baked").waitForExistence(timeout: 3), "the last step did not end the bake")
        XCTAssertFalse(button(app, "Baked").isEnabled, "the button is still on after the last step")

        app = open("warm-parts", variant: "kitchen")
        step(app, "link the second oven", wait: 0.2) { press(app, "Link") }
        XCTAssertTrue(shows(app, "Linking"))
        XCTAssertTrue(button(app, "Link", .prefix).waitForNonExistence(timeout: 6), "the oven did not become linked")

        app = open("warm-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        XCTAssertTrue(shows(app, "Couldn’t sync the jars", within: 6), "the notice did not come back after a failed try")
        finish(app)
    }

    /// Look 11.
    @MainActor func testLayerParts() {
        var app = open("layer-parts", variant: "map")
        XCTAssertTrue(shows(app, "Working · checked 2 days ago"), "the nearest point does not lead the surface")
        step(app, "open the broken tap", wait: 1.8) { press(app, "Pond-side tap", .contains) }
        XCTAssertTrue(shows(app, "Reported not working"), "the row did not open its point")
        step(app, "say it works again", wait: 0.3) { press(app, "Still working") }
        XCTAssertTrue(shows(app, "Saving"))
        XCTAssertTrue(shows(app, "checked just now", within: 6), "the badge did not change after the check")
        XCTAssertFalse(button(app, "Still working").isEnabled, "the button is still on for a point checked just now")
        step(app, "report a problem") { press(app, "Report a problem") }
        step(app, "say what is wrong") { press(app, "Not working") }
        XCTAssertTrue(shows(app, "Problem reported"), "the badge did not change after the report")
        XCTAssertFalse(button(app, "Report a problem").isEnabled, "a reported point can be reported again")
        step(app, "go back to the plan", wait: 1.8) { goBack(app) }
        XCTAssertTrue(shows(app, "not working"), "the report did not reach the point's row")

        step(app, "open the add sheet") { press(app, "Add a point") }
        XCTAssertTrue(button(app, "Add point").waitForExistence(timeout: 3))
        XCTAssertFalse(button(app, "Add point").isEnabled, "the button is on with no name typed")
        step(app, "choose a tap") { press(app, "Tap") }
        step(app, "switch step-free on") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "1")
        step(app, "type a name that is taken") { type(app, "Pond-side tap") }
        step(app, "try to add it") { press(app, "Add point") }
        XCTAssertTrue(shows(app, "already on the map"), "a taken name was not refused")
        step(app, "change the name") { type(app, " 2") }
        XCTAssertFalse(shows(app, "already on the map", within: 0.5), "the reason stayed after the name changed")
        step(app, "add it", wait: 0.3) { press(app, "Add point") }
        XCTAssertTrue(shows(app, "Adding"))
        XCTAssertTrue(shows(app, "1.1 km", within: 6), "the new point has no row on the surface")
        step(app, "open the new point", wait: 1.8) { press(app, "Pond-side tap 2", .contains) }
        XCTAssertTrue(shows(app, "Step-free access"), "the switch did not reach the new point")
        step(app, "go back to the plan", wait: 1.8) { goBack(app) }
        step(app, "open the keepers", wait: 1.8) { press(app, "Keepers") }
        XCTAssertTrue(shows(app, "Mina"), "the bar's button opened nothing")

        app = open("layer-parts", variant: "empty")
        step(app, "search a wider area", wait: 0.3) { press(app, "Search a wider area") }
        XCTAssertTrue(shows(app, "Searching"))
        XCTAssertTrue(shows(app, "North gate fountain", within: 6), "the wider search left the surface empty")

        app = open("layer-parts", variant: "keepers")
        XCTAssertTrue(shows(app, "Nobody yet"))
        step(app, "take the open point") { press(app, "Take it") }
        XCTAssertTrue(shows(app, "You"), "the open point was not taken")
        XCTAssertFalse(shows(app, "Nobody yet", within: 0.5))
        step(app, "link the second source", wait: 0.2) { press(app, "Link") }
        XCTAssertTrue(button(app, "Link", .prefix).waitForNonExistence(timeout: 5), "the source did not become linked")

        app = open("layer-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        step(app, "let it settle", wait: 2.5) { true }
        finish(app)
    }

    /// Look 13. The work leads every screen; each control's answer can be
    /// read on the screen.
    @MainActor func testCanvasParts() {
        var app = open("canvas-parts", variant: "flyers")
        step(app, "open the new flyer sheet") { press(app, "New flyer") }
        XCTAssertTrue(button(app, "Create flyer").waitForExistence(timeout: 3))
        XCTAssertFalse(button(app, "Create flyer").isEnabled, "the button is on with no name typed")
        step(app, "choose square") { press(app, "Square") }
        step(app, "switch the title off") { flipFirstSwitch(app) }
        XCTAssertEqual(app.switches.firstMatch.value as? String, "0")
        step(app, "type a name that is taken") { type(app, "Plant swap flyer") }
        step(app, "try to create it") { press(app, "Create flyer") }
        XCTAssertTrue(shows(app, "already have a flyer"), "a taken name was not refused")
        step(app, "change the name") { type(app, " 2") }
        XCTAssertFalse(shows(app, "already have a flyer", within: 0.5), "the reason stayed after the name changed")
        step(app, "create it", wait: 0.3) { press(app, "Create flyer") }
        XCTAssertTrue(button(app, "Create flyer").waitForNonExistence(timeout: 6), "the sheet did not close")
        XCTAssertTrue(shows(app, "Plant swap flyer 2"), "the new flyer is not on the board")

        step(app, "open a flyer from its row", wait: 1.8) { press(app, "Street party", .contains) }
        XCTAssertTrue(shows(app, "£8.75"), "the row did not open its flyer")
        step(app, "choose fifty copies") { press(app, "50 copies") }
        XCTAssertTrue(shows(app, "£15.00"), "the price did not follow the copies")
        step(app, "order the prints", wait: 0.3) { press(app, "Order prints") }
        XCTAssertTrue(shows(app, "Sending"))
        XCTAssertTrue(shows(app, "Ready Thursday", within: 6), "the order was not answered")
        XCTAssertFalse(button(app, "10 copies").isEnabled, "the copies can still be changed after the order")
        step(app, "cancel the order") { press(app, "Cancel order") }
        XCTAssertTrue(button(app, "Order prints").waitForExistence(timeout: 3), "cancelling did not bring the action back")
        step(app, "go back", wait: 1.8) { goBack(app) }

        step(app, "open people", wait: 1.8) { press(app, "People") }
        step(app, "link the second print shop", wait: 0.2) { press(app, "Link") }
        XCTAssertTrue(button(app, "Link", .prefix).waitForNonExistence(timeout: 5), "the shop did not become linked")

        app = open("canvas-parts", variant: "empty")
        step(app, "start a flyer from the empty board") { press(app, "New flyer") }
        step(app, "name it") { type(app, "Book swap") }
        step(app, "create it", wait: 0.3) { press(app, "Create flyer") }
        XCTAssertTrue(shows(app, "Creating"))
        XCTAssertTrue(button(app, "Cancel").waitForNonExistence(timeout: 6), "the sheet did not close")
        XCTAssertTrue(shows(app, "Book swap"), "creating left the board empty")
        XCTAssertFalse(shows(app, "No flyers yet", within: 0.5), "the empty board stayed")

        app = open("canvas-parts", variant: "offline")
        step(app, "try again", wait: 0.1) { press(app, "Try again") }
        XCTAssertTrue(shows(app, "Trying"))
        step(app, "let it settle", wait: 2.5) { true }
        finish(app)
    }
}
