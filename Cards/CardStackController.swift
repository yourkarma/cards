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

struct Card {
    let viewController: UIViewController

    var views: CardHierarchy
    var layout: CardLayout
}

struct CardHierarchy {
    let containerView: UIView
    let dismissButton: UIButton
    let scrollView: UIScrollView
    let childView: UIView
}

struct CardLayout {
    var constraintsAffectedByTraitChange: [NSLayoutConstraint]
    var dismissButtonTopConstraint: NSLayoutConstraint
}

extension UIViewController {
    public var cardStackController: CardStackController? {
        if let cardStackController = self.parentViewController as? CardStackController {
            return cardStackController
        } else {
            return self.parentViewController?.cardStackController
        }
    }
}

public class CardStackController: UIViewController {
    public var topViewController: UIViewController? {
        return self.topCard?.viewController
    }

    public var topViewControllerCanBeDismissed: Bool {
        get {
            return self.topCard?.views.dismissButton.enabled ?? false
        }
        set {
            self.topCard?.views.dismissButton.enabled = newValue
        }
    }

    public var cardTopOffset: CGFloat {
        get {
            return self.cardAppearanceCalculator.topOffset
        }
        set {
            self.cardAppearanceCalculator.topOffset = newValue
        }
    }

    public init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.pushViewController(rootViewController, animated: false, completion: nil)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public var cardStackTransitionCoordinator: TransitionCoordinator?

    var cards: [Card] = []
    var topCard: Card? {
        return self.cards.last
    }
    var cardAppearanceCalculator: CardAppearanceCalculator = CardAppearanceCalculator()

    var rootViewController: UIViewController? {
        didSet {
            if let rootViewController = self.rootViewController {
                self.addChildViewController(rootViewController)
                self.view.addSubview(rootViewController.view)

                self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[root]|", options: [], metrics: nil, views: ["root": rootViewController.view]))
                self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[root]|", options: [], metrics: nil, views: ["root": rootViewController.view]))

                rootViewController.didMoveToParentViewController(self)
            } else {
                oldValue?.willMoveToParentViewController(nil)
                oldValue?.view.removeFromSuperview()
                oldValue?.removeFromParentViewController()
            }
        }
    }

    var panGestureRecognizer: UIPanGestureRecognizer!

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        self.view.addGestureRecognizer(self.panGestureRecognizer)
    }

    public func pushViewController(viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        self.cancelAnimations()

        if rootViewController == nil {
            self.rootViewController = viewController
        } else {
            self.cardStackTransitionCoordinator = TransitionCoordinator()

            let topViewController: UIViewController?

            if let topCard = self.topCard {
                topViewController = topCard.viewController
            } else {
                topViewController = self.rootViewController
            }
            topViewController?.beginAppearanceTransition(false, animated: animated)

            let hierarchy = self.makeHierarchyForChildView(viewController.view)
            let layout = self.constrainHierarchy(hierarchy)
            let card = Card(viewController: viewController, views: hierarchy, layout: layout)

            self.addChildViewController(viewController)

            self.presentCard(card, overCards: self.cards, animated: animated) {
                viewController.didMoveToParentViewController(self)
                topViewController?.endAppearanceTransition()
                completion?()
            }
        }
    }

    public func popViewController(animated: Bool, completion: (() -> Void)? = nil) {
        self.popViewController(animated, velocity: nil, completion: completion)
    }

    func popViewController(animated: Bool, velocity: CGFloat?, completion: (() -> Void)? = nil) {
        self.cancelAnimations()
        
        if let topCard = self.topCard {
            self.cardStackTransitionCoordinator = TransitionCoordinator()

            let topViewController = topCard.viewController
            let remainingCards = Array(self.cards[0..<self.cards.endIndex - 1])

            let newTopViewController: UIViewController?
            if let newTopCard = remainingCards.last {
                newTopViewController = newTopCard.viewController
            } else {
                newTopViewController = self.rootViewController
            }

            newTopViewController?.beginAppearanceTransition(true, animated: animated)
            topViewController.willMoveToParentViewController(nil)

            self.dismissCard(topCard, remainingCards: remainingCards, animated: animated, velocity: velocity) {
                topViewController.removeFromParentViewController()
                newTopViewController?.endAppearanceTransition()
                completion?()
            }
        }
    }

    public override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        for card in self.cards {
            card.layout.constraintsAffectedByTraitChange.forEach { $0.constant = self.cardAppearanceCalculator.verticalTopOffsetForTraitCollection(self.traitCollection) }
            self.view.layoutIfNeeded()
        }
    }

    func presentCard(card: Card, overCards cards: [Card], animated: Bool, completion: (() -> Void)) {
        let containerView = card.views.containerView

        self.cards.append(card)
        self.view.addSubview(containerView)

        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: containerView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))

        self.view.layoutIfNeeded()

        self.cardStackTransitionCoordinator?.transitionWillBegin()

        if animated {
            // Applying the transform directly, instead of using fromValue, prevents a brief flash
            // where the view is visible in it's final location.
            containerView.layer.transform = CATransform3DMakeTranslation(0.0, containerView.bounds.height, 0.0)

            let presentAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
            presentAnimation.toValue = 0.0
            presentAnimation.springSpeed = 12.0
            presentAnimation.springBounciness = 2.0
            containerView.layer.pop_addAnimation(presentAnimation, forKey: "presentAnimation")
            presentAnimation.completionBlock = { _ in
                self.cardStackTransitionCoordinator?.transitionDidEnd()
                self.cardStackTransitionCoordinator = nil
                completion()
            }

        } else {
            self.cardStackTransitionCoordinator?.transitionDidEnd()
            completion()
        }

        self.moveCardsBack(cards, animated: animated)
    }

    func moveCardsBack(cards: [Card], animated: Bool) {
        let springSpeed: CGFloat = 12.0
        let springBounciness: CGFloat = 2.0

        for (i, card) in Array(cards.reverse()).enumerate() {
            let dismissButton = card.views.dismissButton

            // Disable the dismiss button without showing the disabled state
            dismissButton.userInteractionEnabled = false

            let containerView = card.views.containerView

            // + 1 because the first card is not part of the cards array
            let offset = self.offsetForCardAtIndex(i + 1)
            let scale = self.scaleForCardAtIndex(i + 1)
            let opacity = self.opacityForCardAtIndex(i + 1)

            if animated {
                let moveUpAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
                moveUpAnimation.toValue = offset
                moveUpAnimation.springSpeed = springSpeed
                moveUpAnimation.springBounciness = springBounciness
                containerView.layer.pop_addAnimation(moveUpAnimation, forKey: "moveUpAnimation")

                let scaleBackAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
                scaleBackAnimation.toValue = NSValue(CGPoint: CGPoint(x: scale, y: scale))
                scaleBackAnimation.springSpeed = springSpeed
                scaleBackAnimation.springBounciness = springBounciness
                containerView.layer.pop_addAnimation(scaleBackAnimation, forKey: "scaleDownAnimation")

                let opacityDownAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha)
                opacityDownAnimation.toValue = opacity
                opacityDownAnimation.springSpeed = springSpeed
                opacityDownAnimation.springBounciness = springBounciness
                containerView.pop_addAnimation(opacityDownAnimation, forKey: "opacityDownAnimation")

                let dismissButtonOpacityAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
                dismissButtonOpacityAnimation.duration = 0.25
                dismissButtonOpacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                dismissButtonOpacityAnimation.toValue = 0.0
                dismissButton.pop_addAnimation(dismissButtonOpacityAnimation, forKey: "dismissButtonDisappearAnimation")
            } else {
                let scaleTransform = CGAffineTransformMakeScale(scale, scale)
                let translationTransform = CGAffineTransformMakeTranslation(0.0, offset)
                let combinedTransform = CGAffineTransformConcat(scaleTransform, translationTransform)

                containerView.transform = combinedTransform
                containerView.alpha = opacity
                dismissButton.alpha = 0.0
            }
        }
    }

    func dismissCard(card: Card, remainingCards: [Card], animated: Bool, velocity: CGFloat?, completion: (() -> Void)) {
        self.cardStackTransitionCoordinator?.transitionWillBegin()

        let containerView = card.views.containerView
        self.cards.removeLast()

        if animated {
            let dismissAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
            dismissAnimation.toValue = containerView.frame.height
            dismissAnimation.springSpeed = 12.0
            dismissAnimation.springBounciness = 0.0

            if let velocity = velocity {
                dismissAnimation.velocity = velocity
            }

            containerView.layer.pop_addAnimation(dismissAnimation, forKey: "dismissAnimation")
            dismissAnimation.completionBlock = { _ in
                containerView.removeFromSuperview()
                self.cardStackTransitionCoordinator?.transitionDidEnd()
                completion()
            }

        } else {
            containerView.removeFromSuperview()
            self.cardStackTransitionCoordinator?.transitionDidEnd()
            self.cardStackTransitionCoordinator = nil
            completion()
        }

        self.moveCardsForward(self.cards, animated: animated)
    }

    func moveCardsForward(cards: [Card], animated: Bool) {
        for (index, card) in Array(cards.reverse()).enumerate() {
            let containerView = card.views.containerView
            let dismissButton = card.views.dismissButton

            let offset = self.offsetForCardAtIndex(index)
            let scale = self.scaleForCardAtIndex(index)
            let opacity = self.opacityForCardAtIndex(index)

            if animated {
                let springSpeed: CGFloat = 12.0
                let springBounciness: CGFloat = 0.0

                let moveUpAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
                moveUpAnimation.toValue = offset
                moveUpAnimation.springSpeed = springSpeed
                moveUpAnimation.springBounciness = springBounciness
                containerView.layer.pop_addAnimation(moveUpAnimation, forKey: "moveDownAnimation")

                let scaleBackAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
                scaleBackAnimation.toValue = NSValue(CGPoint: CGPoint(x: scale, y: scale))
                scaleBackAnimation.springSpeed = springSpeed
                scaleBackAnimation.springBounciness = springBounciness
                containerView.layer.pop_addAnimation(scaleBackAnimation, forKey: "scaleUpAnimation")

                let opacityDownAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha)
                opacityDownAnimation.toValue = opacity
                opacityDownAnimation.springSpeed = springSpeed
                opacityDownAnimation.springBounciness = springBounciness
                containerView.pop_addAnimation(opacityDownAnimation, forKey: "opacityUpAnimation")

                if index == 0 {
                    let dismissButtonOpacityAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
                    dismissButtonOpacityAnimation.duration = 0.3
                    dismissButtonOpacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                    dismissButtonOpacityAnimation.toValue = 1.0
                    dismissButton.pop_addAnimation(dismissButtonOpacityAnimation, forKey: "dismissButtonAppearAnimation")
                }

            } else {
                let scaleTransform = CGAffineTransformMakeScale(scale, scale)
                let translationTransform = CGAffineTransformMakeTranslation(0.0, offset)
                let combinedTransform = CGAffineTransformConcat(scaleTransform, translationTransform)
                containerView.transform = combinedTransform
                containerView.alpha = opacity

                dismissButton.alpha = index == 0 ? 1.0 : 0.0
            }

            dismissButton.userInteractionEnabled = index == 0
        }
    }

    func popViewController(sender: AnyObject) {
        self.popViewController(true)
    }

    func makeHierarchyForChildView(childView: UIView) -> CardHierarchy {
        let containerView = UIView()

        containerView.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self

        childView.translatesAutoresizingMaskIntoConstraints = false

        let dismissButton = self.makeDismissButton()
        dismissButton.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(childView)
        scrollView.addSubview(dismissButton)
        containerView.addSubview(scrollView)

        return CardHierarchy(containerView: containerView, dismissButton: dismissButton, scrollView: scrollView, childView: childView)
    }

    func constrainHierarchy(hierarchy: CardHierarchy) -> CardLayout {
        let verticalTopOffset = self.cardAppearanceCalculator.verticalTopOffsetForTraitCollection(self.traitCollection)

        let dismissButton = hierarchy.dismissButton
        let childView = hierarchy.childView
        let containerView = hierarchy.containerView
        let scrollView = hierarchy.scrollView

        let dismissButtonTopConstraint = NSLayoutConstraint(item: dismissButton, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: verticalTopOffset)
        containerView.addConstraint(dismissButtonTopConstraint)
        containerView.addConstraint(NSLayoutConstraint(item: dismissButton, attribute: .Leading, relatedBy: .Equal, toItem: containerView, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: dismissButton, attribute: .Trailing, relatedBy: .Equal, toItem: containerView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: dismissButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 45.0))

        let childScrollTopConstraint = NSLayoutConstraint(item: childView, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Top, multiplier: 1.0, constant: verticalTopOffset)
        let childScrollBottomConstraint = NSLayoutConstraint(item: childView, attribute: .Bottom, relatedBy: .Equal, toItem: scrollView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let childScrollLeadingConstraint = NSLayoutConstraint(item: childView, attribute: .Leading, relatedBy: .Equal, toItem: scrollView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let childScrollTrailingConstraint = NSLayoutConstraint(item: childView, attribute: .Trailing, relatedBy: .Equal, toItem: scrollView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let childScrollConstraints = [childScrollTopConstraint, childScrollBottomConstraint, childScrollLeadingConstraint, childScrollTrailingConstraint]
        containerView.addConstraints(childScrollConstraints)

        let childContainerTopConstraint = NSLayoutConstraint(item: childView, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: verticalTopOffset)
        let childContainerBottomConstraint = NSLayoutConstraint(item: childView, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let childContainerLeadingConstraint = NSLayoutConstraint(item: childView, attribute: .Leading, relatedBy: .Equal, toItem: containerView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let childContainerTrailingConstraint = NSLayoutConstraint(item: childView, attribute: .Trailing, relatedBy: .Equal, toItem: containerView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let childContainerConstraints = [childContainerTopConstraint, childContainerBottomConstraint, childContainerLeadingConstraint, childContainerTrailingConstraint]
        childContainerConstraints.forEach { $0.priority = 1 } // Super low priority so that essentially everything (i.e. image view content hugging priority, compression resistantance) overrides it
        containerView.addConstraints(childContainerConstraints)

        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))

        return CardLayout(constraintsAffectedByTraitChange: [childScrollTopConstraint, childContainerTopConstraint, dismissButtonTopConstraint], dismissButtonTopConstraint: dismissButtonTopConstraint)

    }

    func makeDismissButton() -> UIButton {
        let dismissButton = UIButton()
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        let bundle = NSBundle(forClass: CardStackController.self)
        let image = UIImage(named: "Cards.bundle/dismiss-arrow.png", inBundle: bundle, compatibleWithTraitCollection: nil)
        dismissButton.setImage(image, forState: .Normal)
        dismissButton.addTarget(self, action: "popViewController:", forControlEvents: .TouchUpInside)
        return dismissButton
    }

    // Taken from: http://holko.pl/2014/07/06/inertia-bouncing-rubber-banding-uikit-dynamics/
    func rubberBandDistance(offset: CGFloat , dimension: CGFloat )  -> CGFloat {
        let constant: CGFloat = 0.01
        let result = (constant * abs(offset) * dimension) / (dimension + constant * abs(offset))

        // The algorithm expects a positive offset, so we have to negate the result if the offset was negative.
        return offset < 0.0 ? -result : result
    }

    func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        if !self.topViewControllerCanBeDismissed {
            return
        }

        if let containerView = self.topCard?.views.containerView,
            let childView = self.topCard?.viewController.view {
            let translation = gestureRecognizer.translationInView(self.view)
            let velocity = gestureRecognizer.velocityInView(self.view)

            switch gestureRecognizer.state {

            case .Began:
                let containerViewHeightConstraint = NSLayoutConstraint(item: containerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: containerView.frame.height)
                containerView.addConstraint(containerViewHeightConstraint)
                self.cancelAnimations()

            case .Changed:
                let minY: CGFloat = 0.0
                let maxY: CGFloat = translation.y

                let constrained = max(minY, min(translation.y, maxY))
                let rubberBandedY = self.rubberBandDistance(translation.y - constrained, dimension: containerView.frame.height)
                let newY = rubberBandedY + constrained

                let childFrame = self.view.convertRect(childView.frame, fromView: childView)
                let distanceFromBottom = childFrame.maxY - self.view.frame.maxY

                let minHeight = containerView.frame.height
                let newHeight = childView.frame.size.height - (distanceFromBottom - 2.0)
                childView.frame.size.height = max(minHeight, newHeight)
                containerView.transform = CGAffineTransformMakeTranslation(0.0, newY)

            case .Failed, .Cancelled:
                self.returnTopCardToStartPosition()

            case .Ended:
                if translation.y >= 25.0 && velocity.y > 0.0 {
                    self.popViewController(true, velocity: velocity.y)
                } else {
                    self.returnTopCardToStartPosition()
                }

            case .Possible: return
            }
        }
    }

    func returnTopCardToStartPosition() {
        if let card = self.topCard {
            let returnAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
            returnAnimation.toValue = self.offsetForCardAtIndex(0)
            returnAnimation.springSpeed = 12.0
            returnAnimation.springBounciness = 1.0
            card.views.containerView.layer.pop_addAnimation(returnAnimation, forKey: "returnAnimation")
        }
    }

    func cancelAnimations() {
        self.topCard?.views.containerView.layer.pop_removeAnimationForKey("returnAnimation")
        self.topCard?.views.containerView.layer.pop_removeAnimationForKey("presentAnimation")
        self.topCard?.views.containerView.layer.pop_removeAnimationForKey("dismissAnimation")
    }
}

// MARK: Appearance calculator
extension CardStackController {
    func offsetForCardAtIndex(i: Int) -> CGFloat {
        return self.cardAppearanceCalculator.offsetForCardAtIndex(i)
    }

    func scaleForCardAtIndex(i: Int) -> CGFloat {
        return self.cardAppearanceCalculator.scaleForCardAtIndex(i)
    }

    func opacityForCardAtIndex(i: Int) -> CGFloat {
        return self.cardAppearanceCalculator.opacityForCardAtIndex(i)
    }
}

extension CardStackController: UIScrollViewDelegate {
    func anchorDismissButtonToTop() {
        self.topCard?.layout.dismissButtonTopConstraint.constant = 0.0
    }

    func moveDismissButtonWithScrollViewOffset(contentOffset: CGPoint, verticalTopOffset: CGFloat) {

        self.topCard?.layout.dismissButtonTopConstraint.constant = verticalTopOffset - contentOffset.y
    }

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        let verticalTopOffset = self.cardAppearanceCalculator.verticalTopOffsetForTraitCollection(self.traitCollection)

        if contentOffset.y >= verticalTopOffset {
            self.anchorDismissButtonToTop()
        } else {
            self.moveDismissButtonWithScrollViewOffset(contentOffset, verticalTopOffset: verticalTopOffset)
        }
    }
}