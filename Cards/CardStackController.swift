// CardStackController.Swift
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

public class CardStackController: UIViewController {

    public var cardStack: CardStack? {
        return self.view as? CardStack
    }

    public override var view: UIView! {
        willSet {
            if let view = newValue as? CardStack {
                view.delegate = self
            } else {
                assert(false, "Attempt to set the view of a CardStackController to something that isn't a CardStack")
            }
        }
    }

    public var viewControllers: [UIViewController] = []

    public func pushViewController(viewController: UIViewController) {
        self.pushViewController(viewController, animated: false, completion: nil)
    }

    public func pushViewController(viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        viewControllers.append(viewController)

        self.addChildViewController(viewController)
        self.cardStack?.pushCard(viewController.view, animated: animated) {
            viewController.didMoveToParentViewController(self)
            completion?()
        }
    }

    public func popViewController() {
        popViewController(animated: false, completion: nil)
    }

    public func popViewController(#animated: Bool, completion: (() -> Void)?) {
        if let viewController = self.viewControllers.last {
            viewControllers.removeLast()

            viewController.willMoveToParentViewController(nil)
            self.cardStack?.popCard(animated: animated) {
                viewController.removeFromParentViewController()
                completion?()
            }
        }
    }

    private func _setViewControllers(viewControllers: [UIViewController], animated: Bool, completion: (() -> Void)?) {
        self.viewControllers = viewControllers

        viewControllers.map { self.addChildViewController($0) }
        cardStack?.setCards(viewControllers.map { $0.view }, animated: animated) {
            viewControllers.map { $0.didMoveToParentViewController(self) }
            completion?()
        }
    }

    private func additions<T: Equatable>(a: [T], _ b: [T]) -> [T] {
        return b.filter { !contains(a, $0) }
    }

    private func removals<T: Equatable>(a: [T], _ b: [T]) -> [T] {
        return a.filter { !contains(b, $0) }
    }

    private func swaps<T: Equatable>(a: [T], _ b: [T]) -> [T] {
        let additions = self.additions(a, b).count
        let removals = self.removals(a, b).count

        return a.filter {
            if let currentIndex = find(a, $0) {
                if let newIndex = find(b, $0) {
                    if currentIndex != newIndex {
                        let numberOfIndexesMoved = abs(newIndex - currentIndex)
                        return numberOfIndexesMoved != additions && numberOfIndexesMoved != removals
                    }
                }
            }
            return false
        }
    }

    public func setViewControllers(viewControllers: [UIViewController], animated: Bool, completion: (() -> Void)?) {
        let toAdd = viewControllers.filter { !contains(self.viewControllers, $0) }
        let toRemove = self.viewControllers.filter { !contains(viewControllers, $0) }
        let toSwap = swaps(self.viewControllers, viewControllers)

        if self.viewControllers.count <= 0 || toSwap.count > 0 {
            self._setViewControllers(viewControllers, animated: animated, completion: completion)
        } else {
            self.viewControllers = viewControllers

            let group = dispatch_group_create()

            let cardsToAdd: [UIView] = toAdd.map { $0.view }
            let indexes = toAdd.map { find(viewControllers, $0) }.filter{ $0 != nil }.map { $0! }
            if cardsToAdd.count > 0 {
                dispatch_group_enter(group)
                self.cardStack?.insertCards(cardsToAdd, atIndexes:indexes, animated: true) {
                    dispatch_group_leave(group)
                }
            }

            let cardsToRemove: [UIView] = toRemove.map { $0.view }
            if cardsToRemove.count > 0 {
                dispatch_group_enter(group)
                self.cardStack?.removeCards(cardsToRemove, animated: true) {
                    dispatch_group_leave(group)
                }
            }

            dispatch_group_notify(group, dispatch_get_main_queue()) {
                completion?()
                return // Compiler bug.
            }
        }
    }
}

extension CardStackController: CardStackDelegate {
    public func cardStackDidMoveCardToBack(cardStack: CardStack) {
        let viewController = self.viewControllers.removeLast()
        self.viewControllers.insert(viewController, atIndex: 0)
    }
}