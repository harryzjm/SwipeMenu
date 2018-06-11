<p align="center" >
  <img src="./Logo/hummingbird.jpg">
</p>  

Swipe Menu
===============

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

SwipeMenu is a simple, strong, fast menu and also easy to use in your iOS app.  

![show](./Logo/SwipeMenu.gif)  

## Requirements

- iOS 9.0+
- Xcode 8.0
- Swift 3.1
ps: Because of `NSLayoutAnchor`, so it up to iOS 9.0

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate SwipeMenu into your Xcode project using Carthage, specify it in your `Cartfile`:

```swift
github "harryzjm/SwipeMenu"
```

Run `carthage` to build the framework and drag the built `SwipeMenu.framework` and `SnapKit.framework` into your Xcode project.

#### Source File

Simply add the file in Source directory into your project.

## Usage

### Creating and Add

```swift
import SwipeMenu

let menu = SwipeMenu()
view.addSubview(menu)


```

### Must Perfect SwipeMenuDataSource  
SwipeMenuDataSource will be used to provide menu data source.  

```swift
@objc public protocol SwipeMenuDataSource {
    func numberOfItemsInMenu(menu: SwipeMenu) -> Int
    func menu(menu: SwipeMenu, titleForRow row: Int) -> String
    
    optional func menu(menu: SwipeMenu, indicatorIconForRow row: Int) -> UIImage
}
```

### May be you want SwipeMenuDelegate  
SwipeMenuDelegate will be used to select action.  

```swift
@objc public protocol SwipeMenuDelegate {
    optional func menu(menu: SwipeMenu, didSelectRow row: Int)
}
```

## Communication

- If you **need help**, open an issue or send an email.
- If you **found a bug**, open an issue or send an email.
- If you'd like to **ask a question**,open an issue or send an email.
- If you **want to contribute**, submit a pull request.

## License

SwipeMenu is released under the MIT license. See LICENSE for details.

##  Author😬  

🇨🇳[Hares - https://github.com/harryzjm](https://github.com/harryzjm)  
Email: **angel-i@outlook.com**
