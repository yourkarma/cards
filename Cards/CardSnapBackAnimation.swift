//
//  CardSnapBackAnimation.swift
//  Cards
//
//  Created by Klaas Pieter Annema on 14/01/15.
//  Copyright (c) 2015 Klaas Pieter Annema. All rights reserved.
//

import UIKit

class CardSnapBackAnimation: CardAnimation {

    let cardStack: CardStack
    let cards: [UIView]
    let dynamicAnimator: UIDynamicAnimator
    let completion: CompletionBlock?
    var delay = 0.0

    var isRunning: Bool = false

    convenience init(cardStack: CardStack, card: UIView, completion: CompletionBlock?) {
        self.init(cardStack: cardStack, cards: [card], completion: completion)
    }

    required init(cardStack: CardStack, cards: [UIView], completion: CompletionBlock?) {
        self.cardStack = cardStack
        self.cards = cards
        self.dynamicAnimator = UIDynamicAnimator(referenceView: cardStack)
        self.completion = completion
    }

    func start() {
        self.isRunning = true

        let group = dispatch_group_create()

        self.cards.map { card -> Void in

            if let index = find(self.cardStack.cards, card) {
                dispatch_group_enter(group)

                let rect = self.cardStack.cardRectForBounds(self.cardStack.bounds, atIndex: index)
                UIView.animateWithDuration(0.35, delay: self.delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.allZeros, animations: {
                    card.frame = rect
                    }) { completed in
                        dispatch_group_leave(group)
                }
            }
        }

        dispatch_group_notify(group, dispatch_get_main_queue()) {
            self.finish()
        }
    }

    func stop() {
        self.cards.map { $0.layer.removeAllAnimations() }
        isRunning = false
    }

    func finish() {
       self.isRunning = false
        completion?()
    }
}
