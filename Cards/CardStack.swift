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

public class CardStack: UIView {
    private var _cards: [UIView] = []
    public var cards: [UIView] {
        return _cards
    }

    var animator: UIDynamicAnimator?
    var displayLink: CADisplayLink!

    var startY: CGFloat!

    var animations: [CardAnimation] = []

    override public func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview != nil {
            animator = UIDynamicAnimator(referenceView: self)
            animator?.delegate = self

            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
            panGestureRecognizer.delegate = self
            addGestureRecognizer(panGestureRecognizer)

            displayLink = CADisplayLink(target: self, selector: "syncCardPositions")
            displayLink.paused = true
            displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        }
    }

    /*
    The speed the top card needs to be moving at to move down and to the back
    */
    let velocityTreshold = CGFloat(1500.0)

    /*
    The number of points of each that is visible above the cards in front of it.
    */
    let cardHeaderHeight = CGFloat(40.0)

    public var topCard: UIView? {
        return _cards.last
    }

    private func addCardToBack(card: UIView, animated: Bool, completion: (() -> Void)?) {
        insertCard(card, atIndex: 0, animated: animated, completion: completion)
    }

    private func insertCard(card: UIView, atIndex index: Int, animated: Bool, completion: (() -> Void)?) {
        self.insertSubview(card, atIndex: index)
        _cards.insert(card, atIndex: index)

        if animated {
            startAnimation(CardPushDownAnimation(cardStack: self, cards: cards.filter { $0 !== card }, completion: nil))
        } else {
            self.layoutIfNeeded()
            completion?()
        }
    }

    public func pushCard(card: UIView) {
        pushCard(card, animated: false, nil)
    }

    public func pushCard(card: UIView, animated: Bool, completion: (() -> Void)?) {
        _cards.append(card)
        addSubview(card)
        layoutIfNeeded()

        if animated {
            startAnimation(CardPushAnimation(cardStack: self, card: card, completion: completion))
        } else {
            completion?()
        }
    }

    public func popCard() {
        popCard(animated: false, completion: nil)
    }

    public func popCard(#animated: Bool, completion: (() -> Void)?) {
        if let card = topCard {
            self._cards.removeLast()

            let finishPop: (() -> Void) = {
                card.removeFromSuperview()
                completion?()
            }

            if (animated) {
                startAnimation(CardPopAnimation(cardStack: self, card: card, completion: finishPop))
            } else {
                finishPop()
            }
        }
    }

    public func setCards(cards: [UIView], animated: Bool, completion: (() -> Void)?) {
        while topCard != nil {
            popCard()
        }
        cards.map { self.addSubview($0) }
        _cards = cards
        layoutIfNeeded()

        if animated {
            stopAllAnimations()
            startAnimation(CardGroupPushAnimation(cardStack: self, cards: cards, completion: completion))
        } else {
            completion?()
        }
    }
}

// Gestures
extension CardStack: UIGestureRecognizerDelegate {

    func rubberBandDistance(offset: CGFloat, dimension: CGFloat) -> CGFloat {
        let constant = CGFloat(0.05)
        let result = (constant * abs(offset) * dimension) / (dimension + constant * abs(offset));
        return offset < 0.0 ? -result : result;
    }

    func shouldRubberBand(atPosition position: CGPoint) -> Bool {
        return cards.count == 1 || position.y < 0.0
    }

    func shouldTransition(velocity: CGPoint) -> Bool {
        return cards.count > 1 && velocity.y > velocityTreshold
    }

    func handlePan(pan: UIPanGestureRecognizer) {
        if let card = topCard {
            if pan.state == UIGestureRecognizerState.Began {
                stopAllAnimations()
                startY  = card.frame.minY

            } else if pan.state == UIGestureRecognizerState.Changed {

                let translation: CGPoint = pan.translationInView(self)
                var newPosition = CGPoint(x: frame.minX, y: CGFloat(startY + translation.y))

                let minOriginY = CGFloat(0.0)
                let maxOriginY = CGFloat(0.0)

                if shouldRubberBand(atPosition: newPosition) {
                    let constrainedOriginY = max(minOriginY, min(newPosition.y, maxOriginY));
                    let rubberBandY = rubberBandDistance(newPosition.y - constrainedOriginY, dimension: bounds.height)
                    newPosition.y = constrainedOriginY + rubberBandY
                }

                card.frame.origin = newPosition
                syncCardPositions()

            } else if pan.state == UIGestureRecognizerState.Ended {

                let velocity = pan.velocityInView(self)
                if shouldTransition(velocity) {
                    displayLink.paused = true
                    let animation = CardPopWithVelocityAnimation(cardStack: self, cards: cards) {
                        let card = self.topCard!
                        self.popCard(animated: false, completion: nil)
                        self.addCardToBack(card, animated: true, completion: nil)
                    }
                    animation.velocity = velocity
                    startAnimation(animation)
                } else {
                    displayLink.paused = false
                    startAnimation(CardSnapBackAnimation(cardStack: self, card: card) {
                        self.displayLink.paused = false
                    })
                }
            }
        }
    }

    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        // Only accept touches that are inside the top card
        if let card = topCard {
            return card.frame.contains(touch.locationInView(self))
        }

        return false
    }

    func syncCardPositions() {
        if let card = topCard {
            let normalY = cardRectForBounds(bounds, atIndex: find(cards, card)!).minY
            let currentY = card.frame.minY
            let offsetY = currentY - normalY

            let otherCards = cards.filter { $0 !== card }
            for index in (0..<otherCards.count) {
                let card = otherCards[index]
                let normalY = cardRectForBounds(bounds, atIndex: find(cards, card)!).minY
                let newY = normalY + ((offsetY / 20.0) * CGFloat(index + 1))
                card.frame.origin.y = newY
            }
        }
    }
}

// Layout
extension CardStack {
    public override func layoutSubviews() {
        super.layoutSubviews()

        animator?.removeAllBehaviors()
        animations.filter { $0.isRunning }

        for index in (0..<_cards.count) {
            let card = _cards[index]
            card.frame = cardRectForBounds(bounds, atIndex: index)
        }
    }

    func cardRectForBounds(bounds: CGRect, atIndex index: Int) -> CGRect {
        return CGRectMake(0.0, CGFloat(index) * cardHeaderHeight, CGRectGetWidth(bounds), CGRectGetHeight(bounds))
    }
}

// Animation
extension CardStack: UIDynamicAnimatorDelegate {
    func startAnimation(animation: CardAnimation) {
        animations.append(animation)
        animation.start()
    }

    func stopAllAnimations() {
        animations.map { $0.stop() }
        animations = []
        animator?.removeAllBehaviors()
    }

    public func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        animator.removeAllBehaviors()
    }
}