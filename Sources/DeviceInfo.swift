//
//  DeviceInfo.swift
//  Pods
//
//  Created by 김문옥 on 2020/08/22.
//

import UIKit

struct DeviceInfo {
    static let maxWH = max(UIScreen.main.bounds.size.width,
                           UIScreen.main.bounds.size.height)
    static let isPhone = UIDevice.current.userInterfaceIdiom == .phone
    static let isPad = UIDevice.current.userInterfaceIdiom == .pad
    static let isIPhoneX = isPhone && maxWH == 812.0
    static let isIPhoneXRMax = isPhone && maxWH == 896.0
    static var hasNotch: Bool {
        return isIPhoneX || isIPhoneXRMax
    }
    /// https://kylebashour.com/posts/finding-the-real-iphone-x-corner-radius
    static var cornerRadius: CGFloat {
        return hasNotch ? 38.5 : 0.0001
    }
}
