//
//  MenuCell.swift
//  Sample
//
//  Created by Magic on 9/5/2016.
//  Copyright © 2016 Magic. All rights reserved.
//

import UIKit
import SnapKit

class LeftMenuCell: MenuCell {
    fileprivate override func configCell() {
        super.configCell()
        
        iconV.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(margin)
            make.right.equalTo(titleLb.snp.left).offset(-margin)
            make.width.height.equalTo(30)
            make.centerY.equalTo(self)
        }
        
        titleLb.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.top.bottom.equalTo(self)
        }
    }
}

class RightMenuCell: MenuCell {
    fileprivate override func configCell() {
        super.configCell()
        titleLb.textAlignment = .right
        titleLb.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.top.bottom.equalTo(self)
        }
        iconV.snp.makeConstraints { (make) in
            make.left.equalTo(titleLb.snp.right).offset(margin)
            make.right.equalTo(self).offset(-margin)
            make.width.height.equalTo(30)
            make.centerY.equalTo(self)
        }
    }
}

enum CellStyle {
    case normal, highlighted, selected
}

open class MenuCell: UITableViewCell {
    static var SelectColor = DefautColor
    fileprivate let margin = 10
    
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
        configCell()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configCell()
    }
    
    fileprivate func configCell() {
        backgroundColor = .clear
        addSubview(iconV)
        addSubview(titleLb)
    }
}
