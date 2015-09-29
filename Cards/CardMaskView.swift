import UIKit

class CardMaskView: UIView {
    let maskLayer: CAShapeLayer

    override init(frame: CGRect) {
        self.maskLayer = CAShapeLayer()
        super.init(frame: frame)
        self.updateMask()
    }

    required init?(coder: NSCoder) {
        self.maskLayer = CAShapeLayer()
        super.init(coder: coder)
        self.updateMask()
    }

    func updateMask() {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSize(width: 4.0, height: 4.0)).CGPath
        self.maskLayer.path = maskPath
        self.layer.mask = self.maskLayer
        self.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateMask()
    }
}