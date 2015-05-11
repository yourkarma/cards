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
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        self.addSubview(scrollView)
        return scrollView
    }()

    var animations: [CardAnimation] = []

    public var topCard: UIView? {
        return _cards.last
    }

    internal func addCardToBack(card: UIView, animated: Bool, completion: (() -> Void)?) {
        insertCard(card, atIndex: 0, animated: animated, completion: completion)
    }

    internal func insertCard(card: UIView, atIndex index: Int, animated: Bool, completion: (() -> Void)?) {
        self.scrollView.insertSubview(card, atIndex: index)
        _cards.insert(card, atIndex: index)

        self.setNeedsLayout()
        self.layoutIfNeeded()

        if animated {
            startAnimation(CardPushDownAnimation(cardStack: self, cards: cards.filter { $0 !== card }, completion: completion))
        } else {
            completion?()
        }
    }

    internal func insertCards(cards: [UIView], atIndexes indexes: [Int], animated: Bool, completion: (() -> Void)?) {
        assert(cards.count == indexes.count, "number of cards: \(cards.count) not equal to number of indexes: \(indexes.count)")

        let currentCards = self.cards

        let group = dispatch_group_create()
        for index in (0..<cards.count) {
            let card = cards[index]
            let insertionIndex = indexes[index]

            self.scrollView.insertSubview(card, atIndex: insertionIndex)
            _cards.insert(card, atIndex: insertionIndex)

        }

        self.setNeedsLayout()
        self.layoutIfNeeded()

        if (animated) {
            dispatch_group_enter(group)
            let animation = CardGroupPushAnimation(cardStack: self, cards: cards) {
                dispatch_group_leave(group)
            }
            animation.individualCardDelay = 0.0
            startAnimation(animation)
            dispatch_group_enter(group)
            startAnimation(CardSnapBackAnimation(cardStack: self, cards: currentCards) {
                dispatch_group_leave(group)
            })
        }

        dispatch_group_notify(group, dispatch_get_main_queue()) {
            completion?()
        }
    }


    internal func removeCards(cards: [UIView], animated: Bool, completion: (() -> Void)?) {

        cards.map { card -> Void in
            if let index = find(self.cards, card) {
                self._cards.removeAtIndex(index)
            }
        }

        let finishRemoval: (() ->()) = {
            cards.map { $0.removeFromSuperview() }
            self.setNeedsLayout()
            self.layoutIfNeeded()
            completion?()
        }

        if (animated) {
            let group = dispatch_group_create()

            dispatch_group_enter(group)
            startAnimation(CardGroupPopAnimation(cardStack: self, cards: cards) {
                dispatch_group_leave(group)
            })

            let remainingCards = self._cards.filter { !contains(cards, $0) }
            dispatch_group_enter(group)
            let snapAnimation = CardSnapBackAnimation(cardStack: self, cards: remainingCards) {
                dispatch_group_leave(group)
            }
            snapAnimation.delay = 0.1
            startAnimation(snapAnimation)

            dispatch_group_notify(group, dispatch_get_main_queue(), finishRemoval)
        } else {
            finishRemoval()
        }
    }

    public func pushCard(card: UIView) {
        pushCard(card, animated: false, completion: nil)
    }

    public func pushCard(card: UIView, animated: Bool, completion: (() -> Void)?) {
        _cards.append(card)
        self.scrollView.addSubview(card)
        self.setNeedsLayout()
        self.layoutIfNeeded()

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
                self.setNeedsLayout()
                self.layoutIfNeeded()
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
        self.startAnimation(CardGroupPopAnimation(cardStack: self, cards: self.cards) {
            self.cards.map { $0.removeFromSuperview() }

            cards.map { self.scrollView.addSubview($0) }
            self._cards = cards
            self.setNeedsLayout()
            self.layoutIfNeeded()

            if animated {
                self.stopAllAnimations()
                self.startAnimation(CardGroupPushAnimation(cardStack: self, cards: cards, completion: completion))
            } else {
                completion?()
            }
        })
    }
}

// Layout
extension CardStack {
    public override func layoutSubviews() {
        super.layoutSubviews()

        self.scrollView.frame = self.bounds

        animations.filter { $0.isRunning }

        var lastCard: UIView? = nil
        for index in (0..<_cards.count) {
            let card = self._cards[index]
            card.frame = self.cardRectForBounds(bounds, atIndex: index)
            lastCard = card
        }

        self.scrollView.contentSize = CGSize(width: self.bounds.width, height: lastCard?.frame.maxY ?? self.bounds.height)
    }

    func cardRectForBounds(bounds: CGRect, atIndex index: Int) -> CGRect {
        let aboveFrame: CGRect
        if index > 0 {
            aboveFrame = self._cards[index - 1].frame
        } else {
            aboveFrame = CGRect.zeroRect
        }

        let card = self._cards[index]
        return CGRect(x: bounds.minX, y: bounds.minY + aboveFrame.maxY, width: bounds.maxX, height: card.frame.height)
    }
}

// Animation
extension CardStack {
    func startAnimation(animation: CardAnimation) {
        animations.append(animation)
        animation.start()
    }

    func stopAllAnimations() {
        animations.map { $0.stop() }
    }
}