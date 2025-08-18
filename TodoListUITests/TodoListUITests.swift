//
//  TodoListUITests.swift
//  TodoListUITests
//
//  Created by Dmitrii Nikulin on 8/17/25.
//

import XCTest

final class TodoListUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        // Add new task via plus button then cancel (detail auto-saves only if dirty)
        let addButton = app.buttons["plus"]
        if addButton.exists { addButton.tap() }
        // Enter title
        let titleField = app.textFields["detail_title_field"]
        if titleField.waitForExistence(timeout: 2) {
            titleField.tap()
            titleField.typeText("UITest Task")
            app.navigationBars.buttons.element(boundBy: 0).tap()  // back
        }
        // Verify task appears
        XCTAssertTrue(
            app.staticTexts["UITest Task"].waitForExistence(timeout: 2)
        )
        // Open then close detail again via back button
        let cell = app.staticTexts["UITest Task"].firstMatch
        if cell.exists {
            cell.tap()
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        // Search for task
        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 2) {
            searchField.tap()
            searchField.typeText("UITest Task")
        }
        XCTAssertTrue(app.staticTexts["UITest Task"].exists)
        // Delete task via context menu (long press not easily in UI tests; swipe instead)
        let tablesQuery = app.tables
        if tablesQuery.cells.firstMatch.waitForExistence(timeout: 2) {
            let first = tablesQuery.cells.firstMatch
            first.swipeLeft()
            if first.buttons["Delete"].exists { first.buttons["Delete"].tap() }
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
