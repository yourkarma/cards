// CardsPushAnimation.swift
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

class CardsPushAnimation: NSObject, CardAnimation {
    let cardStack: CardStack
    let cards: [UIView]
    let dynamicAnimator: UIDynamicAnimator
    let completion: CompletionBlock?

    var isRunning: Bool {
        return dynamicAnimator.behaviors.count > 0 || pendingBehaviors.count > 0
    }

    required init(cardStack: CardStack, cards: [UIView], completion: CompletionBlock?) {
        self.cardStack = cardStack
        self.cards = cards
        self.dynamicAnimator = UIDynamicAnimator(referenceView: cardStack)
        self.completion = completion
        super.init()

        self.dynamicAnimator.delegate = self
    }

    var pendingBehaviors: [UIDynamicBehavior] = []

    func delay(delay: Double, behaviors: [UIDynamicBehavior], onCard card: UIView) {
        pendingBehaviors += behaviors

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            for behavior in behaviors {
                if let index = find(self.pendingBehaviors, behavior) {
                    self.pendingBehaviors.removeAtIndex(index)

                    if card.superview == self.cardStack {
                        self.dynamicAnimator.addBehavior(behavior)
                    }
                }

            }
        }
    }

    func start() {
        assert(!isRunning, "Attempt to start a \(self) that is already running")

        for index in (0..<cards.count) {
            let card = cards[index]

            let snapToPoint = card.center
            card.center.y += self.cardStack.bounds.height

            let dynamicBehavior = UIDynamicItemBehavior(items: [card])
            dynamicBehavior.allowsRotation = false

            let snapBehavior = UISnapBehavior(item: card, snapToPoint: snapToPoint)
            snapBehavior.damping = 0.35
            delay(0.2 * Double(index), behaviors: [dynamicBehavior, snapBehavior], onCard: card)
        }
    }

    func stop() {
        println("stop")
        pendingBehaviors = []
        dynamicAnimator.removeAllBehaviors()
        completion?()
    }
}

extension CardsPushAnimation: UIDynamicAnimatorDelegate {
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        println("pause")
        if (pendingBehaviors.count <= 0) {
            stop()
        }
    }
}
