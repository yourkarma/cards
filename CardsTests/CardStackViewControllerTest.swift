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

        let childControllers = [UIViewController()]
        stackViewController.viewControllers = childControllers

        XCTAssertEqual(childControllers.count, stackViewController.childViewControllers.count,
            "View controllers should be added as child controllers")
    }

    func testViewControllerViewIsAddedAsSubview() {
        let stackViewController = CardStackViewController()

        let viewController = UIViewController()
        let view = UIView()
        viewController.view = view

        stackViewController.viewControllers = [viewController]

        XCTAssertTrue(view.isDescendantOfView(stackViewController.view), "View controller's view should be added as a subview of the stack")
    }

    func testViewControllerDidMoveToParentViewControllerIsCalled() {
        let stackViewController = CardStackViewController()

        let childController = ViewController()
        stackViewController.viewControllers = [childController]

        if (childController.didMoveToParentViewControllerArgument == nil) {
            XCTFail("didMoveToParentViewController should have been called")
            return
        }
        XCTAssertEqual(childController.didMoveToParentViewControllerArgument!, stackViewController)
    }

    func testChildViewControllersAreRemovedWhenSettingNewChildren() {
        let stackViewController = CardStackViewController()

        stackViewController.viewControllers = [UIViewController(), UIViewController()]
        let childControllers = [UIViewController()]
        stackViewController.viewControllers = childControllers;

        XCTAssertEqual(childControllers.count, stackViewController.childViewControllers.count,
            "View controllers should be added as child controllers")
    }

    func testWillMoveToParentViewControllerIsCalledWhenSettingNewChildren() {
        let stackViewController = CardStackViewController()

        let childController = ViewController()
        stackViewController.viewControllers = [childController]
        stackViewController.viewControllers = [UIViewController()]

        XCTAssertNil(childController.willMoveToParentViewControllerArgument, "willMoveToParentViewController should have been called with nil argument")
    }

    func testViewControllerViewIsRemovedWhenSettingNewChildren() {
        let stackViewController = CardStackViewController()

        let childController = ViewController()
        let view = UIView()
        childController.view = view
        stackViewController.viewControllers = [childController]
        stackViewController.viewControllers = [UIViewController()]

        XCTAssertFalse(view.isDescendantOfView(stackViewController.view), "View controller's view should be removed as a subview of the stack")
    }
}

