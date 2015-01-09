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

public class CardStack: UIView, UIDynamicAnimatorDelegate {
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

        let tap = UITapGestureRecognizer(target: self, action: "handleTap:")
        addGestureRecognizer(tap)
    }

    func handleTap(tap: UITapGestureRecognizer) {
        animator.removeAllBehaviors()
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

                if card.frame.minY > center.y {
                    // This is where the card is supposed to move down and slide to the back
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
        setNeedsLayout()
    }

    public func removeCard(card: UIView) {
        if let index = find(_cards, card) {
            _cards.removeAtIndex(index)
            card.removeFromSuperview()
            setNeedsLayout()
        }
    }

    public override func layoutSubviews() {
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
}