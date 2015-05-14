//
//  ColorWell.swift
//  ColorWell
//
//  Created by Florian Schliep on 14.05.15.
//  Copyright (c) 2015 Appiculous UG (haftungsbeschränkt). All rights reserved.
//

import Cocoa

private let BorderColor = NSColor(white: 0.4, alpha: 1.0)
private let CornerRadius: CGFloat = 4
private let MouseOverIndicatorSize: CGFloat = 13

protocol ColorWellDataSource {
    func numberOfRowsInColorWell(colorwell: ColorWell) -> UInt
    func numberOfColumnsInColorWell(colorwell: ColorWell) -> UInt
    func colorWell(colorwell: ColorWell, colorAtIndexPath indexPath: IndexPath) -> NSColor?
}

@IBDesignable class ColorWell: NSControl {
    
    @IBInspectable dynamic var color: NSColor? {
        didSet {
            self.updateColorWell()
            if self.target?.respondsToSelector(self.action) == true {
                NSApp.sendAction(self.action, to: self.target, from: self)
            }
            if self.popover.shown {
                self.popover.close()
            }
        }
    }
    var dataSource: ColorWellDataSource?
    override var frame: NSRect {
        didSet {
            self.colorCell.frame = self.bounds
        }
    }
    var selectedIndexPath: IndexPath? {
        didSet {
            if let color = self.dataSource?.colorWell(self, colorAtIndexPath: self.selectedIndexPath!) {
                self.color = color
            }
            self.colorGridView.selectedIndexPath = self.selectedIndexPath
        }
    }
    
// MARK: - Instance Variables
    
    private let popover = NSPopover()
    private let mouseOverIndicator = MouseOverIndicator()
    private let colorCell = CALayer()
    private var showMouseOverIndicator = false {
        didSet {
            self.updateColorWell()
        }
    }
    private let colorGridView = ColorGridView()
    
// MARK: - Instantiation
    
    init() {
        super.init(frame: NSZeroRect)
        self.setUp()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setUp()
    }
    
    private func setUp() {
        self.colorGridView.colorWell = self
        self.wantsLayer = true
        
        self.colorCell.masksToBounds = true
        self.colorCell.cornerRadius = CornerRadius
        self.colorCell.borderWidth = 1
        self.colorCell.borderColor = BorderColor.CGColor
        self.colorCell.zPosition = 1
        self.colorCell.frame = self.bounds
        self.layer!.addSublayer(self.colorCell)
        
        self.mouseOverIndicator.zPosition = 2
        self.mouseOverIndicator.setNeedsDisplay()
        
        self.addTrackingRect(self.bounds, owner: self, userData: nil, assumeInside: false)
        self.addToolTipRect(self.bounds, owner: self, userData: nil)
    }
    
// MARK: - Tooltips
    
    override func view(view: NSView, stringForToolTip tag: NSToolTipTag, point: NSPoint, userData data: UnsafeMutablePointer<Void>) -> String {
        if view == self {
            return "Click to choose a color";
        }
        
        return super.view(view, stringForToolTip: tag, point: point, userData: data)
    }
    
// MARK: - Appearance
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        self.updateColorWell()
    }
    
    private func updateColorWell() {
        if let color = self.color {
            self.colorCell.backgroundColor = color.CGColor
        }
        if self.showMouseOverIndicator {
            self.mouseOverIndicator.bounds = CGRectMake(0, 0, MouseOverIndicatorSize, MouseOverIndicatorSize)
            self.mouseOverIndicator.position = CGPointMake(NSMidX(self.bounds), NSMidY(self.bounds))
            self.colorCell.addSublayer(self.mouseOverIndicator)
        } else if self.mouseOverIndicator.superlayer != nil {
            self.mouseOverIndicator.removeFromSuperlayer()
        }
    }
    
// MARK: - Mouse
    
    override func mouseEntered(theEvent: NSEvent) {
        self.showMouseOverIndicator = true
    }
    
    override func mouseExited(theEvent: NSEvent) {
        self.showMouseOverIndicator = false
    }
    
    override func mouseUp(theEvent: NSEvent) {
        if self.popover.shown {
            self.popover.close()
        } else {
            
            let contentViewController = NSViewController()
            contentViewController.view = self.colorGridView
            
            self.popover.contentSize = self.colorGridView.intrinsicContentSize
            self.popover.contentViewController = contentViewController
            self.popover.animates = false
            self.popover.behavior = .Semitransient
            self.popover.showRelativeToRect(self.bounds, ofView: self, preferredEdge: NSMinYEdge)
        }
    }
    
// MARK: - IB
    
    override func drawRect(dirtyRect: NSRect) {
        #if TARGET_INTERFACE_BUILDER
        self.color?.setFill()
        BorderColor.setStroke()
        
        let bezierPath = NSBezierPath(roundedRect: NSInsetRect(self.bounds, 1, 1), xRadius: CornerRadius, yRadius: CornerRadius)
        bezierPath.lineWidth = 1
        bezierPath.fill()
        bezierPath.stroke()
        #endif
    }
    
}

// MARK: - MouseOverIndicator

class MouseOverIndicator: CALayer {
    
    override func drawInContext(ctx: CGContext!) {
        super.drawInContext(ctx)
        
        let ovalPath = CGPathCreateWithEllipseInRect(self.bounds, nil)
        CGContextAddPath(ctx, ovalPath)
        CGContextSetFillColorWithColor(ctx, NSColor(white: 0.4, alpha: 0.4).CGColor)
        CGContextFillPath(ctx)
        
        // draw "tick"
        let center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        let tickUnitLength: CGFloat = 3.0
        let secondPoint = CGPointMake(center.x, center.y - tickUnitLength/2)
        let firstPoint = CGPointMake(secondPoint.x - tickUnitLength, secondPoint.y + tickUnitLength)
        let thirdPoint = CGPointMake(secondPoint.x + tickUnitLength, secondPoint.y + tickUnitLength)
        
        let tickPath = CGPathCreateMutable()
        CGPathMoveToPoint(tickPath, nil, firstPoint.x, firstPoint.y)
        CGPathAddLineToPoint(tickPath, nil, secondPoint.x, secondPoint.y)
        CGPathAddLineToPoint(tickPath, nil, thirdPoint.x, thirdPoint.y)
        CGContextAddPath(ctx, tickPath)
        CGContextSetLineWidth(ctx, 1.0)
        CGContextSetStrokeColorWithColor(ctx, NSColor.whiteColor().CGColor)
        CGContextStrokePath(ctx)
    }
    
}

// MARK: - IndexPath

struct IndexPath {
    var column: UInt
    var row: UInt
}
