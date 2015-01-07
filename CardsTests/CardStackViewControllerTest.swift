// CardStackViewControllerTest.Swift
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
// THE SOFTWARE.


import UIKit
import XCTest
import Cards

class ViewController: UIViewController {
    var willMoveToParentViewControllerArgument: UIViewController?
    var didMoveToParentViewControllerArgument: UIViewController?

    override func willMoveToParentViewController(parent: UIViewController?) {
        willMoveToParentViewControllerArgument = parent
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        didMoveToParentViewControllerArgument = parent
    }
}

class CardStackViewControllerTest: XCTestCase {

    func testViewControllersAreAddedAsChildControllers() {
        let stackViewController = CardStackViewController()

        stackViewController.addViewController(UIViewController())

        XCTAssertEqual(stackViewController.childViewControllers.count, 1,
            "View controllers should be added as child controllers")
    }

    func testViewControllerViewIsAddedAsACard() {
        let stackViewController = CardStackViewController()

        let viewController = UIViewController()
        viewController.view = UIView()
        stackViewController.addViewController(viewController)

        XCTAssertTrue(contains(stackViewController.cardStack.cards, viewController.view), "Card stack should contain the view")
    }

    func testViewControllerDidMoveToParentViewControllerIsCalled() {
        let stackViewController = CardStackViewController()

        let childController = ViewController()
        stackViewController.addViewController(childController)
        stackViewController.addViewController(childController)

        if (childController.didMoveToParentViewControllerArgument == nil) {
            XCTFail("didMoveToParentViewController should have been called")
            return
        }
        XCTAssertEqual(childController.didMoveToParentViewControllerArgument!, stackViewController)
    }

    func testRemovingViewControllersRemovesTheChildControllerRelationship() {
        let stackViewController = CardStackViewController()

        stackViewController.removeViewController(UIViewController())

        XCTAssertEqual(stackViewController.childViewControllers.count, 0,
            "View controllers should be removed as child controllers")
    }

    func testWillMoveToParentViewControllerIsCalledWhenViewControllersAreRemoved() {
        let stackViewController = CardStackViewController()

        let childController = ViewController()
        stackViewController.addViewController(childController)
        stackViewController.removeViewController(childController)

        XCTAssertNil(childController.willMoveToParentViewControllerArgument, "willMoveToParentViewController should have been called with nil argument")
    }

    func testViewControllerCardIsRemovedWhenRemovingTheViewController() {
        let stackViewController = CardStackViewController()

        let childController = ViewController()
        let view = UIView()
        childController.view = view
        stackViewController.addViewController(childController)
        stackViewController.removeViewController(childController)

        XCTAssertFalse(contains(stackViewController.cardStack.cards, view))
    }
}

