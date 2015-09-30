import UIKit

class CardScrollView: UIScrollView {
    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancelInContentView(view)
    }
}