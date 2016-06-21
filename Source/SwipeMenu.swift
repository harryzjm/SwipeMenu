//
//  SwipeMenu.swift
//  Sample
//
//  Created by Magic on 9/5/2016.
//  Copyright © 2016 Magic. All rights reserved.
//

import UIKit

public enum SwipeMenuSide : Int {
    case Left = -1
    case Right = 1
    
    private var reverse: SwipeMenuSide { return self == .Left ? .Right:.Left }
    private var edges: UIRectEdge { return self == .Left ? .Left:.Right }
}

@objc public protocol SwipeMenuDelegate {
    optional func menu(menu: SwipeMenu, didSelectRow row: Int)
}

@objc public protocol SwipeMenuDataSource {
    func numberOfItemsInMenu(menu: SwipeMenu) -> Int
    func menu(menu: SwipeMenu, titleForRow row: Int) -> String
    
    optional func menu(menu: SwipeMenu, indicatorIconForRow row: Int) -> UIImage
}

private let RightCellIdentifier = "SwipeMenuRightCellIdentifier"
private let LeftCellIdentifier = "SwipeMenuLeftCellIdentifier"
private let SwipeMenuZPosition: CGFloat = 997

let DefautColor = UIColor(red:0.13, green:0.08, blue:0.29, alpha:1)

public class SwipeMenu : UIView {
    
    weak public var dataSource: SwipeMenuDataSource?
    weak public var delegate: SwipeMenuDelegate?
    
    var indicatorColor = DefautColor {
        didSet{
            MenuCell.SelectColor = indicatorColor
            MenuIndicator.ShapeColor = indicatorColor
        }
    }

    public private(set) var selectedRow: Int = 0
    public private(set) var openingSide: SwipeMenuSide = .Right
    public var menuItemHigh: CGFloat = 60
    
    private var cellIdentifier = LeftCellIdentifier
    private var preSelectedRow: Int?
    
    private var menuOriginalY: CGFloat = 0.0
    private var panOriginalY: CGFloat = 0.0
    
    //MARK:- UI
    private lazy var effectV: UIVisualEffectView = {
        let e = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        e.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        return e
    }()
    
    private lazy var tableV: UITableView = {
        let v = UITableView()
        v.delegate = self
        v.dataSource = self
        
        v.backgroundColor = .clearColor()
        v.separatorStyle = .None
        
        v.registerClass(RightMenuCell.self, forCellReuseIdentifier: RightCellIdentifier)
        v.registerClass(LeftMenuCell.self, forCellReuseIdentifier: LeftCellIdentifier)
        return v
    }()
    
    private lazy var indicator: MenuIndicator = {
        let i = MenuIndicator()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SwipeMenu.longPressGes(_:)))
        i.addGestureRecognizer(longPress)
        
        return i
    }()
    
    //MARK:- Calculate Property
    private var itemNumber: Int { return dataSource?.numberOfItemsInMenu(self) ?? 0 }
    private func iconFor(row: Int) -> UIImage? { return dataSource?.menu?(self, indicatorIconForRow: row) }
    
    //MARK:- Gesture
    private var leftSidePan: UIScreenEdgePanGestureRecognizer = {
        let ges = UIScreenEdgePanGestureRecognizer()
        ges.edges = .Left
        return ges
    }()
    private var rightSidePan: UIScreenEdgePanGestureRecognizer = {
        let ges = UIScreenEdgePanGestureRecognizer()
        ges.edges = .Right
        return ges
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        hidden = true
        backgroundColor = .clearColor()
        layer.zPosition = SwipeMenuZPosition
        addSubview(effectV)
        
        leftSidePan.addTarget(self, action: #selector(SwipeMenu.panGes(_:)))
        rightSidePan.addTarget(self, action: #selector(SwipeMenu.panGes(_:)))
        
        addSubview(tableV)
        
        tableV.snp_makeConstraints { (make) in
            make.top.right.left.equalTo(self)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToSuperview() {
        guard let superV = superview else { return }
        
        superV.addSubview(indicator)
        
        snp_makeConstraints { (make) in
            make.edges.equalTo(superV)
        }
        
        tableV.snp_updateConstraints { (make) in
            make.height.equalTo(menuItemHigh * CGFloat( itemNumber ))
        }
        
        superV.addGestureRecognizer(leftSidePan)
        superV.addGestureRecognizer(rightSidePan)
    }
    
    private func updateMenuTable(y: CGFloat) {
        tableV.snp_updateConstraints { $0.top.equalTo(y) }
    }
    
    public func showMenu() {
        hidden = false
        alpha = 1
        superview?.layoutIfNeeded()
    }
    
    public func hideMenu() {
        indicator.update(.Origin, side: openingSide)

        weak var view = self
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            view?.alpha = 0
            }, completion: { (finished) -> Void in
                if view?.alpha < 0.1 { view?.hidden = true }
        })
    }

    func sideChanged() {
        openingSide = openingSide.reverse
        cellIdentifier = openingSide == .Left ? RightCellIdentifier:LeftCellIdentifier
        tableV.reloadData()
    }
    
    private func updateIndicatorsForRow(row: Int) {
        let offset = tableV.frame.origin.y + CGFloat(row) * menuItemHigh + (menuItemHigh - indicator.size.height) / 2
        indicator.update(.Y(offset), side: openingSide)
        guard let image = iconFor(row) else { return }
        indicator.updateImage(image)
    }
    
    //Gesture Method
    @objc private func longPressGes(ges: UIGestureRecognizer) {
        guard let indicator = ges.view as? MenuIndicator else { return }
        let location = ges.locationInView(self)
        let side: SwipeMenuSide = location.x / frame.width > 0.5 ? .Right:.Left
        
        if side != openingSide {
            sideChanged()
            indicator.update(.Edge, side: side)
        }
        
        switch ges.state {
        case .Began:
            indicator.update(.Edge, side: side)
        case .Changed:
            let value = location.y - (indicator.size.height / 2)
            indicator.update(.Y(value), side: side)
        case .Ended:
            fallthrough
        case .Cancelled:
            fallthrough
        case .Failed:
            let value = location.y - (indicator.size.height / 2)
            indicator.update(.Y(value), side: side)
            indicator.update(.Origin, side: side)
        default:
            break
        }
    }
    
    @objc private func panGes(ges: UIScreenEdgePanGestureRecognizer) {
        let location = ges.locationInView(ges.view)
        
        switch ges.state {
        case .Began:
            panGestureBegan(location, ges: ges)
        case .Changed:
            panGestureChange(location)
        case .Ended:
            fallthrough
        case .Cancelled:
            fallthrough
        case .Failed:
            panGestureEnd(location)
        default:
            break
        }
    }
    
    private func panGestureBegan(location: CGPoint, ges: UIScreenEdgePanGestureRecognizer) {
        if ges.edges != openingSide.edges {
            sideChanged()
        }
        
        showMenu()
        indicator.update(.Show(frame.size.width), side: openingSide)
        
        panOriginalY = location.y
        
        menuOriginalY = location.y - ((menuItemHigh * CGFloat(selectedRow)) + (menuItemHigh/2))
        
        updateMenuTable(menuOriginalY)
    }
    
    private func panGestureChange(location: CGPoint) {
        let newYconstant = menuOriginalY + panOriginalY - location.y
        
        updateMenuTable(newYconstant)
        
        var matchIndex = Int(rint((location.y - newYconstant) / menuItemHigh))
        matchIndex = min(max(matchIndex,0), itemNumber - 1)
        
        if preSelectedRow !=  matchIndex {
            cellFor(preSelectedRow)?.style = preSelectedRow == selectedRow ? .Selected:.Normal
            preSelectedRow = matchIndex
            cellFor(matchIndex)?.style = .Highlighted
        }
        
        updateIndicatorsForRow(matchIndex)
    }
    
    private func panGestureEnd(location: CGPoint) {
        cellFor(selectedRow)?.style = .Normal
        cellFor(preSelectedRow)?.style = .Normal
        selectedRow = preSelectedRow ?? 0
        cellFor(selectedRow)?.style = .Selected
        preSelectedRow = nil
        
        delegate?.menu?(self, didSelectRow: selectedRow)
        updateIndicatorsForRow(selectedRow)
        hideMenu()
    }
}

extension SwipeMenu: UITableViewDelegate, UITableViewDataSource {
    private func cellFor(row: Int?) -> MenuCell? {
        guard let cRow = row else { return nil }
        let index = NSIndexPath(forRow: cRow, inSection: 0)
        return tableV.cellForRowAtIndexPath(index) as? MenuCell
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemNumber
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MenuCell
        
        cell.style = indexPath.row == selectedRow ? .Selected:.Normal
        cell.iconV.image = iconFor(indexPath.row)?.changeImage(MenuCell.SelectColor)
        cell.titleLb.text = dataSource?.menu(self, titleForRow: indexPath.row)
        
        return cell
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return menuItemHigh
    }
}

extension SwipeMenu: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

private extension UIImage {
    func changeImage(color: UIColor) -> UIImage {
        let width = size.width * scale
        let high = size.height * scale
        let bounds = CGRect(x: 0, y: 0, width: width, height: high)
        
        let context = CGBitmapContextCreate(nil, Int(width), Int(high), 8, 0, CGColorSpaceCreateDeviceRGB(), CGImageAlphaInfo.PremultipliedLast.rawValue)
        CGContextClipToMask(context, bounds, CGImage)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, bounds)
        let newCGImage = CGBitmapContextCreateImage(context)
        return UIImage(CGImage: newCGImage!, scale: scale, orientation: imageOrientation)
    }
}
