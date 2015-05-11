import Quick
import Nimble
import Cards

class CardStackSpec: QuickSpec {
    var stack: CardStack!

    override func spec() {
        beforeEach {
            self.stack = CardStack()
        }

        describe("#pushCard") {
            it("adds the card as a descendant") {
                let view = UIView()
                self.stack.pushCard(view)
                expect(view.isDescendantOfView(self.stack)) == true
            }

            it("calls the animation completion block when cards are pushed without animation") {
                waitUntil { done in
                    let view = UIView()
                    self.stack.pushCard(view, animated: false) {
                        done()
                    }
                }
            }

            it("adds the last added card as the top card") {
                let view = UIView()
                self.stack.pushCard(UIView())
                self.stack.pushCard(view)

                expect(self.stack.topCard) == view
            }
        }

        describe("#popCard") {
            it("removes the card as a descendant") {
                let view = UIView()
                self.stack.pushCard(view)
                self.stack.popCard(animated: false, completion: nil)

                expect(view.isDescendantOfView(self.stack)) == false
            }

            it("calls the animation completion block when removed without animation") {
                waitUntil { done in
                    self.stack.pushCard(UIView())
                    self.stack.popCard(animated: false) {
                        done()
                    }
                }
            }
        }

        describe("#setCards") {
            it("adds the cards as descendents") {
                let view = UIView()
                self.stack.setCards([UIView(), view], animated: false, completion: nil)
                expect(view.isDescendantOfView(self.stack)).toEventually(beTrue())
            }

            it("calls the animation completion block when setting multiple cards without animation") {
                waitUntil { done in
                    self.stack.setCards([UIView()], animated: false) {
                        done()
                    }
                }
            }

            it("removes old cards when setting new") {
                let view1 = UIView()
                let view2 = UIView()

                self.stack.setCards([view1], animated: false, completion: nil)
                self.stack.setCards([view2], animated: false, completion: nil)

                expect(view1.isDescendantOfView(self.stack)) == false
            }
        }
    }
}
