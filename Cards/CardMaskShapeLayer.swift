import UIKit

class CardMaskShapeLayer: CAShapeLayer {
    override func actionForKey(event: String) -> CAAction? {
        if event == "path" {
            let animation = CABasicAnimation(keyPath: event)
            animation.duration = CATransaction.animationDuration()
            animation.timingFunction = CATransaction.animationTimingFunction()
            return animation
        } else {
            return super.actionForKey(event)
        }
    }
}