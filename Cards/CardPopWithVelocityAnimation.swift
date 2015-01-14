//
// CardPopWithVelocityAnimation.swift

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

class CardPopWithVelocityAnimation: NSObject, CardAnimation, UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate {
    let cardStack: CardStack
    let cards: [UIView]
    let completion: CompletionBlock?
    let dynamicAnimator: UIDynamicAnimator

    var isRunning: Bool {
        return self.dynamicAnimator.behaviors.count > 0
    }
    var velocity: CGPoint = CGPoint.zeroPoint

    required init(cardStack: CardStack, cards: [UIView], completion: CompletionBlock?) {
        self.cardStack = cardStack
        self.cards = cards
        self.completion = completion
        self.dynamicAnimator = UIDynamicAnimator(referenceView: cardStack)
        super.init()
        self.dynamicAnimator.delegate = self
    }

    func start() {
        assert(!isRunning, "Attempt to start a \(self) that is already running")

        let card = cards.last!

        let dynamicBehavior = UIDynamicItemBehavior(items: [card])
        dynamicBehavior.allowsRotation = false
        dynamicBehavior.addLinearVelocity(CGPoint(x: 0.0, y: velocity.y), forItem: card)
        dynamicAnimator.addBehavior(dynamicBehavior)

        let bottomCollisionBehavior = UICollisionBehavior(items: [card])
        bottomCollisionBehavior.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x: 0.0, y: cardStack.bounds.maxY + card.frame.height), toPoint: CGPoint(x: cardStack.bounds.maxX, y: cardStack.bounds.maxY + card.frame.height))
        bottomCollisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(bottomCollisionBehavior)
    }

    func stop() {
        dynamicAnimator.removeAllBehaviors()
    }

    func finish() {
        completion?()
    }

    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        dynamicAnimator.removeAllBehaviors()
    }

    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        finish()
    }

}
