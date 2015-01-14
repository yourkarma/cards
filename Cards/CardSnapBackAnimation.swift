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
    let card: UIView
    let dynamicAnimator: UIDynamicAnimator
    let completion: CompletionBlock?

    var isRunning: Bool = false

    convenience init(cardStack: CardStack, card: UIView, completion: CompletionBlock?) {
        self.init(cardStack: cardStack, cards: [card], completion: completion)
    }

    required init(cardStack: CardStack, cards: [UIView], completion: CompletionBlock?) {
        self.cardStack = cardStack
        self.card = cards.last!
        self.dynamicAnimator = UIDynamicAnimator(referenceView: cardStack)
    }

    func start() {
        self.isRunning = true
        let index = find(cardStack.cards, card)!
        let rect = cardStack.cardRectForBounds(cardStack.bounds, atIndex: index)
        UIView.animateWithDuration(0.35, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.allZeros, animations: {
            self.card.frame = rect
        }) { completed in
            if let completion = self.completion {
                self.isRunning = false
                completion()
            }
        }
    }

    func stop() {
        card.layer.removeAllAnimations()
        isRunning = false
    }
}
