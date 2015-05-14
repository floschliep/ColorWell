ColorWell
-----------

![](screenshot.png)

An implementation of the color well similar to iWork, inspired by [DFColorWell](https://github.com/danieljfarrell/DFColorWell).

All custom drawing is done with layers, the usual NSEvent methods (mouseDown:, mouseUp:) are implemented to keep track of the control's state and turn on or off different drawing options. Colors can only be selected from a predefined set of colors, unlike [DFColorWell](https://github.com/danieljfarrell/DFColorWell). Data source methods must be implemented to fill the popover grid with color cells.

Any improvements welcomed. 

Usage
-----

1. Drag out an NSView into an XIB or Storyboard
2. Change the class to `ColorWell`
3. Unlike [DFColorWell](https://github.com/danieljfarrell/DFColorWell), `ColorWell` allows custom sizes, but 67x23 (or similar sizes) looks good
4. Set the color well’s data source and initial selected index path (the latter is not required, but recommended):
```
    @IBOutlet weak var colorWell: ColorWell! {
        didSet {
            self.colorWell.dataSource = self
            self.colorWell.selectedIndexPath = IndexPath(column: 0, row: 0)
        }
    }
```
5. Implement all data source methods to fill the popover with different colors:
```
    func numberOfRowsInColorWell(colorwell: ColorWell) -> UInt
    func numberOfColumnsInColorWell(colorwell: ColorWell) -> UInt
    func colorWell(colorwell: ColorWell, colorAtIndexPath indexPath: IndexPath) -> NSColor?
```

Contact
-------
* Florian Schliep
* [@floschliep](https://twitter.com/floschliep)
* http://floschliep.com

Acknowledgements
----------------

Thanks to [Daniel J Farrell](https://github.com/danieljfarrell) for creating [DFColorWell](https://github.com/danieljfarrell/DFColorWell), which is the basis of this project.

Licensing
---------
ColorWell is licensed under the [BSD license](http://opensource.org/licenses/BSD-3-Clause).
