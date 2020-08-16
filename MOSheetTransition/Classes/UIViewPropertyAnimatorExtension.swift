//
//  UIViewPropertyAnimatorExtension.swift
//  EazelIOS
//
//  Created by eazel5 (Munok) on 2020/07/22.
//  Copyright © 2020 eazel. All rights reserved.
//
//  https://medium.com/@mshcheglov/delightful-interactive-animations-7a7823019c12
//

import UIKit

extension Array where Element: UIViewPropertyAnimator {
    
    var isReversed: Bool {
        set {
            forEach { $0.isReversed = newValue }
        }
        get {
            assertionFailure("The getter is not supported!")
            return false
        }
    }
    
    var fractionComplete: CGFloat {
        set {
            forEach { $0.fractionComplete = newValue }
        }
        get {
            assertionFailure("The getter is not supported!")
            return 0
        }
    }
    
    func startAnimations() {
        forEach { $0.startAnimation() }
    }
    
    func pauseAnimations() {
        forEach { $0.pauseAnimation() }
    }
    
    func continueAnimations(withTimingParameters parameters: UITimingCurveProvider? = nil, durationFactor: CGFloat = 0) {
        forEach { $0.continueAnimation(withTimingParameters: parameters, durationFactor: durationFactor) }
    }
    
    func reverse() {
        forEach { $0.isReversed = !$0.isReversed }
    }
    
    mutating func remove(_ element: Element) {
        self = self.filter { $0 != element }
    }
}
