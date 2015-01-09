//
//  CardStack.swift
//  Cards
//
//  Created by Klaas Pieter Annema on 07/01/15.
//  Copyright (c) 2015 Klaas Pieter Annema. All rights reserved.
//

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
        let card = _cards.last!

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

    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            // Only accept touches that are inside the top card
            return _cards.last!.frame.contains(touch.locationInView(self))
        }

        return true
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