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
        if self.childViewControllers.count == 2 {
            fatalError("For now a maximum of 2 child view controllers is supported")
        }

        let topView = self.topViewController?.view.superview

        self.addChildViewController(viewController)

        self.presentChildView(viewController.view, overTopView: topView, animated: animated) {
            viewController.didMoveToParentViewController(self)
            completion?()
        }
    }

    public func popViewController(animated: Bool, completion: (() -> Void)? = nil) {
        if let topViewController = self.topViewController,
            let containerView = topViewController.view.superview {
                topViewController.willMoveToParentViewController(nil)

                let previousViewController = self.childViewControllers.first as? UIViewController
                self.dismissContainerView(containerView, overTopView: previousViewController?.view.superview, animated: animated) {
                    topViewController.removeFromParentViewController()
                    completion?()
                }
            }
    }

    func popViewController(sender: AnyObject) {
        self.popViewController(true)
    }

    func containerViewByAddingChildViewToViewHierarchy(childView: UIView) -> UIView {
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

        return containerView
    }

    func presentChildView(childView: UIView, overTopView topView: UIView?, animated: Bool, completion: (() -> Void)) {
        let scale = CGPoint(x: 0.9, y: 0.9)
        let transformY: CGFloat = -60.0

        let containerView = self.containerViewByAddingChildViewToViewHierarchy(childView)

        if animated {
            containerView.transform = CGAffineTransformMakeTranslation(0.0, containerView.frame.height - self.extendedEdgeDistance)

            // Ensure the content behind the view doesn't peek through when the
            // spring bounces.
            childView.frame.size.height += self.extendedEdgeDistance

            let transformAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
            transformAnimation.toValue = 0.0
            transformAnimation.springSpeed = 12.0
            transformAnimation.springBounciness = 2.0
            containerView.layer.pop_addAnimation(transformAnimation, forKey: "presentAnimation")
            transformAnimation.completionBlock = { _ in
                completion()
            }

            if let topView = topView {
                let moveUpAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
                moveUpAnimation.toValue = topView.layer.position.y + transformY
                moveUpAnimation.springSpeed = 12.0
                moveUpAnimation.springBounciness = 2.0
                topView.layer.pop_addAnimation(moveUpAnimation, forKey: "moveUpAnimation")

                let scaleBackAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
                scaleBackAnimation.toValue = NSValue(CGPoint: scale)
                scaleBackAnimation.springSpeed = 12.0
                scaleBackAnimation.springBounciness = 2.0
                topView.layer.pop_addAnimation(scaleBackAnimation, forKey: "scaleBackAnimation")

                let opacityDownAnimation = POPSpringAnimation(propertyNamed: kPOPLayerOpacity)
                opacityDownAnimation.toValue = 0.5
                opacityDownAnimation.springSpeed = 12.0
                opacityDownAnimation.springBounciness = 2.0
                topView.layer.pop_addAnimation(opacityDownAnimation, forKey: "opacityDownAnimation")
            }

        } else {
            if let topView = topView {
                let scaleTransform = CGAffineTransformMakeScale(scale.x, scale.y)
                let translateScaleTransform = CGAffineTransformTranslate(scaleTransform, 0.0, transformY)

                topView.transform = translateScaleTransform
                topView.alpha = 0.5
            }

            completion()
        }
    }

    func dismissContainerView(containerView: UIView, overTopView topView: UIView?, animated: Bool, completion: (() -> Void)) {
        if animated {
            let dismissAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
            dismissAnimation.toValue = containerView.frame.height - self.extendedEdgeDistance
            dismissAnimation.springSpeed = 12.0
            dismissAnimation.springBounciness = 0.0
            containerView.layer.pop_addAnimation(dismissAnimation, forKey: "dismissAnimation")
            dismissAnimation.completionBlock = { _ in
                containerView.removeFromSuperview()
                completion()
            }

            if let topView = topView {
                let moveDownAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
                moveDownAnimation.toValue = topView.layer.position.y + 60.0
                moveDownAnimation.springSpeed = 12.0
                moveDownAnimation.springBounciness = 0.0
                topView.layer.pop_addAnimation(moveDownAnimation, forKey: "moveDownAnimation")

                let scaleUpAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
                scaleUpAnimation.toValue = NSValue(CGPoint: CGPoint(x: 1.0, y: 1.0))
                scaleUpAnimation.springSpeed = 12.0
                scaleUpAnimation.springBounciness = 0.0
                topView.layer.pop_addAnimation(scaleUpAnimation, forKey: "scaleUpAnimation")

                let opacityUpAnimation = POPSpringAnimation(propertyNamed: kPOPLayerOpacity)
                opacityUpAnimation.toValue = 1.0
                opacityUpAnimation.springSpeed = 12.0
                opacityUpAnimation.springBounciness = 2.0
                topView.layer.pop_addAnimation(opacityUpAnimation, forKey: "opacityUpAnimation")
            }

        } else {
            if let topView = topView {
                topView.layer.transform = CATransform3DIdentity
                topView.layer.opacity = 1.0
            }

            containerView.removeFromSuperview()
            completion()
        }
    }
}