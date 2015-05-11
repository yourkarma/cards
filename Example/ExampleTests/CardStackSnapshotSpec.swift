import Quick
import Nimble
import Nimble_Snapshots
import Cards

func viewWithBackgroundColor(color: UIColor) -> UIView {
    let view = UIView()
    view.backgroundColor = color
    return view
}

class CardStackSnapshotSpec: QuickSpec {
    var cardStack: CardStack! = nil
    var cards: [UIView]! = nil

    override func spec() {
        beforeEach {
            self.cardStack = CardStack()
            let window = UIApplication.sharedApplication().keyWindow!
            self.cardStack.frame = window.bounds
            window.addSubview(self.cardStack)

            self.cards = [viewWithBackgroundColor(UIColor.redColor()),
                viewWithBackgroundColor(UIColor.greenColor()),
                viewWithBackgroundColor(UIColor.blueColor())]
        }

        it("makes cards visible when set with animation") {
            waitUntil { done in
                self.cardStack.setCards(self.cards, animated: true) {
                    expect(self.cardStack).to(haveValidSnapshot())
                    done()
                }
            }
        }

        it("makes cards visible when set without animation") {
            waitUntil { done in
                self.cardStack.setCards(self.cards, animated: false) {
                    expect(self.cardStack).to(haveValidSnapshot())
                    done()
                }
            }
        }

        it("makes cards invisible when popped with animation") {
            waitUntil { done in
                self.cardStack.setCards(self.cards, animated: false) {
                    self.cardStack.popCard(animated: true) {
                        expect(self.cardStack).to(haveValidSnapshot())
                        done()
                    }
                }
            }
        }

        it("makes cards invisible when popped without animation") {
            waitUntil { done in
                self.cardStack.setCards(self.cards, animated: false) {
                    self.cardStack.popCard(animated: false) {
                        expect(self.cardStack).to(haveValidSnapshot())
                        done()
                    }
                }
            }
        }
    }
}
