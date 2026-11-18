import XCTest

// Presses every control on the good side of each pair and checks that the
// screen changes. A good side with a control that does nothing would break
// the rule it sits beside (G5).
//
// It also presses the controls that are meant to work on the bad sides. A bad
// side shows one failure; these tests keep a second one from creeping in.
// G5's bad side is not pressed: its controls do nothing on purpose.

final class PairsTour: XCTestCase {
    @MainActor private func open(_ pair: String, side: String = "good") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-pair", pair, "-side", side]
        app.launch()
        return app
    }

    @MainActor private func sees(_ app: XCUIApplication, _ text: String) -> Bool {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch.waitForExistence(timeout: 3)
            || app.buttons.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch.waitForExistence(timeout: 1)
    }

    // MARK: Good sides

    @MainActor func testG03TopUp() {
        let app = open("g03")
        app.buttons["Top up £10"].tap()
        XCTAssertTrue(sees(app, "£22.40"))
    }

    @MainActor func testG05RowAndAdd() {
        let app = open("g05")
        app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "The Living Mountain")).firstMatch.tap()
        XCTAssertEqual(app.staticTexts.matching(NSPredicate(format: "label == %@", "Finished")).count, 2)
        app.buttons["Add a book"].tap()
        XCTAssertTrue(sees(app, "Pilgrim at Tinker Creek"))
    }

    @MainActor func testG06Save() {
        let app = open("g06")
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "label == %@", "Save")).count, 2)
        app.buttons.matching(NSPredicate(format: "label == %@", "Save")).firstMatch.tap()
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "label == %@", "Saved")).count, 2)
    }

    @MainActor func testG07TryAgain() {
        let app = open("g07")
        app.buttons["Try again"].tap()
        XCTAssertTrue(app.buttons["Trying…"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Try again"].waitForExistence(timeout: 6))
    }

    @MainActor func testG08PauseAndStop() {
        let app = open("g08")
        app.buttons["Pause"].tap()
        XCTAssertTrue(app.buttons["Play"].waitForExistence(timeout: 2))
        app.buttons["Stop"].tap()
        XCTAssertTrue(sees(app, "STOPPED"))
    }

    @MainActor func testG09DeleteAndSearch() {
        let app = open("g09")
        XCTAssertTrue(sees(app, "Seed order") || app.textViews.firstMatch.waitForExistence(timeout: 3))
        app.buttons["Delete"].tap()
        XCTAssertEqual(app.textViews.firstMatch.value as? String ?? "", "")
        app.tabBars.buttons["Search"].tap()
        XCTAssertTrue(app.navigationBars["Search"].waitForExistence(timeout: 3))
    }

    @MainActor func testG10AddATicket() {
        let app = open("g10")
        app.buttons["Add a ticket"].tap()
        app.swipeUp()
        XCTAssertTrue(sees(app, "New Year Ceilidh"))
    }

    @MainActor func testG11TurnOnAlerts() {
        let app = open("g11")
        app.buttons["Turn on"].tap()
        XCTAssertTrue(sees(app, "Alerts are on"))
        XCTAssertTrue(app.buttons["Turn off"].exists)
    }

    // MARK: Bad sides, the controls that are meant to work

    @MainActor func testBadG03TopUp() {
        let app = open("g03", side: "bad")
        XCTAssertTrue(sees(app, "£12.40"))
        app.buttons["Top up"].tap()
        XCTAssertTrue(sees(app, "£22.40"))
    }

    @MainActor func testBadG06BothControlsChangeOneThing() {
        let app = open("g06", side: "bad")
        app.buttons["Favourite"].tap()
        XCTAssertTrue(app.buttons["Saved to collection"].waitForExistence(timeout: 2))
        app.buttons["Saved to collection"].tap()
        XCTAssertTrue(app.buttons["Save to collection"].waitForExistence(timeout: 2))
    }

    @MainActor func testBadG08PauseAndStop() {
        let app = open("g08", side: "bad")
        app.buttons["Pause"].tap()
        XCTAssertTrue(app.buttons["Play"].waitForExistence(timeout: 2))
        app.buttons["Stop"].tap()
        XCTAssertTrue(sees(app, "STOPPED"))
    }

    @MainActor func testBadG10AddATicket() {
        let app = open("g10", side: "bad")
        app.buttons["Add a ticket"].tap()
        XCTAssertTrue(sees(app, "New Year Ceilidh"))
    }

    @MainActor func testBadG11ThreePagesThenTheWeather() {
        let app = open("g11", side: "bad")
        XCTAssertTrue(sees(app, "Welcome to Drizzle"))
        app.buttons["Next"].tap()
        XCTAssertTrue(sees(app, "Create your account"))
        app.buttons["Next"].tap()
        XCTAssertTrue(sees(app, "Turn on notifications"))
        app.buttons["Get started"].tap()
        XCTAssertTrue(sees(app, "Rain in 25 min"))
    }
}
