import UIKit

class CardMaskShapeLayer: CAShapeLayer {
    var willAnimate: Bool = false

    override func actionForKey(event: String) -> CAAction? {
        if event == "path" && self.willAnimate {
            let animation = CABasicAnimation(keyPath: event)
            animation.duration = CATransaction.animationDuration()
            animation.timingFunction = CATransaction.animationTimingFunction()
            return animation
        } else {
            return super.actionForKey(event)
        }
    }
}