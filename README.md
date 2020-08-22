# MOSheetTransition

[![CI Status](https://img.shields.io/travis/MunokKim/MOSheetTransition.svg?style=flat)](https://travis-ci.org/MunokKim/MOSheetTransition)
[![Version](https://img.shields.io/cocoapods/v/MOSheetTransition.svg?style=flat)](https://cocoapods.org/pods/MOSheetTransition)
[![SwiftPM](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
[![License](https://img.shields.io/cocoapods/l/MOSheetTransition.svg?style=flat)](https://cocoapods.org/pods/MOSheetTransition)
[![Platform](https://img.shields.io/cocoapods/p/MOSheetTransition.svg?style=flat)](https://cocoapods.org/pods/MOSheetTransition)

![](./Images/example.gif)

## About

A library that customized iOS default pageSheet style transitions and interactions.

By using `UIViewControllerInteractiveTransitioning` and `UIViewPropertyAnimator`, interactive transitions are implemented in a form similar to `UIModalPresentationStyle`'s `.pageSheet`.

## Article

[iOS 기본 pageSheet 스타일의 전환 및 인터렉션 만들기](https://medium.com/@shoveler/ios-%EA%B8%B0%EB%B3%B8-pagesheet-%EC%8A%A4%ED%83%80%EC%9D%BC%EC%9D%98-%EC%A0%84%ED%99%98-%EB%B0%8F-%EC%9D%B8%ED%84%B0%EB%A0%89%EC%85%98-%EB%A7%8C%EB%93%A4%EA%B8%B0-8f7607d211ef?source=friends_link&sk=77d55b62906280889b549d28be464806)

## Usage

Since `SheetTransitionController` adopts `UIViewControllerTransitioningDelegate` protocol, instantiate and assign it to `transitioningDelegate` property of the view controller to be present.
```swift
let vc = ViewController()
vc.modalPresentationStyle = .custom
// `ViewController` must have a `transitionController` property.
vc.transitionController = SheetTransitionController(for: self, style: .original)
vc.transitioningDelegate = vc.transitionController

present(vc, animated: true, completion: nil)
```

## Example

Clone the repository and run the example project in the `Example` directory.

## Installation

### Cocoapods

MOSheetTransition is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MOSheetTransition'
```

### Swift Package Manager

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler. It is in early development, but MOSheetTransition does support its use on supported platforms.

Once you have your Swift package set up, adding MOSheetTransition as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift
dependencies: [
    .package(url: "https://github.com/MunokKim/MOSheetTransition.git", .upToNextMajor(from: "0.2.0"))
]
```

## Requirements
- iOS 13 +

## Author

MunokKim, wer0222@naver.com

## License

MOSheetTransition is available under the MIT license. See the LICENSE file for more info.
