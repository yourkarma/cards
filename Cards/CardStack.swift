// CardStack.swift
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

public class CardStack: UIView, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {
    private var _cards: [UIView] = []
    public var cards: [UIView] {
        return _cards
    }

    var animator: UIDynamicAnimator!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var startY: CGFloat!

    override public func willMoveToSuperview(newSuperview: UIView?) {
        animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        addGestureRecognizer(panGestureRecognizer)
    }

    func handlePan(pan: UIPanGestureRecognizer) {
        if let card = topCard {
            if pan.state == UIGestureRecognizerState.Began {
                animator.removeAllBehaviors()
                startY  = card.frame.minY

            } else if pan.state == UIGestureRecognizerState.Changed {

                let translation: CGPoint = pan.translationInView(self)
                let frame = card.frame
                card.frame = CGRect(x: frame.origin.x, y: startY! + translation.y, width: frame.size.width, height: frame.size.height)

            } else if pan.state == UIGestureRecognizerState.Ended {

                let velocity = pan.velocityInView(self)
                if velocity.y > 1500.0 {
                    let dynamicBehavior = UIDynamicItemBehavior(items: [card])
                    dynamicBehavior.allowsRotation = false
                    dynamicBehavior.addLinearVelocity(CGPoint(x: 0.0, y: velocity.y), forItem: card)
                    animator.addBehavior(dynamicBehavior)

                    let topCollisionBehavior = UICollisionBehavior(items: [card])
                    topCollisionBehavior.addBoundaryWithIdentifier("top", fromPoint: CGPoint(x: 0.0, y: 0.0), toPoint: CGPoint(x: bounds.maxX, y: 0.0))
                    animator.addBehavior(topCollisionBehavior)

                    let bottomCollisionBehavior = UICollisionBehavior(items: [card])
                    bottomCollisionBehavior.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x: 0.0, y: bounds.maxY + card.frame.height), toPoint: CGPoint(x: bounds.maxX, y: bounds.maxY + card.frame.height))
                    bottomCollisionBehavior.collisionDelegate = self
                    animator.addBehavior(bottomCollisionBehavior)

                } else {

                    let dynamicBehavior = UIDynamicItemBehavior(items: [card])
                    dynamicBehavior.allowsRotation = false
                    animator.addBehavior(dynamicBehavior)

                    let snapBehavior = UISnapBehavior(item: card, snapToPoint: CGPoint(x: card.center.x, y: frameForCardAtIndex(3).midY))
                    snapBehavior.damping = 0.35
                    animator.addBehavior(snapBehavior)
                }
            }
        }
    }

    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            // Only accept touches that are inside the top card
            if let card = topCard {
                return card.frame.contains(touch.locationInView(self))
            }
        }

        return true
    }

    public var topCard: UIView? {
        return _cards.last
    }

    public func addCard(card: UIView) {
        _cards.append(card)
        addSubview(card)
        layoutCards()
    }

    public func removeCard(card: UIView) {
        if let index = find(_cards, card) {
            _cards.removeAtIndex(index)
            card.removeFromSuperview()
            layoutCards()
        }
    }

    // Using layout subviews here causes problems when moving the top card to the back because
    // moving views around causes layoutSubviews to be called. Instead of keeping track of some sort
    // of animating state, we simply do layout in another method.
    public func layoutCards() {
        for index in (0..<_cards.count) {
            let card = _cards[index]
            card.frame = frameForCardAtIndex(index)
        }
    }

    func frameForCardAtIndex(index: Int) -> CGRect {
        return CGRectMake(0.0, CGFloat(index * 40), CGRectGetWidth(bounds), CGRectGetHeight(bounds))
    }

    public func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        animator.removeAllBehaviors()
    }

    public func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        animator.removeAllBehaviors()

        if let card = topCard {
            sendSubviewToBack(card)
            _cards.removeLast()
            _cards.insert(card, atIndex: 0)

            let dynamicBehavior = UIDynamicItemBehavior(items: cards)
            dynamicBehavior.allowsRotation = false
            animator.addBehavior(dynamicBehavior)

            for index in (0..<cards.count) {
                let card = _cards[index]
                let frame = frameForCardAtIndex(index)

                let snapBehavior = UISnapBehavior(item: card, snapToPoint: CGPoint(x: frame.midX, y: frame.midY))
                snapBehavior.damping = 0.3
                animator.addBehavior(snapBehavior)
            }
        }



    }
}