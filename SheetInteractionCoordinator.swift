//
//  SheetInteractionCoordinator.swift
//  EazelIOS
//
//  Created by eazel5 (Munok) on 2020/07/29.
//  Copyright © 2020 eazel. All rights reserved.
//
//  https://medium.com/@mshcheglov/delightful-interactive-animations-7a7823019c12
//

import UIKit
import Combine

/// 전환 컨트롤러에게 제스처를 전달받고 Interactive 전환 애니메이션을 조정합니다.
///
/// `UIViewControllerInteractiveTransitioning`를 채택하고 있어 `UIViewControllerContextTransitioning`의 애니메이션 진행율 조정 및 취소/완료를 수행할 수 있습니다.
class SheetInteractionCoordinator: NSObject {
    
    enum SheetState {
        case open
        case closed
        
        static prefix func !(_ state: SheetState) -> SheetState {
            return state == .open ? .closed : .open
        }
    }
    
    var coverUpAnimator: SheetAnimator?
    
    private var transitionContext: UIViewControllerContextTransitioning?
    private let transitioningObserver: PassthroughSubject<SheetTransitionController.TransitioningState, Never>
    /// 열거형으로 열림/닫힘의 상태를 전환할 수 있고 case를 추가하면 semi-open 등의 상태를 구현할 수 있습니다.
    private var state: SheetState = .open
    private var runningAnimators = [UIViewPropertyAnimator]()
    /// Sheet의 모양을 열거형 타입으로 가지고 있으며 Sheet의 전환을 스타일 별로 다르게 구현할 수 있습니다.
    private let sheetType: SheetTransitionController.SheetType
    private var totalAnimationDistance: CGFloat {
        guard let transitionContext = transitionContext
            else { return 0 }
        return transitionContext.containerView.bounds.height
    }
    
    init(
        observer: PassthroughSubject<SheetTransitionController.TransitioningState, Never>,
        type: SheetTransitionController.SheetType
    ) {
        self.transitioningObserver = observer
        self.sheetType = type
        
        super.init()
    }
    
    deinit {
        print("Deinit SheetInteractionCoordinator...")
    }
}

extension SheetInteractionCoordinator: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        updateUI(with: state, transitionContext: transitionContext)
        startInteractiveTransition(for: !state)
        transitioningObserver.send(.start)
    }
}

// MARK: - Pan Gesture Handling

extension SheetInteractionCoordinator {
    
    func didPanWith(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            let translation = recognizer.translation(in: recognizer.view!)
            updateInteractiveTransition(distanceTraveled: translation.y)
        case .ended:
            let distanceTraveled = recognizer.translation(in: recognizer.view!).y
            let velocity = recognizer.velocity(in: recognizer.view!).y
            let isCancelled = isGestureCancelled(with: velocity, distanceTraveled: distanceTraveled)
            continueInteractiveTransition(isCancel: isCancelled)
        case .cancelled, .failed:
            continueInteractiveTransition(isCancel: true)
        default: break
        }
    }
    
    // Perform all animations with animators
    private func startInteractiveTransition(for newState: SheetState) {
        state = newState
        runningAnimators = createTransitionAnimators(with: SheetInteractionCoordinator.animationDuration)
        runningAnimators.startAnimations()
        runningAnimators.pauseAnimations()
    }
    
    // Scrubs transition on pan .changed
    private func updateInteractiveTransition(distanceTraveled: CGFloat) {
        guard let transitionContext = self.transitionContext else { return }
        
        var fraction = distanceTraveled / totalAnimationDistance
        
        if state == .open { fraction *= -1 }
        
        runningAnimators.fractionComplete = fraction
        transitionContext.updateInteractiveTransition(fraction)
    }
    
    // Continues or reverse transition on pan .ended
    private func continueInteractiveTransition(isCancel: Bool) {
        if isCancel {
            runningAnimators.reverse()
            state = !state
        }

        runningAnimators.continueAnimations()
        transitioningObserver.send(.continue)
    }
    
    // Check if gesture is cancelled (reversed)
    private func isGestureCancelled(with velocity: CGFloat, distanceTraveled: CGFloat) -> Bool {
        let fraction = distanceTraveled / totalAnimationDistance
        let errorRange: CGFloat = 4000
        let judgmentCriteria = fraction * -errorRange + (errorRange / 2)
        let isPanningDownExactly = velocity > judgmentCriteria
        
        return (state == .open && isPanningDownExactly) || (state == .closed && !isPanningDownExactly)
    }
}

// MARK: - Animations

extension SheetInteractionCoordinator {
    
    private static let animationDuration = TimeInterval(1.0)
    
    private func createTransitionAnimators(with duration: TimeInterval) -> [UIViewPropertyAnimator] {
        switch state {
        case .open:
            switch self.sheetType {
            case .simple:
                return [openTranslationAnimator(with: duration)]
            case .normal:
                return [openTranslationAnimator(with: duration),
                        scaleDownAnimator(with: duration),
                        fadeOutAnimator(with: duration)]
            }
        case .closed:
            switch self.sheetType {
            case .simple:
                return [closeTranslationAnimator(with: duration)]
            case .normal:
                return [closeTranslationAnimator(with: duration),
                        scaleUpAnimator(with: duration),
                        fadeInAnimator(with: duration)]
            }
        }
    }
    
    private func openTranslationAnimator(with duration: TimeInterval) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0)
        animator.addAnimations {
            self.updateTranslationContainer(with: self.state)
        }
        animator.addCompletion(performTranslationCompletion(animator))
        
        return animator
    }
    
    private func closeTranslationAnimator(with duration: TimeInterval) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.9)
        animator.addAnimations {
            self.updateTranslationContainer(with: self.state)
        }
        animator.addCompletion(performTranslationCompletion(animator))
        
        return animator
    }
    
    private func scaleDownAnimator(with duration: TimeInterval) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0)
        animator.addAnimations {
            self.updateScaleContainer(with: self.state)
        }
        animator.addCompletion(performScaleCompletion(animator))
        
        return animator
    }
    
    private func scaleUpAnimator(with duration: TimeInterval) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.9)
        animator.addAnimations {
            self.updateScaleContainer(with: self.state)
        }
        animator.addCompletion(performScaleCompletion(animator))
        
        return animator
    }
    
    private func fadeOutAnimator(with duration: TimeInterval) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0)
        animator.addAnimations {
            self.updateAlphaDimView(with: self.state)
            self.updateFrameDimView(with: self.state)
        }
        animator.addCompletion(performAlphaCompletion(animator))

        return animator
    }

    private func fadeInAnimator(with duration: TimeInterval) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.9)
        animator.addAnimations {
            self.updateAlphaDimView(with: self.state)
            self.updateFrameDimView(with: self.state)
        }
        animator.addCompletion(performAlphaCompletion(animator))

        return animator
    }
    
    private func performTranslationCompletion(_ animator: UIViewPropertyAnimator) -> (_ animatingPosition: UIViewAnimatingPosition) -> Void {
        return { [unowned self] animatingPosition in
            guard let transitionContext = self.transitionContext,
                let toView = transitionContext.viewController(forKey: .to)?.view
                else { return }
            
            switch animatingPosition {
            case .start: transitionContext.cancelInteractiveTransition()
            case .end: transitionContext.finishInteractiveTransition()
            default: transitionContext.cancelInteractiveTransition()
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.transitioningObserver.send(transitionContext.transitionWasCancelled ? .cancel : .complete)
            
            if !transitionContext.transitionWasCancelled,
                transitionContext.view(forKey: .to) == nil {
                UIApplication.shared.keyWindowForActiveScene?.addSubview(toView)
            }
            
            self.runningAnimators.remove(animator)
            self.transitionContext = nil
        }
    }
    
    private func performScaleCompletion(_ animator: UIViewPropertyAnimator) -> (_ animatingPosition: UIViewAnimatingPosition) -> Void {
        return { [unowned self] animatingPosition in
            if animatingPosition == .end {
                self.coverUpAnimator?.backgroundWhiteView.removeFromSuperview()
            }
            
            self.runningAnimators.remove(animator)
        }
    }
    
    private func performAlphaCompletion(_ animator: UIViewPropertyAnimator) -> (_ animatingPosition: UIViewAnimatingPosition) -> Void {
        return { [unowned self] animatingPosition in
            if animatingPosition == .end {
                self.coverUpAnimator?.dimView.removeFromSuperview()
                self.coverUpAnimator?.dimView.alpha = 0.0
            }
            
            self.runningAnimators.remove(animator)
        }
    }
}

// MARK: - UI state rendering

extension SheetInteractionCoordinator {
    
    private func updateUI(
        with state: SheetState,
        transitionContext: UIViewControllerContextTransitioning
    ) {
        guard let toView = transitionContext.viewController(forKey: .to)?.view else { return }
        
        updateTranslationContainer(with: state)
        
        if sheetType == .normal {
            guard let animator = self.coverUpAnimator else { return }
            
            animator.backgroundWhiteView.frame = transitionContext.containerView.frame
            animator.dimView.frame = CGRect(x: 0,
                                            y: 0,
                                            width: transitionContext.containerView.frame.width,
                                            height: 0)
            
            if animator.backgroundWhiteView.superview == nil {
                transitionContext.containerView.insertSubview(animator.backgroundWhiteView, at: 0)
            }
            
//            transitionContext.containerView.insertSubview(toView, aboveSubview: animator.backgroundWhiteView)
            
            if animator.dimView.superview == nil {
                transitionContext.containerView.insertSubview(animator.dimView, aboveSubview: toView)
            }
            
            updateScaleContainer(with: state)
            updateAlphaDimView(with: state)
            updateFrameDimView(with: state)
        }
    }
    
    private func updateTranslationContainer(with state: SheetState) {
        guard let fromView = self.transitionContext?.viewController(forKey: .from)?.view
            else { return }
        
        fromView.transform = state == .open
            ? .identity
            : CGAffineTransform(translationX: 0, y: totalAnimationDistance)
    }
    
    private func updateScaleContainer(with state: SheetState) {
        guard let toView = self.transitionContext?.viewController(forKey: .to)?.view
            else { return }
        
        toView.transform = state == .open
            ? SheetAnimator.animationScale
            : .identity
    }
    
    private func updateAlphaDimView(with state: SheetState) {
        coverUpAnimator?.dimView.alpha = state == .open
            ? SheetAnimator.animationAlpha
            : 0.0
    }
    
    private func updateFrameDimView(with state: SheetState) {
        coverUpAnimator?.dimView.frame.size.height = state == .open
            ? 0.0
            : totalAnimationDistance
    }
}
