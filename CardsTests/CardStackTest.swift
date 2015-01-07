//
//  CardStackTest.swift
//  Cards
//
//  Created by Klaas Pieter Annema on 07/01/15.
//  Copyright (c) 2015 Klaas Pieter Annema. All rights reserved.
//

import UIKit
import XCTest
import Cards

class CardStackTest: XCTestCase {

    func testCardsAreAddedAsSubviews() {
        let stack = CardStack()

        let view = UIView()
        stack.addCard(view)

        XCTAssertTrue(view.isDescendantOfView(stack), "Card should be a subview of the stack")
    }

    func testCardsAreRemovedAsSubviews()    {
        let stack = CardStack()

        let view = UIView()
        stack.addCard(view)
        stack.removeCard(view)

        XCTAssertFalse(view.isDescendantOfView(stack), "Card should not be a subview of the stack")
    }
}
