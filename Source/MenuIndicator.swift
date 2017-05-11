//
//  MenuIndicator.swift
//  Sample
//
//  Created by Magic on 9/5/2016.
//  Copyright © 2016 Magic. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

private let MenuIndicatorZPosition: CGFloat = 998

class MenuIndicator : UIView {
    fileprivate var imageView = UIImageView()
    
    var size = CGSize(width: 44, height: 40)
    static var ShapeColor = DefautColor
    
    fileprivate var rightConstraint: Constraint?
    fileprivate var leftConstraint: Constraint?
    fileprivate var edgeWidth: CGFloat { return rint( size.width * 0.382 ) }
    
    override func draw(_ frame: CGRect) {
        let path = UIBezierPath(roundedRect: frame, cornerRadius: 15)
        path.close()
        MenuIndicator.ShapeColor.setFill()
        path.fill()
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        backgroundColor = .clear
        layer.zPosition = MenuIndicatorZPosition
        
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            let wh = min(size.width, size.height) * 0.618
            make.width.height.equalTo(wh)
            make.center.equalTo(self)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superV = superview else { return }
        
        snp.makeConstraints { (make) in
            make.top.equalTo(superV)
            make.size.equalTo(size)
            
            leftConstraint = make.left.equalTo(superV).offset(-edgeWidth).constraint
            rightConstraint = make.right.equalTo(superV).offset(edgeWidth).constraint
        }
        leftConstraint?.deactivate()
        
    }
}

enum IndicatorChange {
    case origin
    case y(CGFloat)
    case edge
    case show(CGFloat)
}

extension MenuIndicator {
    func updateImage(_ image:UIImage) { imageView.image = image }
    
    func update(_ change: IndicatorChange, side: SwipeMenuSide) {
        switch change {
        case .origin:
            m_animate(middle:size.width, final: edgeWidth, side: side)
        case .y(let y):
            snp.updateConstraints { $0.top.equalTo(y) }
        case .edge:
            m_animate(middle:edgeWidth, final: 0.0, side: side)
        case .show(let width):
            m_animate(0, middle:-width, final: size.width - width, side: side)
        }
    }
    
    fileprivate func m_animate(_ initial: CGFloat? = nil,  middle: CGFloat, final: CGFloat, side: SwipeMenuSide) {
        guard let superV = superview else { return }
        (side == .left ? rightConstraint:leftConstraint)?.deactivate()
        guard let constraint = side == .left ? leftConstraint:rightConstraint else { return }
        constraint.activate()
        
        if let initialValue = initial {
            constraint.update(offset: initialValue)
            superV.layoutIfNeeded()
        }
        
        let middleVlaue = middle * CGFloat( side.rawValue )
        let finalValue = final * CGFloat( side.rawValue )
        
        constraint.update(offset: middleVlaue)
        UIView.animate(withDuration: 0.2, delay:0, options: [.curveEaseIn], animations: { () -> Void in
            superV.layoutIfNeeded()
        }) { (finished) -> Void in
            constraint.update(offset: finalValue)
            UIView.animate(withDuration: 0.3, delay:0, options: [.curveEaseOut], animations: { () -> Void in
                superV.layoutIfNeeded()
                }, completion: nil)
        }
    }
}


