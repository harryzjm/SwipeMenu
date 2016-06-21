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
    private var imageView = UIImageView()
    
    var size = CGSizeMake(44, 40)
    static var ShapeColor = DefautColor
    
    private var rightConstraint: Constraint?
    private var leftConstraint: Constraint?
    private var edgeWidth: CGFloat { return rint( size.width * 0.382 ) }
    
    override func drawRect(frame: CGRect) {
        let path = UIBezierPath(roundedRect: frame, cornerRadius: 15)
        path.closePath()
        MenuIndicator.ShapeColor.setFill()
        path.fill()
    }
    
    init() {
        super.init(frame: CGRectMake(0, 0, size.width, size.height))
        backgroundColor = .clearColor()
        layer.zPosition = MenuIndicatorZPosition
        
        imageView.contentMode = .ScaleAspectFit
        addSubview(imageView)
        imageView.snp_makeConstraints { (make) in
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
        
        snp_makeConstraints { (make) in
            make.top.equalTo(superV)
            make.size.equalTo(size)
            
            leftConstraint = make.left.equalTo(superV).offset(-edgeWidth).constraint
            rightConstraint = make.right.equalTo(superV).offset(edgeWidth).constraint
        }
        leftConstraint?.deactivate()
        
    }
}

enum IndicatorChange {
    case Origin
    case Y(CGFloat)
    case Edge
    case Show(CGFloat)
}

extension MenuIndicator {
    func updateImage(image:UIImage) { imageView.image = image }
    
    func update(change: IndicatorChange, side: SwipeMenuSide) {
        switch change {
        case .Origin:
            m_animate(middle:size.width, final: edgeWidth, side: side)
        case .Y(let y):
            snp_updateConstraints { $0.top.equalTo(y) }
        case .Edge:
            m_animate(middle:edgeWidth, final: 0.0, side: side)
        case .Show(let width):
            m_animate(0, middle:-width, final: size.width - width, side: side)
        }
    }
    
    private func m_animate(initial: CGFloat? = nil,  middle: CGFloat, final: CGFloat, side: SwipeMenuSide) {
        guard let superV = superview else { return }
        (side == .Left ? rightConstraint:leftConstraint)?.deactivate()
        guard let constraint = side == .Left ? leftConstraint:rightConstraint else { return }
        constraint.activate()
        
        if let initialValue = initial {
            constraint.updateOffset(initialValue)
            superV.layoutIfNeeded()
        }
        
        let middleVlaue = middle * CGFloat( side.rawValue )
        let finalValue = final * CGFloat( side.rawValue )
        
        constraint.updateOffset(middleVlaue)
        UIView.animateWithDuration(0.2, delay:0, options: [.CurveEaseIn], animations: { () -> Void in
            superV.layoutIfNeeded()
        }) { (finished) -> Void in
            constraint.updateOffset(finalValue)
            UIView.animateWithDuration(0.3, delay:0, options: [.CurveEaseOut], animations: { () -> Void in
                superV.layoutIfNeeded()
                }, completion: nil)
        }
    }
}


