# MOSheetTransition

[![CI Status](https://img.shields.io/travis/MunokKim/MOSheetTransition.svg?style=flat)](https://travis-ci.org/MunokKim/MOSheetTransition)
[![Version](https://img.shields.io/cocoapods/v/MOSheetTransition.svg?style=flat)](https://cocoapods.org/pods/MOSheetTransition)
[![SwiftPM](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
[![License](https://img.shields.io/cocoapods/l/MOSheetTransition.svg?style=flat)](https://cocoapods.org/pods/MOSheetTransition)
[![Platform](https://img.shields.io/cocoapods/p/MOSheetTransition.svg?style=flat)](https://cocoapods.org/pods/MOSheetTransition)

A library that customized iOS default pageSheet style transitions and interactions.

By using `UIViewControllerInteractiveTransitioning` and `UIViewPropertyAnimator`, interactive transitions are implemented in a form similar to `UIModalPresentationStyle`'s `.pageSheet`.

## Article

[Create iOS default pageSheet style transition and interaction](https://medium.com/@shoveler)

## Usage

Since `SheetTransitionController` adopts `UIViewControllerTransitioningDelegate` protocol, instantiate and assign it to `transitioningDelegate` property of the view controller to be present.
```swift
let vc = ViewController()
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
- Require iOS version 13

## Author

MunokKim, wer0222@naver.com

## License

MOSheetTransition is available under the MIT license. See the LICENSE file for more info.
