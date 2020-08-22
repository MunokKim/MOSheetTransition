//
//  SheetAnimator.swift
//
//  Created by Munok Kim on 2020/07/28.
//  Copyright © 2020 eazel. All rights reserved.
//

import UIKit
import Combine

/// Present/Dismiss를 위한 애니메이션이 구현되어 있습니다. (non-interactive)
class SheetAnimator: NSObject {
    
    var isPresenting: Bool = true
    
    static let animationAlpha: CGFloat = 0.5
    static let animationScale = CGAffineTransform(scaleX: 0.9, y: 0.9)
    static let animationCornerRadius: CGFloat = 15.0
    
    /// 전환의 진행 상태를 열거형 타입으로 가지고 있으며 각 상태가 바뀔 때를 구독할 수 있습니다.
    private let transitioningObserver: PassthroughSubject<SheetTransitionController.TransitioningState, Never>
    /// Sheet가 표현되는 모양에 대한 열거형 타입을 가지고 있으며 Sheet의 전환을 스타일 별로 다르게 구현할 수 있습니다.
    private let sheetStyle: SheetTransitionController.SheetStyle
    
    let dimmedView: UIView = {
        $0.backgroundColor = .black
        $0.alpha = 0.0
        
        return $0
    }(UIView())
    
    init(
        observer: PassthroughSubject<SheetTransitionController.TransitioningState, Never>,
        style: SheetTransitionController.SheetStyle
    ) {
        self.transitioningObserver = observer
        self.sheetStyle = style
        
        super.init()
    }
    
    private func prepareForCoverUp(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
        }
        
        let container = transitionContext.containerView
        let screenOffDown = CGAffineTransform(translationX: 0, y: container.frame.height)
        
        dimmedView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: container.frame.width,
                                  height: container.frame.height)

        container.addSubview(fromVC.view)
        container.addSubview(dimmedView)
        container.addSubview(toVC.view)
        
        if DeviceInfo.isPhone {
            fromVC.view.clipsToBounds = true
            fromVC.view.layer.cornerRadius = DeviceInfo.cornerRadius
            fromVC.view.layer.cornerCurve = .continuous
        }
        
        if DeviceInfo.hasNotch || DeviceInfo.isPad {
            toVC.view.clipsToBounds = true
            toVC.view.layer.cornerRadius = SheetAnimator.animationCornerRadius
            toVC.view.layer.cornerCurve = .continuous
        }
        
        toVC.view.transform = screenOffDown
    }
    
    func animateCoverUpTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
        }
        
        transitioningObserver.send(.start)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        
                        toVC.view.transform = .identity
                        
                        switch self.sheetStyle {
                        case .original:
                            if DeviceInfo.isPhone {
                                fromVC.view.transform = SheetAnimator.animationScale
                                fromVC.view.layer.cornerRadius = SheetAnimator.animationCornerRadius
                            }
                            self.dimmedView.alpha = SheetAnimator.animationAlpha
                        case .onlyDim:
                            self.dimmedView.alpha = SheetAnimator.animationAlpha
                        default: break
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
        
        let container = transitionContext.containerView
        let screenOffDown = CGAffineTransform(translationX: 0, y: container.frame.height)
        
        transitioningObserver.send(.start)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        
                        fromVC.view.transform = screenOffDown
                        
                        switch self.sheetStyle {
                        case .original:
                            if DeviceInfo.isPhone {
                                toVC.view.transform = .identity
                                toVC.view.layer.cornerRadius = DeviceInfo.cornerRadius
                            }
                            self.dimmedView.alpha = 0.0
                        case .onlyDim:
                            self.dimmedView.alpha = 0.0
                        default: break
                        }
        }) { (success) in
            fromVC.view.transform = .identity
            self.dimmedView.removeFromSuperview()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.transitioningObserver.send(.complete)
            
            if !transitionContext.transitionWasCancelled,
                transitionContext.view(forKey: .to) == nil {
                UIApplication.shared.keyWindow?.addSubview(toVC.view)
            }
        }
    }
}

extension SheetAnimator: UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            prepareForCoverUp(using: transitionContext)
            animateCoverUpTransition(using: transitionContext)
        } else {
            animateDiscoverDownTransition(using: transitionContext)
        }
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
