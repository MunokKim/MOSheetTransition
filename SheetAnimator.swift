//
//  SheetAnimator.swift
//  EazelIOS
//
//  Created by eazel5 (Munok) on 2020/07/28.
//  Copyright © 2020 eazel. All rights reserved.
//

import UIKit
import Combine

/// Present/Dismiss를 위한 애니메이션이 구현되어 있습니다. (non-interactive)
class SheetAnimator: NSObject {
    
    var isPresenting: Bool = true
    
    static let animationScale = CGAffineTransform(scaleX: 0.9, y: 0.9)
    static let animationAlpha: CGFloat = 0.5
    
    let backgroundWhiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        
        return view
    }()
    
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.0
        
        return view
    }()
    
    private let transitioningObserver: PassthroughSubject<SheetTransitionController.TransitioningState, Never>
    /// Sheet의 모양을 열거형 타입으로 가지고 있으며 Sheet의 전환을 스타일 별로 다르게 구현할 수 있습니다.
    private let sheetType: SheetTransitionController.SheetType
    
    init(
        observer: PassthroughSubject<SheetTransitionController.TransitioningState, Never>,
        type: SheetTransitionController.SheetType
    ) {
        self.transitioningObserver = observer
        self.sheetType = type
        
        super.init()
    }
    
    func animateCoverUpTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
        }
        
        let container = transitionContext.containerView
        let screenOffDown = CGAffineTransform(translationX: 0, y: container.frame.height)
        
        transitioningObserver.send(.start)

        container.addSubview(toVC.view)
        
        toVC.view.transform = screenOffDown
        
        if sheetType == .normal {
            backgroundWhiteView.frame = transitionContext.containerView.frame
            dimView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: transitionContext.containerView.frame.width,
                                   height: transitionContext.containerView.frame.height)
            
            container.insertSubview(backgroundWhiteView, at: 0)
            container.insertSubview(fromVC.view, aboveSubview: backgroundWhiteView)
            container.insertSubview(dimView, aboveSubview: fromVC.view)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        
                        toVC.view.transform = .identity
                        
                        if self.sheetType == .normal {
                            fromVC.view.transform = SheetAnimator.animationScale
                            self.dimView.alpha = SheetAnimator.animationAlpha
                            self.dimView.frame.size.height = 0
                        }
        }) { (success) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.transitioningObserver.send(.complete)
        }
    }
    
    func animateDiscoverDownTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
        }
        
        let isExistToView = transitionContext.view(forKey: .to) != nil
        
        let container = transitionContext.containerView
        let screenOffDown = CGAffineTransform(translationX: 0, y: container.frame.height)
        
        transitioningObserver.send(.start)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        
                        fromVC.view.transform = screenOffDown
                        
                        if self.sheetType == .normal {
                            toVC.view.transform = .identity
                            self.dimView.alpha = 0.0
                            self.dimView.frame.size.height = container.frame.height
                        }
        }) { (success) in
            fromVC.view.transform = .identity
            self.backgroundWhiteView.removeFromSuperview()
            self.dimView.removeFromSuperview()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            if !isExistToView {
                UIApplication.shared.keyWindowForActiveScene?.addSubview(toVC.view)
            }
            
            self.transitioningObserver.send(.complete)
        }
    }
}

extension SheetAnimator: UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        return self.isPresenting
            ? animateCoverUpTransition(using: transitionContext)
            : animateDiscoverDownTransition(using: transitionContext)
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.isPresenting ? 0.55 : 0.5
    }
}

extension UIApplication {
    var keyWindowForActiveScene: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map {$0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }
}
