//
//  TodoListUITests.swift
//  TodoListUITests
//
//  Created by Dmitrii Nikulin on 8/17/25.
//

import XCTest

final class TodoListUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launchArguments += ["UITEST_DISABLE_SPEECH", "UITEST_MODE"]
        app.launch()

        // Use page objects style (minimal inline version) for consistency
        let addButton = app.buttons["add_task_button"]
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 5),
            "Add button not found"
        )
        addButton.tap()

        // Enter title on detail screen
        let titleField = app.textFields["detail_title_field"]
        XCTAssertTrue(
            titleField.waitForExistence(timeout: 5),
            "Title field not present"
        )
        titleField.tap()
        titleField.typeText("UITest Task")

        // Tap explicit back button by accessibility id to persist
        let backButton = app.buttons["detail_back_button"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5),
            "Back button missing"
        )
        backButton.tap()

        // Open then close detail again
        let listCell = app.staticTexts["UITest Task"].firstMatch
        if listCell.exists {
            listCell.tap()
            backButton.tap()
        }

        // Search for task
        let searchField = app.textFields["search_field"]
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 5),
            "Search field not found"
        )
        searchField.tap()
        searchField.typeText("UITest Task")
        XCTAssertTrue(
            app.staticTexts["UITest Task"].waitForExistence(timeout: 3)
        )

        // Delete task via swipe
        let row = app.tables.cells.containing(
            .staticText,
            identifier: "UITest Task"
        ).firstMatch
        if row.waitForExistence(timeout: 5) {
            row.swipeLeft()
            let deleteButton = row.buttons["Delete"]
            if deleteButton.waitForExistence(timeout: 3) { deleteButton.tap() }
        }

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "EndState"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testCreateSearchAndDeleteFlow() {
        let app = XCUIApplication()
        app.launchArguments += ["UITEST_DISABLE_SPEECH", "UITEST_MODE"]
        app.launch()
        let list = TodoListPage(app: app)
        XCTContext.runActivity(named: "Add new task") { _ in
            XCTAssertTrue(list.addButton.waitForExistence(timeout: 5))
            list.addButton.tap()
            let detail = TodoDetailPage(app: app)
            XCTAssertTrue(detail.titleField.waitForExistence(timeout: 5))
            detail.titleField.tap()
            detail.titleField.typeText("Flow Test")
            detail.backButton.tap()
        }
        XCTContext.runActivity(named: "Search for task") { _ in
            let searchField = app.textFields["search_field"]
            XCTAssertTrue(searchField.waitForExistence(timeout: 5))
            searchField.tap()
            searchField.typeText("Flow Test")
            XCTAssertTrue(
                app.staticTexts["Flow Test"].firstMatch.waitForExistence(
                    timeout: 5
                )
            )
        }
        XCTContext.runActivity(named: "Delete task") { _ in
            let list = app.collectionViews["todo_list"]
            let row = list.cells.containing(
                .staticText,
                identifier: "Flow Test"
            ).firstMatch
            XCTAssertTrue(
                row.waitForExistence(timeout: 5),
                "Row not found for deletion"
            )
            row.swipeLeft()
            let deleteButton = app.buttons.matching(
                NSPredicate(
                    format:
                        "label CONTAINS[c] 'Delete' OR label CONTAINS[c] 'Удалить' OR label CONTAINS[c] 'Eliminar'"
                )
            ).firstMatch
            XCTAssertTrue(
                deleteButton.waitForExistence(timeout: 5),
                "Delete button missing after swipe"
            )
            deleteButton.tap()
            // Ensure it disappears
            XCTAssertFalse(
                app.staticTexts["Flow Test"].waitForExistence(timeout: 3),
                "Task still visible after delete"
            )
            addScreenshot(name: "AfterDelete", app: app)
        }
    }

    // MARK: - NEW: delete via long-press (context menu)
    @MainActor
    func testDeleteViaLongPressContextMenu() {
        let app = XCUIApplication()
        app.launchArguments += ["UITEST_DISABLE_SPEECH", "UITEST_MODE"]
        app.launch()

        // 1) Add a task we can delete
        let list = TodoListPage(app: app)
        XCTContext.runActivity(named: "Add task for long-press deletion") { _ in
            XCTAssertTrue(list.addButton.waitForExistence(timeout: 5))
            list.addButton.tap()

            let detail = TodoDetailPage(app: app)
            XCTAssertTrue(detail.titleField.waitForExistence(timeout: 5))
            detail.titleField.tap()
            detail.titleField.typeText("LongPress Test")
            detail.backButton.tap()
        }

        // 2) Scroll to end, then verify it shows up
        XCTContext.runActivity(
            named: "Scroll to end and verify appears in list"
        ) { _ in
            let collection = app.collectionViews["todo_list"]
            XCTAssertTrue(
                collection.waitForExistence(timeout: 5),
                "Todo list not found"
            )

            // Scroll to the very bottom first
            collection.scrollToBottom(maxSwipes: 15)

            // Now check if the task is present (it may be at the end)
            let target = app.staticTexts["LongPress Test"]
            // Optional: if you want to be extra sure it's visible on screen:
            collection.scrollElementIntoView(target, maxSwipes: 8)

            XCTAssertTrue(
                target.exists,
                "Expected to find 'LongPress Test' after scrolling to end"
            )
            addScreenshot(name: "LP_AfterAdd", app: app)
        }

        // 3) Long-press row to open context menu, then tap Delete
        XCTContext.runActivity(named: "Long-press and delete from context menu")
        { _ in
            // Using the same list identifier you already rely on
            let collection = app.collectionViews["todo_list"]
            XCTAssertTrue(
                collection.waitForExistence(timeout: 5),
                "Todo list not found"
            )

            let row = collection.cells.containing(
                .staticText,
                identifier: "LongPress Test"
            ).firstMatch
            XCTAssertTrue(
                row.waitForExistence(timeout: 5),
                "Row not found for long-press"
            )

            // Long-press to reveal the context menu (preview + actions)
            row.press(forDuration: 1.0)

            // Try common cases for SwiftUI context menus across iOS versions
            let deletePredicate = NSPredicate(
                format:
                    "label CONTAINS[c] 'Delete' OR label CONTAINS[c] 'Удалить' OR label CONTAINS[c] 'Eliminar'"
            )

            // Buttons often work on iOS 16/17; menuItems is a fallback on some locales/builds
            let deleteButton = app.buttons.matching(deletePredicate).firstMatch
            let deleteMenuItem = app.menuItems.matching(deletePredicate)
                .firstMatch

            // Wait briefly for either to appear
            let appeared =
                deleteButton.waitForExistence(timeout: 3)
                || deleteMenuItem.waitForExistence(timeout: 3)
            XCTAssertTrue(
                appeared,
                "Context menu didn't appear or Delete action not found"
            )

            if deleteButton.exists {
                deleteButton.tap()
            } else {
                deleteMenuItem.tap()
            }

            // 4) Ensure it disappears
            XCTAssertFalse(
                app.staticTexts["LongPress Test"].waitForExistence(timeout: 3),
                "Task still visible after context menu delete"
            )
            addScreenshot(name: "LP_AfterContextDelete", app: app)
        }
    }

    // MARK: - create empty, go back, ensure nothing saved (with population wait)
    @MainActor
    func testCreateEmptyThenBack_NoSave() {
        let app = XCUIApplication()
        app.launchArguments += ["UITEST_DISABLE_SPEECH", "UITEST_MODE"]
        app.launch()

        let list = TodoListPage(app: app)

        XCTContext.runActivity(
            named: "Wait for list to populate & capture baseline"
        ) { _ in
            let collection = app.collectionViews["todo_list"]
            XCTAssertTrue(
                collection.waitForExistence(timeout: 5),
                "Todo list not found"
            )

            // 1) wait for loading overlay (if any) to disappear
            waitUntilLoadingStops(app: app, timeout: 10)

            // 2) wait until the list has > 0 cells (backend finished fetching)
            waitUntilListHasAtLeastOneCell(collection, timeout: 10)

            // now it’s safe to capture the baseline count
            let initialCount = collection.cells.count

            XCTContext.runActivity(
                named: "Open Add, then go back without typing"
            ) { _ in
                XCTAssertTrue(list.addButton.waitForExistence(timeout: 5))
                list.addButton.tap()

                let detail = TodoDetailPage(app: app)
                XCTAssertTrue(detail.titleField.waitForExistence(timeout: 5))
                // Intentionally DO NOT type anything
                detail.backButton.tap()
            }

            XCTContext.runActivity(named: "Verify no new item was saved") { _ in
                // allow the list to settle again (e.g., refresh on return)
                waitUntilLoadingStops(app: app, timeout: 5)
                addScreenshot(name: "Empty_Create_Back", app: app)

                XCTAssertEqual(
                    collection.cells.count,
                    initialCount,
                    "A new empty task was incorrectly saved"
                )
            }
        }
    }
}

// MARK: - Helpers
extension TodoListUITests {
    fileprivate func addScreenshot(name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Waits until the loading overlay (A11yId.loadingIndicator) is gone, or times out.
    fileprivate func waitUntilLoadingStops(
        app: XCUIApplication,
        timeout: TimeInterval
    ) {
        let indicator = app.otherElements["loading_indicator"]
        if indicator.exists {
            let gone = indicator.waitForExistence(timeout: 0) == false
            if !gone {
                let start = Date()
                while indicator.exists
                    && Date().timeIntervalSince(start) < timeout
                {
                    RunLoop.current.run(until: Date().addingTimeInterval(0.1))
                }
            }
        }
    }

    /// Polls until the collection view has at least one cell, or times out.
    fileprivate func waitUntilListHasAtLeastOneCell(
        _ collection: XCUIElement,
        timeout: TimeInterval
    ) {
        let start = Date()
        while collection.cells.count == 0
            && Date().timeIntervalSince(start) < timeout
        {
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        // if it’s still zero after timeout, test can still proceed (maybe a truly empty account),
        // but per your scenario we do want to wait for > 0 when backend loads.
    }
}

extension XCUIElement {

    /// Repeatedly swipes up until the list stops changing or maxSwipes is reached.
    func scrollToBottom(maxSwipes: Int = 12) {
        guard self.exists else { return }
        var lastVisibleSnapshotCount = self.cells.matching(
            .cell,
            identifier: nil
        ).count
        var stagnationCount = 0

        for _ in 0..<maxSwipes {
            swipeUp()
            // Give the UI a tick to settle
            _ = self.waitForExistence(timeout: 0.2)

            let currentCount = self.cells.matching(.cell, identifier: nil).count
            if currentCount == lastVisibleSnapshotCount {
                stagnationCount += 1
            } else {
                stagnationCount = 0
                lastVisibleSnapshotCount = currentCount
            }
            // If two consecutive swipes didn’t change anything, assume we're at the bottom.
            if stagnationCount >= 2 { break }
        }
    }

    /// Scrolls until the element is hittable or maxSwipes is reached.
    func scrollElementIntoView(
        _ element: XCUIElement,
        maxSwipes: Int = 10,
        directionUpFirst: Bool = true
    ) {
        guard self.exists else { return }
        if element.isHittable { return }

        // Try the likely direction first
        var swipes = 0
        while !element.isHittable && swipes < maxSwipes {
            directionUpFirst ? swipeUp() : swipeDown()
            swipes += 1
        }

        // If still not visible, try the opposite direction
        if !element.isHittable {
            var backSwipes = 0
            while !element.isHittable && backSwipes < maxSwipes {
                directionUpFirst ? swipeDown() : swipeUp()
                backSwipes += 1
            }
        }
    }
}
