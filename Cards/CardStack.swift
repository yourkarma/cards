//
//  CardStack.swift
//  Cards
//
//  Created by Klaas Pieter Annema on 07/01/15.
//  Copyright (c) 2015 Klaas Pieter Annema. All rights reserved.
//

import UIKit

public class CardStack: UIView {
    private var _cards: [UIView] = []
    public var cards: [UIView] {
        return _cards
    }

    public func addCard(card: UIView) {
        _cards.append(card)
        self.addSubview(card)
        self.setNeedsLayout()
    }

    public func removeCard(card: UIView) {
        if let index = find(_cards, card) {
            _cards.removeAtIndex(index)
            card.removeFromSuperview()
        }

        self.setNeedsLayout()
    }

    func frameForCardAtIndex(index: Int) -> CGRect {
        return CGRectMake(0.0, CGFloat(index * 40), CGRectGetWidth(bounds), CGRectGetHeight(bounds))
    }

    public override func layoutSubviews() {
        for index in (0..<_cards.count) {
            let card = _cards[index]
            card.frame = frameForCardAtIndex(index)
        }
    }
}