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
    private override func configCell() {
        super.configCell()
        
        iconV.snp_updateConstraints { (make) in
            make.left.equalTo(self).offset(margin)
            make.right.equalTo(titleLb.snp_left).offset(-margin)
        }
        
        titleLb.snp_updateConstraints { (make) in
            make.right.equalTo(self)
        }
    }
}

class RightMenuCell: MenuCell {
    private override func configCell() {
        super.configCell()
        titleLb.textAlignment = .Right
        titleLb.snp_updateConstraints { (make) in
            make.left.equalTo(self)
        }
        iconV.snp_updateConstraints { (make) in
            make.left.equalTo(titleLb.snp_right).offset(margin)
            make.right.equalTo(self).offset(-margin)
        }
    }
}

enum CellStyle {
    case Normal, Highlighted, Selected
}

public class MenuCell: UITableViewCell {
    static var SelectColor = DefautColor
    private let margin = 10
    
    var style: CellStyle = .Normal {
        didSet {
            switch style {
            case .Normal:       titleLb.textColor = .lightGrayColor()
            case .Highlighted:  titleLb.textColor = MenuCell.SelectColor.colorWithAlphaComponent(0.618)
            case .Selected:     titleLb.textColor = MenuCell.SelectColor
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
    
    private func configCell() {
        backgroundColor = .clearColor()
        addSubview(iconV)
        addSubview(titleLb)
        iconV.snp_makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.centerY.equalTo(self)
        }
        titleLb.snp_makeConstraints { (make) in
            make.top.bottom.equalTo(self)
        }
    }
}
