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

    /*
    The speed the top card needs to be moving at to move down and to the back
    */
    let velocityTreshold = CGFloat(1500.0)

    /*
    The number of points of each that is visible above the cards in front of it.
    */
    let cardHeaderHeight = CGFloat(40.0)

    /*
    The damping applied when the velocity treshold isn't reached
    and the top card is snapped back to it's original position
    */
    let snapBackDamping = CGFloat(0.35)

    /*
    The damping applied when moving the top card to the back
    and up to the back card position
    */
    let topBackTransitionDamping = CGFloat(0.3)


    func rubberBandDistance(offset: CGFloat, dimension: CGFloat) -> CGFloat {
        let constant = CGFloat(0.05)
        let result = (constant * abs(offset) * dimension) / (dimension + constant * abs(offset));
        return offset < 0.0 ? -result : result;
    }

    var shouldRubberBand: Bool {
        return cards.count == 1
    }

    func shouldTransition(velocity: CGPoint) -> Bool {
        return cards.count > 1 && velocity.y > velocityTreshold
    }

    func handlePan(pan: UIPanGestureRecognizer) {
        if let card = topCard {
            if pan.state == UIGestureRecognizerState.Began {
                animator.removeAllBehaviors()
                startY  = card.frame.minY

            } else if pan.state == UIGestureRecognizerState.Changed {

                let translation: CGPoint = pan.translationInView(self)
                var newOriginY = CGFloat(startY + translation.y)

                if shouldRubberBand {
                    let minOriginY = CGFloat(0.0)
                    let maxOriginY = CGFloat(0.0)
                    let constrainedOriginY = max(minOriginY, min(newOriginY, maxOriginY));
                    let rubberBandY = rubberBandDistance(newOriginY - constrainedOriginY, dimension: bounds.height)
                    newOriginY = constrainedOriginY + rubberBandY
                }


                let frame = card.frame
                card.frame = CGRect(x: frame.origin.x, y: newOriginY, width: frame.size.width, height: frame.size.height)

            } else if pan.state == UIGestureRecognizerState.Ended {

                let velocity = pan.velocityInView(self)
                if shouldTransition(velocity) {
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

                    let snapBehavior = UISnapBehavior(item: card, snapToPoint: CGPoint(x: card.center.x, y: cardRectForBounds(bounds, atIndex: cards.count - 1).midY))
                    snapBehavior.damping = snapBackDamping
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

    public func pushCard(card: UIView) {
        _cards.append(card)
        addSubview(card)
        setNeedsLayout()
    }

    public func popCard() {
        if let card = topCard {
            _cards.removeLast()
            card.removeFromSuperview()
            setNeedsLayout()
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        animator.removeAllBehaviors()

        for index in (0..<_cards.count) {
            let card = _cards[index]
            card.frame = cardRectForBounds(bounds, atIndex: index)
        }
    }

    func cardRectForBounds(bounds: CGRect, atIndex index: Int) -> CGRect {
        return CGRectMake(0.0, CGFloat(index) * cardHeaderHeight, CGRectGetWidth(bounds), CGRectGetHeight(bounds))
    }

    public func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        animator.removeAllBehaviors()
    }

    public func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        animator.removeAllBehaviors()

        if let card = topCard {
            sendSubviewToBack(card)
            _cards.removeLast()
            self.layoutIfNeeded()
            _cards.insert(card, atIndex: 0)

            let dynamicBehavior = UIDynamicItemBehavior(items: cards)
            dynamicBehavior.allowsRotation = false
            animator.addBehavior(dynamicBehavior)

            for index in (0..<cards.count) {
                let card = _cards[index]
                let frame = cardRectForBounds(bounds, atIndex: index)

                let snapBehavior = UISnapBehavior(item: card, snapToPoint: CGPoint(x: frame.midX, y: frame.midY))
                snapBehavior.damping = topBackTransitionDamping
                animator.addBehavior(snapBehavior)
            }
        }



    }
}