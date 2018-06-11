//
//  UIView+Layout.swift
//  SwipeMenu
//
//  Created by Magic on 9/6/2017.
//  Copyright © 2017 Magic. All rights reserved.
//

import Foundation

extension UIView {
    func edgesEqualTo(constant: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: constant.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: constant.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: constant.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: constant.bottomAnchor).isActive = true
    }
}
