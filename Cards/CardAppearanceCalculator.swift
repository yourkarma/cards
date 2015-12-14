// CardAppearanceCalculator.swift
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