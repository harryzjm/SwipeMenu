//
//  SwipeMenu.swift
//  Sample
//
//  Created by Magic on 9/5/2016.
//  Copyright © 2016 Magic. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


public enum SwipeMenuSide : Int {
    case left = -1
    case right = 1
    
    fileprivate var reverse: SwipeMenuSide { return self == .left ? .right:.left }
    fileprivate var edges: UIRectEdge { return self == .left ? .left:.right }
}

@objc public protocol SwipeMenuDelegate {
    @objc optional func menu(_ menu: SwipeMenu, didSelectRow row: Int)
}

@objc public protocol SwipeMenuDataSource {
    func numberOfItems(in menu: SwipeMenu) -> Int
    func menu(_ menu: SwipeMenu, titleForRow row: Int) -> String
    
    @objc optional func menu(_ menu: SwipeMenu, indicatorIconForRow row: Int) -> UIImage
}

private let RightCellIdentifier = "SwipeMenuRightCellIdentifier"
private let LeftCellIdentifier = "SwipeMenuLeftCellIdentifier"
private let SwipeMenuZPosition: CGFloat = 997

let DefautColor = UIColor(red:0.13, green:0.08, blue:0.29, alpha:1)

open class SwipeMenu : UIView {
    
    weak open var dataSource: SwipeMenuDataSource?
    weak open var delegate: SwipeMenuDelegate?
    
    var indicatorColor = DefautColor {
        didSet{
            MenuCell.SelectColor = indicatorColor
            MenuIndicator.ShapeColor = indicatorColor
        }
    }

    open fileprivate(set) var selectedRow: Int = 0
    open fileprivate(set) var openingSide: SwipeMenuSide = .right
    open var menuItemHigh: CGFloat = 60
    
    fileprivate var cellIdentifier = LeftCellIdentifier
    fileprivate var preSelectedRow: Int?
    
    fileprivate var menuOriginalY: CGFloat = 0.0
    fileprivate var panOriginalY: CGFloat = 0.0
    
    //MARK:- UI
    fileprivate lazy var effectV: UIVisualEffectView = {
        let e = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        e.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return e
    }()
    
    fileprivate lazy var tableV: UITableView = {
        let v = UITableView()
        v.delegate = self
        v.dataSource = self
        
        v.backgroundColor = .clear
        v.separatorStyle = .none
        
        v.register(RightMenuCell.self, forCellReuseIdentifier: RightCellIdentifier)
        v.register(LeftMenuCell.self, forCellReuseIdentifier: LeftCellIdentifier)
        return v
    }()
    
    fileprivate lazy var indicator: MenuIndicator = {
        let i = MenuIndicator()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SwipeMenu.longPressGes(_:)))
        i.addGestureRecognizer(longPress)
        
        return i
    }()
    
    //MARK:- Calculate Property
    fileprivate var itemNumber: Int { return dataSource?.numberOfItems(in: self) ?? 0 }
    fileprivate func iconFor(_ row: Int) -> UIImage? { return dataSource?.menu?(self, indicatorIconForRow: row) }
    
    //MARK:- Gesture
    fileprivate var leftSidePan: UIScreenEdgePanGestureRecognizer = {
        let ges = UIScreenEdgePanGestureRecognizer()
        ges.edges = .left
        return ges
    }()
    fileprivate var rightSidePan: UIScreenEdgePanGestureRecognizer = {
        let ges = UIScreenEdgePanGestureRecognizer()
        ges.edges = .right
        return ges
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isHidden = true
        backgroundColor = .clear
        layer.zPosition = SwipeMenuZPosition
        addSubview(effectV)
        
        leftSidePan.addTarget(self, action: #selector(SwipeMenu.panGes(_:)))
        rightSidePan.addTarget(self, action: #selector(SwipeMenu.panGes(_:)))
        
        addSubview(tableV)
        
        tableV.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(self)
            make.height.equalTo(0)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func didMoveToSuperview() {
        guard let superV = superview else { return }
        
        superV.addSubview(indicator)
        
        snp.makeConstraints { (make) in
            make.edges.equalTo(superV)
        }
        
        tableV.snp.updateConstraints { (make) in
            make.height.equalTo(menuItemHigh * CGFloat( itemNumber ))
        }
        
        superV.addGestureRecognizer(leftSidePan)
        superV.addGestureRecognizer(rightSidePan)
    }
    
    fileprivate func updateMenuTable(_ y: CGFloat) {
        tableV.snp.updateConstraints { $0.top.equalTo(y) }
    }
    
    open func showMenu() {
        isHidden = false
        alpha = 1
        superview?.layoutIfNeeded()
    }
    
    open func hideMenu() {
        indicator.update(.origin, side: openingSide)

        weak var view = self
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            view?.alpha = 0
            }, completion: { (finished) -> Void in
                if view?.alpha < 0.1 { view?.isHidden = true }
        })
    }

    func sideChanged() {
        openingSide = openingSide.reverse
        cellIdentifier = openingSide == .left ? RightCellIdentifier:LeftCellIdentifier
        tableV.reloadData()
    }
    
    fileprivate func updateIndicatorsForRow(_ row: Int) {
        let offset = tableV.frame.origin.y + CGFloat(row) * menuItemHigh + (menuItemHigh - indicator.size.height) / 2
        indicator.update(.y(offset), side: openingSide)
        guard let image = iconFor(row) else { return }
        indicator.updateImage(image)
    }
    
    //Gesture Method
    @objc fileprivate func longPressGes(_ ges: UIGestureRecognizer) {
        guard let indicator = ges.view as? MenuIndicator else { return }
        let location = ges.location(in: self)
        let side: SwipeMenuSide = location.x / frame.width > 0.5 ? .right:.left
        
        if side != openingSide {
            sideChanged()
            indicator.update(.edge, side: side)
        }
        
        switch ges.state {
        case .began:
            indicator.update(.edge, side: side)
        case .changed:
            let value = location.y - (indicator.size.height / 2)
            indicator.update(.y(value), side: side)
        case .ended:
            fallthrough
        case .cancelled:
            fallthrough
        case .failed:
            let value = location.y - (indicator.size.height / 2)
            indicator.update(.y(value), side: side)
            indicator.update(.origin, side: side)
        default:
            break
        }
    }
    
    @objc fileprivate func panGes(_ ges: UIScreenEdgePanGestureRecognizer) {
        let location = ges.location(in: ges.view)
        
        switch ges.state {
        case .began:
            panGestureBegan(location, ges: ges)
        case .changed:
            panGestureChange(location)
        case .ended:
            fallthrough
        case .cancelled:
            fallthrough
        case .failed:
            panGestureEnd(location)
        default:
            break
        }
    }
    
    fileprivate func panGestureBegan(_ location: CGPoint, ges: UIScreenEdgePanGestureRecognizer) {
        if ges.edges != openingSide.edges {
            sideChanged()
        }
        
        showMenu()
        indicator.update(.show(frame.size.width), side: openingSide)
        
        panOriginalY = location.y
        
        menuOriginalY = location.y - ((menuItemHigh * CGFloat(selectedRow)) + (menuItemHigh/2))
        
        updateMenuTable(menuOriginalY)
    }
    
    fileprivate func panGestureChange(_ location: CGPoint) {
        let newYconstant = menuOriginalY + panOriginalY - location.y
        
        updateMenuTable(newYconstant)
        
        var matchIndex = Int(rint((location.y - newYconstant) / menuItemHigh))
        matchIndex = min(max(matchIndex,0), itemNumber - 1)
        
        if preSelectedRow !=  matchIndex {
            cellFor(preSelectedRow)?.style = preSelectedRow == selectedRow ? .selected:.normal
            preSelectedRow = matchIndex
            cellFor(matchIndex)?.style = .highlighted
        }
        
        updateIndicatorsForRow(matchIndex)
    }
    
    fileprivate func panGestureEnd(_ location: CGPoint) {
        cellFor(selectedRow)?.style = .normal
        cellFor(preSelectedRow)?.style = .normal
        selectedRow = preSelectedRow ?? 0
        cellFor(selectedRow)?.style = .selected
        preSelectedRow = nil
        
        delegate?.menu?(self, didSelectRow: selectedRow)
        updateIndicatorsForRow(selectedRow)
        hideMenu()
    }
}

extension SwipeMenu: UITableViewDelegate, UITableViewDataSource {
    fileprivate func cellFor(_ row: Int?) -> MenuCell? {
        guard let cRow = row else { return nil }
        let index = IndexPath(row: cRow, section: 0)
        return tableV.cellForRow(at: index) as? MenuCell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemNumber
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MenuCell
        
        cell.style = indexPath.row == selectedRow ? .selected:.normal
        cell.iconV.image = iconFor(indexPath.row)?.changeImage(MenuCell.SelectColor)
        cell.titleLb.text = dataSource?.menu(self, titleForRow: indexPath.row)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return menuItemHigh
    }
}

extension SwipeMenu: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

private extension UIImage {
    func changeImage(_ color: UIColor) -> UIImage {
        let width = size.width * scale
        let high = size.height * scale
        let bounds = CGRect(x: 0, y: 0, width: width, height: high)
        
        let context = CGContext(data: nil, width: Int(width), height: Int(high), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.clip(to: bounds, mask: cgImage!)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        let newCGImage = context.makeImage()
        return UIImage(cgImage: newCGImage!, scale: scale, orientation: imageOrientation)
    }
}
