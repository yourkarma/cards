// CardStackTest.Swift
//
// Copyright (c) 2015 Karma Mobility Inc. (https://yourkarma.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.Kit

import XCTest
import Cards

class CardStackTest: XCTestCase {

    override func setUp() {
        UIView.setAnimationsEnabled(false)
    }

    func test_cards_are_added_as_subviews() {
        let stack = CardStack()

        let view = UIView()
        stack.pushCard(view, animated: false, completion: nil)

        XCTAssertTrue(view.isDescendantOfView(stack), "Card should be a subview of the stack")
    }

    func test_pushing_cards_without_animation_calls_completion_block() {
        let stack = CardStack()
        let view = UIView()

        let expectation = expectationWithDescription("Completion block")
        stack.pushCard(view, animated: false) {
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(0.0) { error in
            XCTAssertNil(error, "Completion block should have been called")
        }
    }

    func test_cards_are_removed_as_subviews()    {
        let stack = CardStack()

        let view = UIView()
        stack.pushCard(view)
        stack.popCard(animated: false, completion: nil)

        XCTAssertFalse(view.isDescendantOfView(stack), "Card should not be a subview of the stack")
    }

    func test_last_added_card_is_top_card() {
        let stack = CardStack()
        let view = UIView()
        stack.pushCard(UIView())
        stack.pushCard(view)

        XCTAssertEqual(stack.topCard!, view, "The last added view should be the top card")
    }

    func test_pop_cards_without_animation_calls_completion_block() {
        let stack = CardStack()

        let expectation = expectationWithDescription("Completion block")
        stack.pushCard(UIView())
        stack.popCard(animated: false) {
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(0.0) { error in
            XCTAssertNil(error, "Completion block should have been called")
        }
    }

    func test_multiple_cards_can_bet_set_simultanously() {
        let stack = CardStack()

        let view = UIView()

        let expectation = self.expectationWithDescription("Completion block called")
        stack.setCards([view], animated: false) {
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(0.0) { error in
            XCTAssertTrue(view.isDescendantOfView(stack), "Card should have been added as a subview")
        }
    }

    func test_old_cards_are_removed_when_setting_new() {
        let stack = CardStack()

        let view = UIView()
        stack.setCards([view], animated: false, completion: nil)
        stack.setCards([], animated: false, completion: nil)

        XCTAssertFalse(view.isDescendantOfView(stack), "Card should have been removed as a subview")
    }

    func test_setting_multiple_cards_without_animation_triggers_completion_block() {
        let stack = CardStack()
        let expectation = expectationWithDescription("Completion block")

        stack.setCards([UIView()], animated: false) {
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(0.0) { error in
            XCTAssertNil(error, "Completion block should have been called")
        }
    }
}
