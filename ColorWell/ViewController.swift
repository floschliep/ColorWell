//
//  ViewController.swift
//  ColorWell
//
//  Created by Florian Schliep on 14.05.15.
//
//

import Cocoa

class ViewController: NSViewController, ColorWellDataSource {
    
    @IBOutlet weak var colorWell: ColorWell! {
        didSet {
            self.colorWell.dataSource = self
            self.colorWell.selectedIndexPath = IndexPath(column: 0, row: 0)
        }
    }
    @IBOutlet weak var colorInformationLabel: NSTextField!
    private let colors: Array<Array<NSColor>> =
    [
        [NSColor(red:0.996, green:0.898, blue:0.411, alpha:1), NSColor(red:0.999, green:0.723, blue:0.443, alpha:1), NSColor(red:1, green:0.631, blue:0.62, alpha:1), NSColor(red:1, green:0.489, blue:0.42, alpha:1)],
        [NSColor(red:0.998, green:0.633, blue:0.883, alpha:1), NSColor(red:0.477, green:0.53, blue:0.992, alpha:1), NSColor(red:0.362, green:0.65, blue:0.992, alpha:1), NSColor(red:0.587, green:0.91, blue:0.991, alpha:1)],
        [NSColor(red:0.669, green:0.977, blue:0.667, alpha:1), NSColor(red:0.331, green:0.665, blue:0.354, alpha:1), NSColor(red:0.465, green:0.342, blue:0.138, alpha:1), NSColor(red:0.468, green:0.166, blue:0.075, alpha:1)],
        [NSColor(red:0.468, green:0.16, blue:0.172, alpha:1), NSColor(red:0.587, green:0.149, blue:0.23, alpha:1), NSColor(red:0.587, green:0.154, blue:0.528, alpha:1), NSColor(red:0.267, green:0.275, blue:0.581, alpha:1)],
        [NSColor(red:0.165, green:0.343, blue:0.581, alpha:1), NSColor(red:0, green:0.515, blue:0.581, alpha:1), NSColor(red:0.284, green:0.573, blue:0.453, alpha:1), NSColor(red:0.136, green:0.361, blue:0.127, alpha:1)]
    ]
    
// MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateColorInformation(self.colorWell)
    }
    
// MARK: - Color Well Action
    
    @IBAction func updateColorInformation(sender: ColorWell) {
        if let color = self.colorWell.color {
            self.colorInformationLabel.stringValue = "R:\(color.redComponent), G:\(color.greenComponent), B:\(color.blueComponent)"
        }
    }
    
// MARK: - ColorWellDataSource
    
    func numberOfColumnsInColorWell(colorwell: ColorWell) -> UInt {
        return 5
    }
    
    func numberOfRowsInColorWell(colorwell: ColorWell) -> UInt {
        return 4
    }
    
    func colorWell(colorwell: ColorWell, colorAtIndexPath indexPath: IndexPath) -> NSColor? {
        return self.colors[Int(indexPath.column)][Int(indexPath.row)]
    }
    
}

