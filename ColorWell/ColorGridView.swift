//
//  ColorGridView.swift
//  ColorWell
//
//  Created by Florian Schliep on 14.05.15.
//  Copyright (c) 2015 Appiculous UG (haftungsbeschränkt). All rights reserved.
//

import Cocoa

private let CellSpacing: CGFloat = 2
private let CellWidth: CGFloat = 44
private let CellHeight: CGFloat = 23
private let BorderColor = NSColor(white: 0.4, alpha: 1.0)
private let BorderPadding: CGFloat = 6
private let CornerRadius: CGFloat = 4

class ColorGridView: NSView {

    var colorWell: ColorWell?
    var selectedIndexPath: IndexPath?
    private var cells = Array<Array<CALayer?>?>()
    
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
        self.wantsLayer = true
        self.updateCells()
    }
    
// MARK: - Appearance
    
    override var needsDisplay: Bool {
        didSet {
            self.updateCells()
        }
    }
    
    private func updateCells() {
        if self.colorWell == nil || self.colorWell?.dataSource == nil {
            return
        }
        
        let columns = self.colorWell!.dataSource!.numberOfColumnsInColorWell(self.colorWell!)
        let rows = self.colorWell!.dataSource!.numberOfRowsInColorWell(self.colorWell!)
        var indexPath: IndexPath?
        
        for column in 0...columns-1 {
            for row in 0...rows-1 {
                if let color = self.colorWell!.dataSource!.colorWell(self.colorWell!, colorAtIndexPath: IndexPath(column: column, row: row)) {
                    let cell: CALayer
                    if count(self.cells) >= Int(column)+1 && count(self.cells[Int(column)]!) >= Int(row)+1 {
                        cell = self.cells[Int(column)]![Int(row)]!
                    } else {
                        cell = CALayer()
                        if count(self.cells) < Int(column)+1 {
                            self.cells.insert([CALayer?](), atIndex: Int(column))
                        }
                        self.cells[Int(column)]!.insert(cell, atIndex: Int(row))
                        self.layer!.addSublayer(cell)
                    }
                    
                    cell.frame = self.frameForCellAtColumn(column, inRow: row)
                    cell.masksToBounds = true
                    cell.cornerRadius = CornerRadius
                    cell.borderWidth = 1
                    cell.borderColor = BorderColor.CGColor
                    cell.backgroundColor = color.CGColor
                    
                    if let selectedIndexPath = self.selectedIndexPath {
                        if selectedIndexPath.row == row && selectedIndexPath.column == column {
                            cell.borderWidth = 2
                            cell.borderColor = NSColor.whiteColor().CGColor
                        }
                    }
                }
            }
        }
    }
    
// MARK: - Frame Calculation
    
    private func frameForCellAtColumn(columnIndex: UInt, inRow rowIndex: UInt) -> NSRect {
        var cellFrame = NSMakeRect(BorderPadding, NSMaxY(self.bounds) - BorderPadding - CellHeight, CellWidth, CellHeight)
        
        if columnIndex > 0 {
            cellFrame = NSOffsetRect(cellFrame, CGFloat(columnIndex)*CellSpacing + CGFloat(columnIndex)*CellWidth, 0)
        }
        if rowIndex > 0 {
            cellFrame = NSOffsetRect(cellFrame, 0, -(CGFloat(rowIndex)*CellSpacing + CGFloat(rowIndex)*CellHeight))
        }
        
        return cellFrame
    }
    
    override var intrinsicContentSize: NSSize {
        get {
            if let colorWell = self.colorWell {
                let maxColumnIndex: UInt
                if colorWell.dataSource?.numberOfColumnsInColorWell(colorWell) > 0 {
                    maxColumnIndex = colorWell.dataSource!.numberOfColumnsInColorWell(colorWell) - 1
                } else {
                    maxColumnIndex = 0
                }
                
                let maxRowIndex: UInt
                if colorWell.dataSource?.numberOfRowsInColorWell(colorWell) > 0 {
                    maxRowIndex = colorWell.dataSource!.numberOfRowsInColorWell(colorWell) - 1
                } else {
                    maxRowIndex = 0
                }
                
                var topLeftCellFrame = self.frameForCellAtColumn(0, inRow: 0)
                var bottomRightCellFrame = self.frameForCellAtColumn(maxColumnIndex, inRow: maxRowIndex)
                topLeftCellFrame = NSOffsetRect(topLeftCellFrame, -BorderPadding, BorderPadding)
                bottomRightCellFrame = NSOffsetRect(bottomRightCellFrame, BorderPadding, -BorderPadding)
                
                return NSUnionRect(topLeftCellFrame, bottomRightCellFrame).size
            }
            
            return super.intrinsicContentSize
        }
    }
    
// MARK: - Mouse
    
    override func mouseDown(theEvent: NSEvent) {
        let location = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        self.selectedIndexPath = nil
        
        if let selectedIndexPath = self.determineIndexPathForLocation(location) {
            self.selectedIndexPath = selectedIndexPath
            self.updateCells()
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        if self.selectedIndexPath == nil {
            return
        }
        
        let location = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        if let selectedIndexPath = self.determineIndexPathForLocation(location) {
            if selectedIndexPath.row == self.selectedIndexPath!.row && selectedIndexPath.column == self.selectedIndexPath!.column {
                if let color = self.colorWell!.dataSource!.colorWell(self.colorWell!, colorAtIndexPath: selectedIndexPath) {
                    self.colorWell!.selectedIndexPath = selectedIndexPath
                }
            }
        }
    }
    
// MARK: - Helpers
    
    private func determineIndexPathForLocation(location: NSPoint) -> IndexPath? {
        if self.colorWell == nil || self.colorWell?.dataSource == nil {
            return nil
        }
    
        let columns = self.colorWell!.dataSource!.numberOfColumnsInColorWell(self.colorWell!)
        let rows = self.colorWell!.dataSource!.numberOfRowsInColorWell(self.colorWell!)
        var indexPath: IndexPath?
        
        for column in 0...columns-1 {
            for row in 0...rows-1 {
                let frame = self.frameForCellAtColumn(column, inRow: row)
                if NSPointInRect(location, frame) {
                    indexPath = IndexPath(column: column, row: row)
                    break
                }
            }
            if indexPath != nil {
                break
            }
        }
        
        return indexPath
    }

}
