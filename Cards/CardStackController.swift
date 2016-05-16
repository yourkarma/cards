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

/**
 A representation of a card used internally by the view controller.
 */
struct Card {
    /**
     The child view controller represented by this card.
     */
    let viewController: UIViewController
    
    /**
     The views required to visualy represent the card.
     */
    var views: CardHierarchy
    
    /**
     The constraints on the card that can be changed during it's lifetime.
     */
    var layout: CardLayout
}

struct CardHierarchy {
    /**
     The view that is added directly to the card stack controller's view.
     It is the superview of all the other views.
     */
    let containerView: UIView
    
    /**
     The dismiss button displayed at the top of each card.
     It is automatically configured to dismiss the card.
     */
    let dismissButton: UIButton
    
    /**
     The scroll view that makes each card's content vertically scrollable.
     */
    let scrollView: CardScrollView
    
    /**
     The view that is responsible for giving each card the top rounded corners.
     */
    let maskView: CardMaskView
    
    /**
     A reference to the child view controller's view property.
     */
    let childView: UIView
}

/**
 Hold the constraints for each card that can change during it's lifetime.
 */
struct CardLayout {
    /**
     The contraints that are affected by a trait change.
     */
    var constraintsAffectedByTraitChange: [NSLayoutConstraint]
    
    /**
     Constraint that holds to dismiss button at the top of the card.
     Used to keep the dismiss button at the top, it's constant is changed to keep
     the dimiss button visible while scrolling.
     */
    var dismissButtonTopConstraint: NSLayoutConstraint
    
    /**
     Constraint that keeps the mask view stuck to the bottom of the card.
     Used to make it appear as if the card is infinitely long when rubber
     bounding passed it's bounds.
     */
    var maskViewBottomConstraint: NSLayoutConstraint
    
    
    /**
     Not used anymore
     */
    var childHeightConstraint: NSLayoutConstraint
}

extension UIViewController {
    
    
    /**
     The nearest ancestor in the view controller hierarchy that is a card stack controller.
     If the view controller or one of its ancestors is a child of a card stack controller, this property contains the owning card stack controller.
     This property is nil if the view controller is not embedded inside a card stack controller.
     */
    public var cardStackController: CardStackController? {
        if let cardStackController = self.parentViewController as? CardStackController {
            return cardStackController
        } else {
            return self.parentViewController?.cardStackController
        }
    }
}

public protocol CardStackControllerDelegate: class {
    func cardWillAppear()
    func cardDidAppear()
    func cardWillDisappear()
    func cardDidDisappear()
}

public class CardStackController: UIViewController {
    /**
     The view controller at the top of the card stack.
     */
    public var topViewController: UIViewController? {
        return self.topCard?.viewController
    }
    
    /**
     The card stack controller delegate
     */
    public weak var delegate: CardStackControllerDelegate?
    
    /**
     Wether the top view controller can be dismissed using the dismiss button.
     Note: A view controller can still be dismissed using `popViewControllerAnimated:completion:`.
     */
    public var topViewControllerCanBeDismissed: Bool {
        get {
            return self.topCard?.views.dismissButton.enabled ?? false
        }
        set {
            self.topCard?.views.dismissButton.enabled = newValue
        }
    }
    
    /**
     A reference to the top card's scroll view.
     */
    public var topScrollView: UIScrollView? {
        return self.topCard?.views.scrollView
    }
    
    /**
     The first card's vertical offset from the top of the receiver's view.
     */
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
    
    /**
     Pushes a view controller onto the receiver’s stack and updates the display.
     
     Parameters:
     - viewController: The view controller to push onto the stack.
     - animated: Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the card stack controller at launch time.
     - completion: The block to execute after the presentation finishes.
     */
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
    
    /**
     Pops the top view controller from the card stack and updates the display.
     Parameters:
     - animated: Set this value to true to animate the transition. Pass false if you are setting up a card stack controller before its view is displayed.
     - completion: The block to execute after the view controller is dismissed.
     
     */
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
    
    public override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        for card in self.cards {
            card.layout.constraintsAffectedByTraitChange.forEach {
                $0.constant = self.cardAppearanceCalculator.verticalTopOffsetForTraitCollection(newCollection)
            }
            card.layout.childHeightConstraint.constant = -self.cardAppearanceCalculator.verticalTopOffsetForTraitCollection(newCollection)
        }
        
        self.topCard?.views.maskView.willAnimate = true
        coordinator.animateAlongsideTransition(nil, completion: { _ in
            self.topCard?.views.maskView.willAnimate = false
        })
    }
    
    public override func showDetailViewController(viewController: UIViewController, sender: AnyObject?) {
        let topViewController: UIViewController?
        let topContainerView: UIView?
        
        if let topCard = self.topCard {
            topViewController = topCard.viewController
            topContainerView = topCard.views.containerView
        } else {
            topViewController = self.rootViewController
            topContainerView = topViewController?.view
        }
        topViewController?.beginAppearanceTransition(false, animated: false)
        
        let hierarchy = self.makeHierarchyForChildView(viewController.view)
        let layout = self.constrainHierarchy(hierarchy)
        
        let replacementCard = Card(viewController: viewController, views: hierarchy, layout: layout)
        replacementCard.views.maskView.backgroundColor = .clearColor()
        
        self.cards.removeLast()
        
        self.addChildViewController(viewController)
        self.presentCard(replacementCard, overCards: self.cards, animated: false) {
            let replacementContainerView = replacementCard.views.containerView
            replacementContainerView.transform = CGAffineTransformMakeTranslation(0.0, self.view.frame.height)
            
            let transformAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
            transformAnimation.duration = 0.25
            transformAnimation.toValue = 0.0
            replacementContainerView.layer.pop_addAnimation(transformAnimation, forKey: "transformAnimation")
            replacementCard.views.maskView.backgroundColor = viewController.view.backgroundColor
            
            transformAnimation.completionBlock = { _ in
                topContainerView?.removeFromSuperview()
                viewController.didMoveToParentViewController(self)
                topViewController?.endAppearanceTransition()
            }
        }
        
    }
    
    func presentCard(card: Card, overCards cards: [Card], animated: Bool, completion: (() -> Void)) {
        let containerView = card.views.containerView
        self.delegate?.cardWillAppear()
        
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
                self.delegate?.cardDidAppear()
                completion()
            }
            
        } else {
            self.cardStackTransitionCoordinator?.transitionDidEnd()
            self.delegate?.cardDidAppear()
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
        self.delegate?.cardWillDisappear()
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
                self.delegate?.cardDidDisappear()
                completion()
            }
            
        } else {
            containerView.removeFromSuperview()
            self.cardStackTransitionCoordinator?.transitionDidEnd()
            self.cardStackTransitionCoordinator = nil
            self.delegate?.cardDidDisappear()
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
        
        let scrollView = CardScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        scrollView.delaysContentTouches = false
        
        let maskView = CardMaskView()
        maskView.translatesAutoresizingMaskIntoConstraints = false
        maskView.backgroundColor = childView.backgroundColor
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        let dismissButton = self.makeDismissButton()
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        
        maskView.addSubview(childView)
        scrollView.addSubview(maskView)
        scrollView.addSubview(dismissButton)
        containerView.addSubview(scrollView)
        
        return CardHierarchy(containerView: containerView, dismissButton: dismissButton, scrollView: scrollView, maskView: maskView, childView: childView)
    }
    
    func constrainHierarchy(hierarchy: CardHierarchy) -> CardLayout {
        let verticalTopOffset = self.cardAppearanceCalculator.verticalTopOffsetForTraitCollection(self.traitCollection)
        
        let dismissButton = hierarchy.dismissButton
        let maskView = hierarchy.maskView
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
        
        let childScrollWidthConstraint = NSLayoutConstraint(item: childView, attribute: .Width, relatedBy: .Equal, toItem: containerView, attribute: .Width, multiplier: 1.0, constant: 0.0)
        let childScrollHeightConstraint = NSLayoutConstraint(item: childView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: containerView, attribute: .Height, multiplier: 1.0, constant: -verticalTopOffset)
        let childSizeConstraints = [childScrollWidthConstraint, childScrollHeightConstraint]
        containerView.addConstraints(childSizeConstraints)
        
        let maskViewTopConstraint = NSLayoutConstraint(item: maskView, attribute: .Top, relatedBy: .Equal, toItem: childView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let maskViewBottomConstraint = NSLayoutConstraint(item: maskView, attribute: .Bottom, relatedBy: .Equal, toItem: childView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let maskViewLeadingConstraint = NSLayoutConstraint(item: maskView, attribute: .Leading, relatedBy: .Equal, toItem: childView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let maskViewTrailingConstraint = NSLayoutConstraint(item: maskView, attribute: .Trailing, relatedBy: .Equal, toItem: childView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let maskViewConstraints = [maskViewTopConstraint, maskViewBottomConstraint, maskViewLeadingConstraint, maskViewTrailingConstraint]
        containerView.addConstraints(maskViewConstraints)
        
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
        
        return CardLayout(constraintsAffectedByTraitChange: [childScrollTopConstraint, dismissButtonTopConstraint], dismissButtonTopConstraint: dismissButtonTopConstraint, maskViewBottomConstraint: maskViewBottomConstraint, childHeightConstraint: childScrollHeightConstraint)
        
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
    
    func makeBackgroundExtendOffset(offset: CGFloat) {
        self.topCard?.layout.maskViewBottomConstraint.constant = offset
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
        guard scrollView == self.topCard?.views.scrollView else { return }
        
        let contentOffset = scrollView.contentOffset
        let verticalTopOffset = self.cardAppearanceCalculator.verticalTopOffsetForTraitCollection(self.traitCollection)
        
        if contentOffset.y >= verticalTopOffset {
            self.anchorDismissButtonToTop()
        } else {
            self.moveDismissButtonWithScrollViewOffset(contentOffset, verticalTopOffset: verticalTopOffset)
            
            if !self.topViewControllerCanBeDismissed {
                scrollView.contentOffset.y = 0.0
            }
        }
        
        let bottomOffset = scrollView.bounds.maxY - scrollView.contentSize.height
        if bottomOffset >= 0 {
            self.makeBackgroundExtendOffset(bottomOffset)
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let contentOffset = scrollView.contentOffset
        let velocity = scrollView.panGestureRecognizer.velocityInView(self.view)
        if self.topViewControllerCanBeDismissed && ((contentOffset.y <= 25.0 && velocity.y > 0.0) || velocity.y >= 4000.0) {
            self.popViewController(true, velocity: velocity.y)
        }
    }
}