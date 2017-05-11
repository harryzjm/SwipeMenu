//
//  ViewController.swift
//  Sample
//
//  Created by Magic on 9/5/2016.
//  Copyright © 2016 Magic. All rights reserved.
//

import UIKit
import SwipeMenu

class ViewController: UIViewController {
    
    var menu: SwipeMenu = SwipeMenu()
    
    let names = ["Facebook", "Apple", "Microsoft", "Tencent", "Twitter", "Github"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .random
        
        menu.dataSource = self
        menu.delegate = self
        view.addSubview(menu)
    }
}

extension ViewController: SwipeMenuDataSource, SwipeMenuDelegate {
    func numberOfItemsInMenu(_ menu: SwipeMenu) -> Int {
        return names.count
    }
    
    func menu(_ menu: SwipeMenu, titleForRow row: Int) -> String {
        return names[row]
    }
    
    func menu(_ menu: SwipeMenu, indicatorIconForRow row: Int) -> UIImage {
        return UIImage(named: names[row])!
    }
    
    func menu(_ menu: SwipeMenu, didSelectRow row: Int) {
        print("Select Row: ", row)
        view.backgroundColor = .random
    }
}

extension UIColor {
    class var random: UIColor {
        return UIColor(hue: CGFloat(arc4random_uniform(255)) / 255, saturation: 1, brightness: 1, alpha: 1)
    }
}
