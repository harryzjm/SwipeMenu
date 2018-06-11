//
//  MenuIndicator.swift
//  Sample
//
//  Created by Magic on 9/5/2016.
//  Copyright © 2016 Magic. All rights reserved.
//

import Foundation
import UIKit

private let kMenuIndicatorZPosition: CGFloat = 998

class MenuIndicator : UIView {
    fileprivate var imageView = UIImageView()
    
    var size = CGSize(width: 44, height: 40)
    static var ShapeColor = kDefautColor
    
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
        layer.zPosition = kMenuIndicatorZPosition
        
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        let wh = min(size.width, size.height) * 0.618
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: wh).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: wh).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var indicatorLeft: NSLayoutConstraint? { willSet{ indicatorLeft?.isActive = false; newValue?.isActive = true } }
    fileprivate var indicatorRight: NSLayoutConstraint? { willSet{ indicatorRight?.isActive = false; newValue?.isActive = true } }
    fileprivate var indicatorTop: NSLayoutConstraint? { willSet{ indicatorTop?.isActive = false; newValue?.isActive = true } }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superV = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        indicatorTop = topAnchor.constraint(equalTo: superV.topAnchor)
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
        indicatorLeft = leftAnchor.constraint(equalTo: superV.leftAnchor, constant: -edgeWidth)
        indicatorLeft?.isActive = false
        indicatorRight = rightAnchor.constraint(equalTo: superV.rightAnchor, constant: edgeWidth)
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
            indicatorTop?.constant = y
        case .edge:
            m_animate(middle:edgeWidth, final: 0.0, side: side)
        case .show(let width):
            m_animate(0, middle:-width, final: size.width - width, side: side)
        }
    }
    
    fileprivate func m_animate(_ initial: CGFloat? = nil,  middle: CGFloat, final: CGFloat, side: SwipeMenuSide) {
        guard let superV = superview else { return }
        (side == .left ? indicatorRight:indicatorLeft)?.isActive = false
        guard let constraint = side == .left ? indicatorLeft:indicatorRight else { return }
        constraint.isActive = true
        
        if let initialValue = initial {
            constraint.constant = initialValue
            superV.layoutIfNeeded()
        }
        
        let middleVlaue = middle * CGFloat( side.rawValue )
        let finalValue = final * CGFloat( side.rawValue )
        
        constraint.constant = middleVlaue
        UIView.animate(withDuration: 0.2, delay:0, options: [.curveEaseIn], animations: { () -> Void in
            superV.layoutIfNeeded()
        }) { (finished) -> Void in
            constraint.constant = finalValue
            UIView.animate(withDuration: 0.3, delay:0, options: [.curveEaseOut], animations: { () -> Void in
                superV.layoutIfNeeded()
                }, completion: nil)
        }
    }
}


