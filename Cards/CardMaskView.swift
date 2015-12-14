// CardMaskView.swift
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

import UIKit

class CardMaskView: UIView {
    let maskLayer: CardMaskShapeLayer

    var willAnimate: Bool {
        get {
            return self.maskLayer.willAnimate
        }
        set {
            self.maskLayer.willAnimate = newValue
        }
    }

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