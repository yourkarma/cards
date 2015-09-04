// CardStackController.swift
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

extension UIViewController {
    public var cardStackController: CardStackController? {
        return self.parentViewController as? CardStackController
    }
}

public class CardStackController: UIViewController {
    public var topViewController: UIViewController? {
        return self.childViewControllers.last as? UIViewController
    }

    public func pushViewController(viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        self.addChildViewController(viewController)

        let containerView = UIView()
        containerView.setTranslatesAutoresizingMaskIntoConstraints(false)

        let childView = viewController.view
        childView.setTranslatesAutoresizingMaskIntoConstraints(false)
        containerView.addSubview(childView)

        let dismissButton = UIButton()
        dismissButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        let image = UIImage(named: "dismiss-arrow", inBundle: NSBundle(forClass: CardStackController.self), compatibleWithTraitCollection: nil)!
        dismissButton.setImage(image, forState: .Normal)
        containerView.addSubview(dismissButton)
        dismissButton.addTarget(self, action: "popViewController:", forControlEvents: .TouchUpInside)
        self.view.addSubview(containerView)

        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[button]|", options: .allZeros, metrics: nil, views: ["button": dismissButton]))
        containerView.addConstraint(NSLayoutConstraint(item: dismissButton, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: 0.0))

        containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: 0.0))

        // The edge of the container view is slightly extended so that it's bottom rounded corners aren't visible.
        // This has no effect on the child view controller's view because it subtracts this amount from it's height.
        let extendedEdgeDistance: CGFloat = 10.0

        containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1.0, constant: -extendedEdgeDistance))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[child]|", options: .allZeros, metrics: nil, views: ["child": childView]))

        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 40.0))

        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: extendedEdgeDistance))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[container]|", options: .allZeros, metrics: nil, views: ["container": containerView]))

        containerView.layer.borderColor = UIColor.clearColor().CGColor
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = 4.0

        viewController.didMoveToParentViewController(self)

        completion?()
    }

    public func popViewController(animated: Bool, completion: (() -> Void)? = nil) {
        if let topViewController = self.topViewController,
            let containerView = topViewController.view.superview {
                topViewController.willMoveToParentViewController(nil)
                containerView.removeFromSuperview()
                topViewController.removeFromParentViewController()
                completion?()
        }
    }

    func popViewController(sender: AnyObject) {
        self.popViewController(true)
    }
}