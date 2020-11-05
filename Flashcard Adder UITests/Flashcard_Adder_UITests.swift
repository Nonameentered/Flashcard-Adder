//
//  Flashcard_Adder_UITests.swift
//  Flashcard Adder UITests
//
//  Created by Matthew Shu on 11/3/20.
//

import XCTest

class Flashcard_Adder_UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        let app = XCUIApplication()
        let element = app/*@START_MENU_TOKEN@*/.scrollViews.containing(.other, identifier:"Vertical scroll bar, 1 page")/*[[".scrollViews.containing(.other, identifier:\"Horizontal scroll bar, 1 page\")",".scrollViews.containing(.other, identifier:\"Vertical scroll bar, 1 page\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .other).element(boundBy: 0)
        let textView1 = element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .textView).element
        textView1.tap()
        textView1.typeText("What is the best way to create flashcards?")
        
        let scrollViewsQuery = app.scrollViews
        let textView2 = scrollViewsQuery.children(matching: .other).element(boundBy: 0).children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .textView).element
        textView2.tap()
        textView2.typeText("Flashcard Adder!")
        element.children(matching: .other).element(boundBy: 2).buttons["favorite"].tap()
        scrollViewsQuery.otherElements.staticTexts["Back"].tap()
        snapshot("0Home")
        
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery/*@START_MENU_TOKEN@*/.staticTexts["Type: Basic"]/*[[".buttons[\"Type: Basic\"].staticTexts[\"Type: Basic\"]",".staticTexts[\"Type: Basic\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("1NoteTypes")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
