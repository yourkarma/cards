//
//  CardStackSnapShotTest.swift
//  Cards
//
//  Created by Klaas Pieter Annema on 15/01/15.
//  Copyright (c) 2015 Klaas Pieter Annema. All rights reserved.
//

import FBSnapshotTestCase
import Cards

class CardStackSnapShotTest: FBSnapshotTestCase {

    func snapshotVerifyView(view: UIView, identifier: String) {
        var error: NSError? = nil
        let comparisonSuccess = compareSnapshotOfView(view, referenceImagesDirectory: Constants.facebookReferenceImageDir(), identifier: identifier, error: &error)

        XCTAssertTrue(comparisonSuccess, "Snapshot comparison failed: \(error)")
        XCTAssertFalse(recordMode, "Test ran in record mode. Reference image is now saved. Disable record mode to perform an actual snapshot comparison!")
    }

    var cardStack: CardStack! = nil
    override func setUp() {
        super.setUp()
        cardStack = CardStack()
        let window = UIApplication.sharedApplication().keyWindow!
        cardStack.frame = window.bounds
        window.addSubview(cardStack)
    }

    func viewWithBackgroundColor(color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }

    func test_that_cards_become_visible_when_set_with_animation() {
        let cards = [viewWithBackgroundColor(UIColor.redColor()),
            viewWithBackgroundColor(UIColor.greenColor()),
            viewWithBackgroundColor(UIColor.blueColor())]

        let expectation = expectationWithDescription("Completion block")
        cardStack.setCards(cards, animated: true) {
            self.snapshotVerifyView(self.cardStack, identifier: "")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5.0, handler: { (error) in
            XCTAssertNil(error, "Completion block should have been called")
        })
    }

    func test_cards_become_visible_when_set_without_animation() {
        let cards = [viewWithBackgroundColor(UIColor.redColor()),
            viewWithBackgroundColor(UIColor.greenColor()),
            viewWithBackgroundColor(UIColor.blueColor())]

        let expectation = expectationWithDescription("Completion block")
        cardStack.setCards(cards, animated: false) {
            self.snapshotVerifyView(self.cardStack, identifier: "")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(0.0, handler: { (error) in
            XCTAssertNil(error, "Completion block should have been called")
        })
    }

    func test_cards_are_hidden_when_popped_with_animation() {
        let cards = [viewWithBackgroundColor(UIColor.redColor()),
            viewWithBackgroundColor(UIColor.greenColor()),
            viewWithBackgroundColor(UIColor.blueColor())]

        let expectation = expectationWithDescription("Completion block")
        cardStack.setCards(cards, animated: false) {
            self.cardStack.popCard(animated: true) {
                self.snapshotVerifyView(self.cardStack, identifier: "")
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(5.0, handler: { (error) in
            XCTAssertNil(error, "Completion block should have been called")
        })
    }

    func test_cards_are_hidden_when_popped_without_animation() {
        let cards = [viewWithBackgroundColor(UIColor.redColor()),
            viewWithBackgroundColor(UIColor.greenColor()),
            viewWithBackgroundColor(UIColor.blueColor())]

        let expectation = expectationWithDescription("Completion block")
        cardStack.setCards(cards, animated: false) {
            self.cardStack.popCard(animated: false) {
                self.snapshotVerifyView(self.cardStack, identifier: "")
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(0.0, handler: { (error) in
            XCTAssertNil(error, "Completion block should have been called")
        })
    }
}
