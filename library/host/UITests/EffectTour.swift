import XCTest

// Drives one entry through the presses that show its motion, slowly enough
// for a screen recording to catch each one. Start a recording with
// `xcrun simctl io <device> recordVideo <file>` and run one test.
//
// These tests assert nothing. They exist so that motion can be looked at.

final class EffectTour: XCTestCase {
    @MainActor private func open(_ pattern: String, state: String = "loaded") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-pattern", pattern, "-state", state]
        app.launch()
        return app
    }

    @MainActor private func wait(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }

    /// 08: add time, then call the dough ready.
    @MainActor func testProofTimer() {
        let app = open("proof-timer")
        wait(3)
        app.buttons["+10 min"].tap()
        wait(2.5)
        app.buttons["It’s ready now"].tap()
        wait(4)
    }

    /// 05: one block, undo it, then two blocks that reach the goal.
    @MainActor func testOneTapLog() {
        let app = open("one-tap-log")
        wait(2.5)
        app.buttons["Add 10 minutes"].tap()
        wait(2)
        app.buttons["Undo 10 minutes"].tap()
        wait(1.5)
        app.buttons["Add 20 minutes"].tap()
        wait(3.5)
    }

    /// Prints what a UI test can see on each entry, so that the tours below
    /// can be written against real labels.
    @MainActor func testDumpControls() {
        let screens = [
            ("sectioned-list", ""), ("explained-metric", ""), ("context-sheet", ""), ("context-sheet", "nearby"),
            ("long-read", "reading"), ("day-blocks", ""), ("service-status", ""), ("audio-take", ""),
            ("audio-take", "recording"), ("plain-draft", ""), ("flyer-canvas", ""), ("flyer-canvas", "selected"),
            ("picture-wall", ""), ("tide-scene", ""),
        ]
        for (pattern, variant) in screens {
            let app = XCUIApplication()
            app.launchArguments = ["-pattern", pattern, "-state", "loaded"] + (variant.isEmpty ? [] : ["-variant", variant])
            app.launch()
            wait(2.5)
            print("DUMP-BEGIN \(pattern) \(variant)")
            print(app.debugDescription)
            print("DUMP-END \(pattern) \(variant)")
            app.terminate()
        }
    }

    /// 04: choose an answer and save it.
    @MainActor func testGentleCheckin() {
        let app = open("gentle-checkin")
        wait(2.5)
        app.buttons["Steady"].tap()
        wait(1.5)
        app.buttons["Save check-in"].tap()
        wait(7)
    }
}
