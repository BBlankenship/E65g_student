//
//  GridProtocol.swift
//  Assignment4
//
//  Created by Bobby Blankenship on 4/18/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

public struct GridPosition: Equatable {
    var row: Int
    var col: Int
    
    public static func == (lhs: GridPosition, rhs: GridPosition) -> Bool {
        return (lhs.row == rhs.row && lhs.col == rhs.col)
    }
}

public struct GridSize {
    var rows: Int
    var cols: Int
}

public enum CellState: String {
    case alive = "alive"
    case empty = "empty"
    case born = "born"
    case died = "died"
    
    
    public func description() -> String {
        switch self {
        default: return self.rawValue
        }
    }
    
    static func allValues() -> [CellState] {
        return [.alive, .empty, .born, .died]
    }
    
    public func toggle (value: CellState)-> CellState {
        switch value {
        case .empty, .died: return .alive
        case .alive, .born: return .empty
        }
    }
    
    public var isAlive: Bool {
        switch self {
        case .alive, .born: return true
        default: return false
        }
    }
}
public protocol GridProtocol: CustomStringConvertible {
    init(_ size: GridSize, cellInitializer: (GridPosition) -> CellState)
    var size: GridSize { get }
    subscript (row: Int, col: Int) -> CellState { get set }
    func next() -> Self
}
