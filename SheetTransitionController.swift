//
//  SheetTransitionController.swift
//  EazelIOS
//
//  Created by eazel5 (Munok) on 2020/07/28.
//  Copyright © 2020 eazel. All rights reserved.
//

import UIKit
import Combine

/// Present/Dismiss를 위한 interactive/non-interactive 전환을 컨트롤 한다.
///
/// - `UIViewControllerTransitioningDelegate` 프로토콜을 채택하고 있으므로 인스턴스화하여 Present 할 뷰컨트롤러의 `transitioningDelegate` 속성에 할당해서 사용한다.
open class SheetTransitionController: NSObject {
    
    enum TransitioningState {
        case start
        case `continue`
        case cancel
        case complete
    }
    
    public enum SheetType {
        case normal
        case simple
    }
    
    /// 전환의 진행 상태를 열거형 타입으로 가지고 있으며 뷰컨트롤러에서 각 진행 상태가 바뀔 때를 구독할 수 있습니다.
    let transitioningState: AnyPublisher<TransitioningState, Never>
    /// 팬제스처 인식기를 가지고 있고 `UIGestureRecognizerDelegate`의 메서드를 통해 제스처를 관리하고 인터렉션 조정자에게 제스처를 전달합니다.
    lazy var panGestureRecognizer: UIPanGestureRecognizer = createPanGestureRecognizer()
    
    /// non-interactive 애니메이션을 담당하는 객체입니다.
    private let animator: SheetAnimator
    /// interactive 애니메이션을 조정하는 객체입니다.
    private let interactor: SheetInteractionCoordinator
    private var isInteracting: Bool = false
    private weak var toViewController: UIViewController!
    
    public init(for viewController: UIViewController, type: SheetType = .normal) {
        let subject = PassthroughSubject<TransitioningState, Never>()
        
        self.transitioningState = subject.eraseToAnyPublisher()
        self.animator = SheetAnimator(observer: subject,
                                      type: type)
        self.interactor = SheetInteractionCoordinator(observer: subject,
                                                      type: type)
        self.toViewController = viewController
        
        super.init()
        
        viewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    deinit {
        print("Deinit CoverUpTransitionController.")
    }
}

extension SheetTransitionController: UIGestureRecognizerDelegate {
    
    private func createPanGestureRecognizer() -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(didPanWith(recognizer:)))
        recognizer.delegate = self
        
        return recognizer
    }
    
    @objc func didPanWith(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            self.isInteracting = true
            self.toViewController.dismiss(animated: true, completion: nil)
        case .ended:
            if self.isInteracting {
                self.isInteracting = false
                self.interactor.didPanWith(recognizer: recognizer)
            }
        default:
            if self.isInteracting {
                self.interactor.didPanWith(recognizer: recognizer)
            }
        }
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view)
        
        return abs(velocity.y) > abs(velocity.x)
    }
    
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view)
        
        if otherGestureRecognizer is UIPanGestureRecognizer,
            let scrollView = otherGestureRecognizer.view as? UIScrollView,
            scrollView.contentOffset.y == 0,
            velocity.y > 0 {
            otherGestureRecognizer.state = .failed
            
            return true
        }
        
        return false
    }
}

extension SheetTransitionController: UIViewControllerTransitioningDelegate {
    
    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = true
        
        return animator
    }
    
    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = false
        
        return animator
    }
    
    public func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        self.interactor.coverUpAnimator = self.animator
        
        return self.isInteracting ? self.interactor : nil
    }
}
