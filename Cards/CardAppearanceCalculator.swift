import Foundation

struct CardAppearanceCalculator {

    let baseOffset: CGFloat = -60.0
    let offsetFraction: CGFloat = 1.75

    let baseScale: CGFloat = 0.9
    let scaleFraction: CGFloat = 0.9

    let baseOpacity: CGFloat =  0.5
    let opacityFraction: CGFloat = 0.6

    var topOffset: CGFloat = 45.0

    func offsetForCardAtIndex(i: Int) -> CGFloat {
        let index = CGFloat(i)

        if i == 0 {
            return 0.0
        } else {
            return baseOffset * CGFloat(pow(offsetFraction, index - 1))
        }
    }

    func scaleForCardAtIndex(i: Int) -> CGFloat {
        let index = CGFloat(i)

        if index == 0 {
            return 1.0
        } else {
            return baseScale * CGFloat(pow(scaleFraction, index - 1))
        }
    }

    func opacityForCardAtIndex(i: Int) -> CGFloat {
        let index = CGFloat(i)

        if i == 0 {
            return 1.0
        } else {
            return baseOpacity * CGFloat(pow(opacityFraction, index - 1))
        }
    }

    func verticalTopOffsetForTraitCollection(traitCollection: UITraitCollection) -> CGFloat {
        if traitCollection.verticalSizeClass == .Compact {
            return 0.0
        } else {
            return self.topOffset
        }
    }
}