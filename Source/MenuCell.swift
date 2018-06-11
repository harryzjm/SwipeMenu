//
//  MenuCell.swift
//  Sample
//
//  Created by Magic on 9/5/2016.
//  Copyright © 2016 Magic. All rights reserved.
//

import UIKit

class LeftMenuCell: MenuCell {
    fileprivate override func initialize() {
        super.initialize()
        iconV.translatesAutoresizingMaskIntoConstraints = false
        iconV.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconV.leftAnchor.constraint(equalTo: leftAnchor, constant: margin).isActive = true
        iconV.rightAnchor.constraint(equalTo: titleLb.leftAnchor, constant: -margin).isActive = true
        iconV.widthAnchor.constraint(equalToConstant: 30).isActive = true
        iconV.heightAnchor.constraint(equalToConstant: 30).isActive = true

        titleLb.translatesAutoresizingMaskIntoConstraints = false
        titleLb.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        titleLb.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLb.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

class RightMenuCell: MenuCell {
    fileprivate override func initialize() {
        super.initialize()
        titleLb.textAlignment = .right
        
        iconV.translatesAutoresizingMaskIntoConstraints = false
        iconV.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconV.leftAnchor.constraint(equalTo: titleLb.rightAnchor, constant: margin).isActive = true
        iconV.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin).isActive = true
        iconV.widthAnchor.constraint(equalToConstant: 30).isActive = true
        iconV.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        titleLb.translatesAutoresizingMaskIntoConstraints = false
        titleLb.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        titleLb.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLb.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

enum CellStyle {
    case normal, highlighted, selected
}

open class MenuCell: UITableViewCell {
    static var SelectColor = kDefautColor
    fileprivate let margin: CGFloat = 10
    
    var style: CellStyle = .normal {
        didSet {
            switch style {
            case .normal:       titleLb.textColor = .lightGray
            case .highlighted:  titleLb.textColor = MenuCell.SelectColor.withAlphaComponent(0.618)
            case .selected:     titleLb.textColor = MenuCell.SelectColor
            }
        }
    }
    
    let iconV = UIImageView()
    let titleLb = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        backgroundColor = .clear
        addSubview(iconV)
        addSubview(titleLb)
    }
    
}
