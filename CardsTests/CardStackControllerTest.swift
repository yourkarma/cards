// CardStackControllerTest.Swift
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
    @IBOutlet weak var containerView: UIView!
    var didMoveToParentViewControllerArgument: UIViewController?

    override func willMoveToParentViewController(parent: UIViewController?) {
        willMoveToParentViewControllerArgument = parent
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        didMoveToParentViewControllerArgument = parent
    }
}

func tap<A>(object: A, block: (A) -> ()) -> A {
    block(object)
    return object
}

class CardStackControllerTest: XCTestCase {

    let stackViewController = tap(CardStackController()) {
        $0.view = CardStack()
    }

    override func setUp() {
        UIView.setAnimationsEnabled(false)
    }

    func test_push_view_controller_adds_view_controller_as_a_child_controller() {
        self.stackViewController.pushViewController(UIViewController(), animated: false, completion: nil)
        XCTAssertEqual(stackViewController.childViewControllers.count, 1,
            "View controllers should be added as child controllers")
    }

    func test_push_view_controller_adds_the_view_as_a_card() {
        let viewController = UIViewController()
        viewController.view = UIView()
        self.stackViewController.pushViewController(viewController)

        XCTAssertTrue(contains(self.stackViewController.cardStack!.cards, viewController.view), "Card stack should contain the view")
    }

    func test_push_view_controller_makes_itself_parent_of_the_view_controller() {
        let childController = ViewController()
        self.stackViewController.pushViewController(childController)
        self.stackViewController.pushViewController(childController)

        if (childController.didMoveToParentViewControllerArgument == nil) {
            XCTFail("didMoveToParentViewController should have been called")
            return
        }
        XCTAssertEqual(childController.didMoveToParentViewControllerArgument!, self.stackViewController)
    }

    func test_push_view_controller_adds_a_view_controller() {
        let childController = ViewController()
        self.stackViewController.pushViewController(childController)

        XCTAssertTrue(contains(self.stackViewController.viewControllers, childController), "View controller should have been added")
    }

    func test_pop_view_controller_removes_the_child_controller_relationship() {
        self.stackViewController.pushViewController(ViewController())
        self.stackViewController.popViewController()

        XCTAssertEqual(self.stackViewController.childViewControllers.count, 0,
            "View controllers should be removed as child controllers")
    }

    func test_pop_view_controller_removes_the_view_controller_from_its_parent() {
        let childController = ViewController()
        self.stackViewController.pushViewController(childController)
        self.stackViewController.popViewController(animated: false, completion: nil)

        XCTAssertNil(childController.willMoveToParentViewControllerArgument, "willMoveToParentViewController should have been called with nil argument")
    }

    func test_pop_view_controller_removes_the_view_controllers_view_as_a_card() {
        let childController = ViewController()
        let view = UIView()
        childController.view = view
        self.stackViewController.pushViewController(childController)
        self.stackViewController.popViewController()

        XCTAssertFalse(contains(self.stackViewController.cardStack!.cards, view))
    }

    func test_pop_view_controllers_removes_the_view_controller() {
        let childController = ViewController()
        self.stackViewController.pushViewController(childController)
        self.stackViewController.popViewController()
        XCTAssertFalse(contains(self.stackViewController.viewControllers, childController), "View controller should have been removed")
    }

    func test_can_set_multiple_view_controllers_at_once() {
        self.stackViewController.setViewControllers([ViewController(), ViewController()], animated: false, completion: nil)
        XCTAssert(self.stackViewController.childViewControllers.count == 2, "Two view controllers should have been added")
    }

    func test_set_view_controllers_adds_every_view_controllers_view_to_the_stack() {
        let viewController = UIViewController()
        let view = UIView()
        viewController.view = view

        let expectation = self.expectationWithDescription("Completion block called")

        self.stackViewController.setViewControllers([viewController], animated: false) {
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(0.0) { error in
            XCTAssertTrue(contains(self.stackViewController.cardStack!.cards, view), "View should have been added as a subview")
        }
    }

    func test_set_view_controllers_moves_each_view_controller_to_itself_as_parent() {
        let childController = ViewController()

        let expectation = self.expectationWithDescription("Completion block called")
        self.stackViewController.setViewControllers([childController], animated: false) {
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(0.0) { error in
            if (childController.didMoveToParentViewControllerArgument == nil) {
                XCTFail("didMoveToParentViewController should have been called")
                return
            }
            XCTAssertEqual(childController.didMoveToParentViewControllerArgument!, self.stackViewController)
        }
    }

    func test_set_view_controllers_adds_each_view_controller() {
        let childControllers = [ViewController(), ViewController()]
        self.stackViewController.setViewControllers(childControllers, animated: false, completion: nil)
        XCTAssertEqual(childControllers, self.stackViewController.viewControllers, "View controllers should have been added")
    }

    func test_sets_itself_as_the_card_stack_delegate() {
        XCTAssertTrue(self.stackViewController.cardStack?.delegate === self.stackViewController, "It should be the card stack's delegate")
    }

    func test_moves_the_view_controller_when_the_view_moves_in_the_stack() {
        let viewController1 = ViewController()
        let viewController2 = ViewController()
        self.stackViewController.setViewControllers([viewController1, viewController2], animated:false, completion: nil)

        self.stackViewController.cardStack?.delegate?.cardStackDidMoveCardToBack?(self.stackViewController.cardStack!)
        XCTAssertEqual([viewController2, viewController1], self.stackViewController.viewControllers, "View controllers should have moved")
    }
}

