// CardStackControllerSpec.swift
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

import Quick
import Nimble
import Cards

private class FakeViewController: UIViewController {
    fileprivate override func loadView() {
        self.view = UIView()
    }

    var willMoveToParentViewController: UIViewController? = nil
    fileprivate override func willMove(toParentViewController parent: UIViewController?) {
        self.willMoveToParentViewController = parent
    }

    var didMoveToParentViewController: UIViewController? = nil
    fileprivate override func didMove(toParentViewController parent: UIViewController?) {
        self.didMoveToParentViewController = parent
    }
}

class CardStackControllerSpec: QuickSpec {
    var viewController: CardStackController! = nil

    override func spec() {
        beforeEach {
            self.viewController = CardStackController(rootViewController: FakeViewController())
            self.viewController.view = UIView()
        }

        it("extends UIViewController with the ability to find the nearest CardStackController") {
            let childViewController = FakeViewController()
            let grandChildViewController = FakeViewController()

            childViewController.addChildViewController(grandChildViewController)
            grandChildViewController.didMove(toParentViewController: childViewController)

            self.viewController.pushViewController(childViewController, animated: false)

            expect(grandChildViewController.cardStackController) == self.viewController
        }

        describe("#pushViewController") {
            it("adds the view controller as a child") {
                let childViewController = FakeViewController()
                self.viewController.pushViewController(childViewController, animated: false)
                expect(self.viewController.childViewControllers).to(contain(childViewController))
            }

            it("adds the view as a subview") {
                let childViewController = FakeViewController()
                self.viewController.pushViewController(childViewController, animated: false)
                expect(childViewController.view.isDescendant(of: self.viewController.view)) == true
            }

            it("notifies the child that it was moved to a parent") {
                let childViewController = FakeViewController()
                self.viewController.pushViewController(childViewController, animated: false)
                expect(childViewController.didMoveToParentViewController) == self.viewController
            }

            it("calls the completion block") {
                waitUntil { done in
                    let childViewController = FakeViewController()
                    self.viewController.pushViewController(childViewController, animated: false) { _ in
                        done()
                    }
                }
            }

            it("is the child's card stack controller") {
                let childViewController = FakeViewController()
                self.viewController.pushViewController(childViewController, animated: false)
                expect(childViewController.cardStackController) == self.viewController
            }
        }

        describe("#popViewController") {
            it("removes the view controller as a child") {
                let childViewController = FakeViewController()
                self.viewController.pushViewController(childViewController, animated: false)
                self.viewController.popViewController(false)
                expect(self.viewController.childViewControllers).toNot(contain(childViewController))
            }

            it("adds the view as a subview") {
                let childViewController = FakeViewController()
                self.viewController.pushViewController(childViewController, animated: false)
                self.viewController.popViewController(false)
                expect(childViewController.view.isDescendant(of: self.viewController.view)) == false
            }

            it("notifies the child that is being removed as a child") {
                let childViewController = FakeViewController()
                self.viewController.pushViewController(childViewController, animated: false)
                self.viewController.popViewController(false)
                expect(childViewController.willMoveToParentViewController).to(beNil())
            }

            it("calls the completion block") {
                waitUntil { done in
                    let childViewController = FakeViewController()
                    self.viewController.pushViewController(childViewController, animated: false)
                    self.viewController.popViewController(false) {
                        done()
                    }
                }
            }

            it("is no longer the child's card stack controller") {
                let childViewController = FakeViewController()
                self.viewController.pushViewController(childViewController, animated: false)
                self.viewController.popViewController(false)
                expect(childViewController.cardStackController).to(beNil())
            }
        }
    }
}
