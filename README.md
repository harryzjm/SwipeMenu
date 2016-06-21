Swipe Menu
===============

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

###Idear from [cariocamenu](https://github.com/arn00s/cariocamenu).👍  


![show](./Logo/SwipeMenu.gif)  

###SwipeMenu is a simple, strong, fast menu and also easy to use in your iOS app.  

## Requirements

- iOS 8.0+
- Xcode 7.0

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

## License

SwipeMenu is released under the MIT license. See LICENSE for details.
