# MOSheetTransition

[![CI Status](https://img.shields.io/travis/MunokKim/MOSheetTransition.svg?style=flat)](https://travis-ci.org/MunokKim/MOSheetTransition)
[![Version](https://img.shields.io/cocoapods/v/MOSheetTransition.svg?style=flat)](https://cocoapods.org/pods/MOSheetTransition)
[![License](https://img.shields.io/cocoapods/l/MOSheetTransition.svg?style=flat)](https://cocoapods.org/pods/MOSheetTransition)
[![Platform](https://img.shields.io/cocoapods/p/MOSheetTransition.svg?style=flat)](https://cocoapods.org/pods/MOSheetTransition)

A library that customized iOS default pageSheet style transitions and interactions.

## Article



## Usage
Since `SheetTransitionController` adopts `UIViewControllerTransitioningDelegate` protocol, instantiate and assign it to `transitioningDelegate` property of the view controller to be present.
```swift
let vc = ViewController()
vc.transitionController = SheetTransitionController(for: self, style: .original)
vc.transitioningDelegate = vc.transitionController

present(vc, animated: true, completion: nil)
```

## Example

Clone the repository and run the example project in the `Example` directory.

## Installation

MOSheetTransition is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MOSheetTransition'
```

## Requirements
- Require iOS version 13

## Author

MunokKim, wer0222@naver.com

## License

MOSheetTransition is available under the MIT license. See the LICENSE file for more info.
