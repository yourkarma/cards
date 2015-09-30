import UIKit

class CardMaskView: UIView {
    let maskLayer: CardMaskShapeLayer

    override init(frame: CGRect) {
        self.maskLayer = CardMaskShapeLayer()
        super.init(frame: frame)
        self.installAndUpdateMask()
        self.updateMask()
    }

    required init?(coder: NSCoder) {
        self.maskLayer = CardMaskShapeLayer()
        super.init(coder: coder)
        self.installAndUpdateMask()
    }

    func installAndUpdateMask() {
        self.layer.mask = self.maskLayer
        self.clipsToBounds = true
        self.updateMask()
    }

    func updateMask() {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSize(width: 4.0, height: 4.0)).CGPath
        self.maskLayer.path = maskPath
        self.maskLayer.frame = self.layer.bounds
    }

    override var bounds: CGRect {
        get {
            return super.bounds
        }
        set {
            super.bounds = newValue
            self.updateMask()
        }
    }
}