//
//  DrawerAnimationController.swift
//  CustomNav
//
//  Created by Sulaiman Alromaih on 05/02/2026.
//

import Foundation
import UIKit

// MARK: -

class DrawerAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    let operation: UINavigationController.Operation
    private var propertyAnimator: UIViewPropertyAnimator?
    
    init(operation: UINavigationController.Operation) {
        self.operation = operation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return operation == .push ? 0.5 : 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let container = transitionContext.containerView
        let isPushing = operation == .push
        let parallaxDistance = fromView.bounds.width / 50
        
        if isPushing {
            fromView.frame = container.bounds
            toView.frame = container.bounds
            toView.transform = CGAffineTransform(translationX: container.bounds.width, y: 0)
            fromView.transform = .identity
            
            container.addSubview(fromView)
            container.addSubview(toView)
            
            let timingParameters: UITimingCurveProvider = transitionContext.isInteractive
            ? UICubicTimingParameters(animationCurve: .linear)
            : UICubicTimingParameters(animationCurve: .easeOut)
            
            let animator = UIViewPropertyAnimator(
                duration: transitionDuration(using: transitionContext),
                timingParameters: timingParameters
            )
            animator.scrubsLinearly = false
            
            animator.addAnimations {
                toView.transform = .identity
                fromView.transform = CGAffineTransform(translationX: -parallaxDistance, y: 0)
            }
            
            animator.addCompletion { position in
                fromView.transform = .identity
                
                let completed = (position == .end)
                transitionContext.completeTransition(completed && !transitionContext.transitionWasCancelled)
            }
            
            self.propertyAnimator = animator
            
            if transitionContext.isInteractive {
                animator.pauseAnimation()
                animator.fractionComplete = 0
            } else {
                animator.startAnimation()
            }
            
        } else {
            toView.frame = container.bounds
            fromView.frame = container.bounds
            toView.transform = CGAffineTransform(translationX: -parallaxDistance, y: 0)
            fromView.transform = .identity
            
            container.addSubview(toView)
            container.addSubview(fromView)
            
            let animator = UIViewPropertyAnimator(
                duration: transitionDuration(using: transitionContext),
                curve: .linear
            )
            animator.scrubsLinearly = false
            
            animator.addAnimations {
                fromView.transform = CGAffineTransform(translationX: container.bounds.width, y: 0)
                toView.transform = .identity
            }
            
            animator.addCompletion { position in
                fromView.transform = .identity
                toView.transform = .identity
                
                if transitionContext.transitionWasCancelled {
                    toView.removeFromSuperview()
                } else {
                    fromView.removeFromSuperview()
                }
                
                let completed = (position == .end)
                transitionContext.completeTransition(completed && !transitionContext.transitionWasCancelled)
            }
            
            self.propertyAnimator = animator
            
            if transitionContext.isInteractive {
                animator.pauseAnimation()
                animator.fractionComplete = 0
            } else {
                animator.startAnimation()
            }
        }
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let animator = propertyAnimator {
            return animator
        }
        
        animateTransition(using: transitionContext)
        return propertyAnimator ?? UIViewPropertyAnimator(duration: 0.35, curve: .linear)
    }
}
