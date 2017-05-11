//
//  GridVariations.swift
//  FinalProject
//
//  Created by Bobby Blankenship on 5/6/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import Foundation

class GridVariation {
    
    static var gridVariationSingleton: GridVariation = GridVariation(data: ["initial row": ["alive": [[0, 0]]]])
    var variationsData: [String : [String : [[Int]]]] {
        didSet {
            variationsUpdateClosure?(self.variationsData)
        }
    }
    var selectedVariation: String?
    var variationsUpdateClosure: (([String : [String : [[Int]]]]) -> Void)?
    var gridSize: Int = 0
    var savedVariation: Bool = false
    
    init (data: [String : [String : [[Int]]]]) {
        self.variationsData = data
        
    }
    func createVariationGrid() -> Grid {
        var newSize: [Int] = []
        
        self.variationsData[selectedVariation!]?.forEach{(receivedVariationState, receivedVariationData) in
            
            //establish the size
            let maxNumber = receivedVariationData
                .reduce([], { (result: [Int], element: [Int]) -> [Int] in
                    return result + element
                })
                .reduce(0){$0 > $1 ? $0 : $1}
            
            newSize.append(maxNumber)
            
        }
        gridSize = ((newSize.reduce(0){$0 > $1 ? $0 : $1}) + 1) * 2
        var variationGrid = Grid(GridSize(rows: 10, cols: 10)) { _ in .empty }
        if (gridSize != 2) {
            variationGrid = Grid(GridSize(rows: gridSize, cols: gridSize)) { _ in .empty } }
        self.variationsData[selectedVariation!]?.forEach{(receivedVariationState, receivedVariationData) in
            (0 ..< receivedVariationData.count).forEach { i in
                let varRow = receivedVariationData[i][0]
                let varCol = receivedVariationData[i][1]
                variationGrid[varRow, varCol] = CellState(rawValue: receivedVariationState)!
            }
        }
        return variationGrid
    }
}
