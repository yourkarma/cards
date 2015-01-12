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

    func testCardsAreAddedAsSubviews() {
        let stack = CardStack()

        let view = UIView()
        stack.pushCard(view, animated: false, completion: nil)

        XCTAssertTrue(view.isDescendantOfView(stack), "Card should be a subview of the stack")
    }

    func testPushingCardsWithoutAnimationCallsCompletionBlock() {
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

    func testCardsAreRemovedAsSubviews()    {
        let stack = CardStack()

        let view = UIView()
        stack.pushCard(view)
        stack.popCard(animated: false, completion: nil)

        XCTAssertFalse(view.isDescendantOfView(stack), "Card should not be a subview of the stack")
    }

    func testLastAddedCardIsTopCard() {
        let stack = CardStack()
        let view = UIView()
        stack.pushCard(UIView())
        stack.pushCard(view)

        XCTAssertEqual(stack.topCard!, view, "The last added view should be the top card")
    }

    func testPopCardsWithoutAnimationCallsCompletionBlock() {
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
}
