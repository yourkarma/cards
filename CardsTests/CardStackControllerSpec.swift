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

import Quick
import Nimble
import Cards

class ViewController: UIViewController {
    override func loadView() {
        self.view = UIView()
    }

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

class CardStackControllerSpec: QuickSpec {
    var viewController: CardStackController!

    override func spec() {
        beforeEach {
            self.viewController = CardStackController()
            self.viewController.view = CardStack()
        }

        describe("#pushViewController") {
            it("adds the view controller as a child controller") {
                self.viewController.pushViewController(UIViewController())
                expect(self.viewController.childViewControllers.count) == 1
            }

            it("adds the view controller's view as a card") {
                let childViewController = ViewController()
                self.viewController.pushViewController(childViewController)

                expect(self.viewController.cardStack!.cards).to(contain(childViewController.view))
            }

            it("makes itself the parent of the child") {
                let childController = ViewController()
                self.viewController.pushViewController(childController)

                expect(childController.parentViewController) == self.viewController
            }
        }

        describe("#popViewController") {
            it("removes the child view controller as a child") {
                self.viewController.pushViewController(ViewController())
                self.viewController.popViewController()

                expect(self.viewController.childViewControllers.count) == 0
            }

            it("removes itself as the child's parent") {
                let childViewController = ViewController()
                self.viewController.pushViewController(childViewController)
                self.viewController.popViewController()

                expect(childViewController.parentViewController).to(beNil())
            }

            it("removes the view controller's view as a card") {
                let childViewController = ViewController()
                self.viewController.pushViewController(childViewController)
                self.viewController.popViewController()

                expect(self.viewController.cardStack!.cards).toNot(contain(childViewController.view))
            }
        }

        describe("#setViewControllers") {
            it("adds all the view controllers as child controllers") {
                self.viewController.setViewControllers([ViewController(), ViewController()], animated: false, completion: nil)
                expect(self.viewController.childViewControllers.count) == 2
            }

            it("adds every view controller's view as a card") {
                let childViewController = ViewController()
                self.viewController.setViewControllers([childViewController], animated: false, completion: nil)

                expect(self.viewController.cardStack!.cards).toEventually(contain(childViewController.view))
            }

            it("sets itself as parent of each view controller") {
                let childViewController = ViewController()
                self.viewController.setViewControllers([childViewController], animated: false, completion: nil)

                expect(childViewController.parentViewController).toEventually(equal(self.viewController))
            }
        }

        describe("cardStack delegate") {
            it("sets itself as the CardStack delegate") {
                self.viewController.cardStack?.delegate === self.viewController
            }

            it("moves the view controllers when the view moves in the stack") {
                let childViewController1 = ViewController()
                let childViewController2 = ViewController()
                self.viewController.setViewControllers([childViewController1, childViewController2], animated: false, completion: nil)

                self.viewController.cardStack?.delegate?.cardStackDidMoveCardToBack?(self.viewController.cardStack!)
                expect([childViewController2, childViewController1] == self.viewController.viewControllers)
            }
        }
    }
}
