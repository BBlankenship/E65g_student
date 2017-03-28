//
//  GridView.swift
//  Assignment3
//
//  Created by Bobby Blankenship on 3/25/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable class GridView: UIView {
    
    @IBInspectable var size = 20{
        didSet{
            grid = Grid(size, size)
        }
    }
    @IBInspectable var livingColor = UIColor.green
    @IBInspectable var emptyColor = UIColor.lightGray
    @IBInspectable var bornColor = UIColor.cyan
    @IBInspectable var diedColor = UIColor.gray
    @IBInspectable var gridColor = UIColor.black
    @IBInspectable var gridWidth = CGFloat(8.0)
    
    var grid = Grid(20, 20)
    private var cellSize = CGSize(width: 0.0, height: 0.0)
    
    override func draw(_ rect: CGRect) {
        cellSize = CGSize(
            width: rect.size.width / CGFloat(self.size),
            height: rect.size.height / CGFloat(self.size)
        )
        let base = rect.origin
        //Draw grid
        (0 ... size).forEach{
            drawLine(
                start: CGPoint(x: 0.0, y: CGFloat($0) * cellSize.height),
                end: CGPoint(x: rect.size.width, y: CGFloat($0) * cellSize.height)
            )
            drawLine(
                start: CGPoint(x: CGFloat($0) * cellSize.width, y: 0.0),
                end: CGPoint(x: CGFloat($0) * cellSize.width, y: rect.size.height)
            )
        }
        
        //Draw cells
        (0 ..< self.size).forEach{ i in
            (0 ..< self.size).forEach{ j in
                var cellColor : UIColor
                let pos = Position(row:i, col:j)
                let cellState = self.grid[pos]
                switch cellState {
                case .alive:
                    cellColor = livingColor
                case .born:
                    cellColor = bornColor
                case .empty:
                    cellColor = emptyColor
                case .died:
                    cellColor = diedColor
                }
                
                let cellOrigin = CGPoint(
                    x: base.x + (CGFloat(j) * cellSize.width),
                    y: base.y + (CGFloat(i) * cellSize.height)
                )
                let cellRect = CGRect(
                    origin: cellOrigin,
                    size: cellSize
                )
                
                let path = UIBezierPath(ovalIn: cellRect)
                cellColor.setFill()
                path.fill()
            }
        }
    }
    
    func drawLine(start: CGPoint, end: CGPoint){
        let path = UIBezierPath();
        path.lineWidth = gridWidth
        path.move(to: start)
        path.addLine(to: end)
        gridColor.setStroke()
        path.stroke()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
    }
    
    var lastTouchedPosition: Position?
    
    func process(touches: Set<UITouch>) -> Position? {
        guard touches.count == 1 else {return nil}
        let pos = convert(touch: touches.first!)
        guard lastTouchedPosition?.row != pos.row ||
            lastTouchedPosition?.col != pos.col
            else {return pos}
        
        grid[pos] = grid[pos].toggle(value: grid[pos])
        setNeedsDisplay()
        return pos
    }
    
    func convert(touch: UITouch) -> Position{
        let touchY = touch.location(in: self).y
        let row = touchY / cellSize.height
        let touchX = touch.location(in: self).x
        let col = touchX / cellSize.width
        let position = (row: Int(row), col: Int(col))
        return position
    }
    
}
