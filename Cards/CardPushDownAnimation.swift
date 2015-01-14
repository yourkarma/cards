//
//  CardPushDownAnimation.swift
//  Cards
//
//  Created by Klaas Pieter Annema on 14/01/15.
//  Copyright (c) 2015 Klaas Pieter Annema. All rights reserved.
//

import UIKit

class CardPushDownAnimation: CardAnimation {
    let cardStack: CardStack
    let cards: [UIView]
    let completion: CompletionBlock?
    var isRunning: Bool = false

    required init(cardStack: CardStack, cards: [UIView], completion: CompletionBlock?) {
        self.cardStack = cardStack
        self.cards = cards
        self.completion = completion
    }

    func start() {
        isRunning = true
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            for i in (0..<self.cards.count) {
                let card = self.cards[i]
                let index = find(self.cardStack.cards, card)!
                card.frame = self.cardStack.cardRectForBounds(self.cardStack.bounds, atIndex: index)
            }
        }) { completed in
            if let completion = self.completion {
                completion()
                self.isRunning = false
            }
        }
    }

    func stop() {
        cards.map { $0.layer.removeAllAnimations() }
        isRunning = false
    }
}
