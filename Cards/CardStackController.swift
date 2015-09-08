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
import pop

extension UIViewController {
    public var cardStackController: CardStackController? {
        return self.parentViewController as? CardStackController
    }
}

public class CardStackController: UIViewController {
    public var topViewController: UIViewController? {
        return self.childViewControllers.last as? UIViewController
    }

    // The edge of the container view is slightly extended so that it's bottom rounded corners aren't visible.
    // This has no effect on the child view controller's view because it subtracts this amount from it's height.
    let extendedEdgeDistance: CGFloat = 10.0

    public func pushViewController(viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        self.addChildViewController(viewController)

        self.presentView(viewController.view, animated: animated) {
            viewController.didMoveToParentViewController(self)
            completion?()
        }
    }

    public func popViewController(animated: Bool, completion: (() -> Void)? = nil) {
        if let topViewController = self.topViewController,
            let containerView = topViewController.view.superview {
                topViewController.willMoveToParentViewController(nil)

                self.dismissContainerView(containerView, animated: animated) {
                    containerView.removeFromSuperview()
                    topViewController.removeFromParentViewController()
                    completion?()
                }
            }
    }

    func popViewController(sender: AnyObject) {
        self.popViewController(true)
    }

    func presentView(childView: UIView, animated: Bool, completion: (() -> Void)) {
        let containerView = UIView()
        containerView.setTranslatesAutoresizingMaskIntoConstraints(false)

        childView.setTranslatesAutoresizingMaskIntoConstraints(false)
        containerView.addSubview(childView)

        let dismissButton = UIButton()
        dismissButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        let bundle = NSBundle(forClass: CardStackController.self)
        let image = UIImage(named: "Cards.bundle/dismiss-arrow.png", inBundle: bundle, compatibleWithTraitCollection: nil)
        dismissButton.setImage(image, forState: .Normal)
        containerView.addSubview(dismissButton)
        dismissButton.addTarget(self, action: "popViewController:", forControlEvents: .TouchUpInside)
        self.view.addSubview(containerView)

        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[button]|", options: .allZeros, metrics: nil, views: ["button": dismissButton]))
        containerView.addConstraint(NSLayoutConstraint(item: dismissButton, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: 0.0))

        containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: 0.0))

        containerView.addConstraint(NSLayoutConstraint(item: childView, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1.0, constant: -self.extendedEdgeDistance))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[child]|", options: .allZeros, metrics: nil, views: ["child": childView]))

        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 40.0))

        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: self.extendedEdgeDistance))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[container]|", options: .allZeros, metrics: nil, views: ["container": containerView]))

        containerView.layer.borderColor = UIColor.clearColor().CGColor
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = 4.0
        self.view.layoutIfNeeded()

        if animated {
            containerView.transform = CGAffineTransformMakeTranslation(0.0, containerView.frame.height - self.extendedEdgeDistance)

            // Ensure the content behind the view doesn't peek through when the
            // spring bounces.
            childView.frame.size.height += self.extendedEdgeDistance

            let transformAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
            transformAnimation.toValue = 0.0
            transformAnimation.springSpeed = 12.0
            transformAnimation.springBounciness = 2.0
            containerView.layer.pop_addAnimation(transformAnimation, forKey: "transformAnimation")

            transformAnimation.completionBlock = { _ in

                // Restore the child view to the state that it should be in (according to it's constraints).
                childView.frame.size.height -= self.extendedEdgeDistance
                completion()
            }
        } else {
            completion()
        }
    }

    func dismissContainerView(containerView: UIView, animated: Bool, completion: (() -> Void)) {
        if animated {
            let transformAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
            transformAnimation.toValue = containerView.frame.height - self.extendedEdgeDistance
            transformAnimation.springSpeed = 12.0
            transformAnimation.springBounciness = 0.0
            containerView.layer.pop_addAnimation(transformAnimation, forKey: "transformAnimation")
            transformAnimation.completionBlock = { _ in
                completion()
            }

        } else {
            completion()
        }

    }
}