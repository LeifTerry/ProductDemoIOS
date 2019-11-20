//
//  DemoGridUITests.swift
//  DemoGridUITests
//
//  Created by Leif Terry on 11/18/19.
//  Copyright © 2019 Stella Zero. All rights reserved.
//

import XCTest

extension XCUIApplication {

    var isDisplayingList: Bool {
        return tables.cells["productListCell"].exists
    }

    var isDisplayingDetail: Bool {
        return otherElements["productDetailView"].exists
    }
}

class DemoGridUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {

        // put setup code here
        // called before the invocation of each test method in the class.
        app = XCUIApplication()

        // in UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test
        app.launch()

        // in UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run.
        // the setUp method is a good place to do this.
    }

    override func tearDown() {
        // put teardown code here.
        // called after the invocation of each test method in the class.
    }

    // MARK: - Tests

    func testListToDetailToList() {
        // from app start
        // 1) verify that list is displayed
        // 2) select a cell
        // 3) verify that detail view is displayed and list view is not
        // 4) select Back
        // 5) verify that list view is displayed and detail view is not

        // make sure we're displaying list
        XCTAssertTrue(app.isDisplayingList)

        // switch to detail view of first item in list
        app.tables.cells["productListCell"].tap()

        XCTAssertFalse(app.isDisplayingList)
        XCTAssertTrue(app.isDisplayingDetail)

        // tap the "Back" button
        app.buttons["Back"].tap()

        // Onboarding should no longer be displayed
        XCTAssertFalse(app.isDisplayingDetail)
        XCTAssertTrue(app.isDisplayingList)
    }
}
