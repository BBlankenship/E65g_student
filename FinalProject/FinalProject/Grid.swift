//
//  Grid.swift
//
import Foundation


func norm(_ val: Int, to size: Int) -> Int { return ((val % size) + size) % size }


let lazyPositions = { (size: GridSize) in
    return (0 ..< size.rows)
        .lazy
        .map { zip( [Int](repeating: $0, count: size.cols) , 0 ..< size.cols ) }
        .flatMap { $0 }
        .map { GridPosition(row: $0.0,col: $0.1) }
}

fileprivate let offsets: [GridPosition] = [
    GridPosition(row: -1, col:  -1), GridPosition(row: -1, col:  0), GridPosition(row: -1, col:  1),
    GridPosition(row:  0, col:  -1),                                 GridPosition(row:  0, col:  1),
    GridPosition(row:  1, col:  -1), GridPosition(row:  1, col:  0), GridPosition(row:  1, col:  1)
]

public extension GridProtocol {
}

public struct Grid: GridProtocol, GridViewDataSource {
    
    private var _cells: [[CellState]]
    //changed to set rows and cols size
    public var size: GridSize
    //  public let size: GridSize
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] }
        set { _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] = newValue }
    }
    
    public init(_ size: GridSize, cellInitializer: (GridPosition) -> CellState = { _ in .empty }) {
        _cells = [[CellState]](
            repeatElement(
                [CellState]( repeatElement(.empty, count: size.cols)),
                count: size.rows
            )
        )
        self.size = size
        lazyPositions(self.size).forEach { self[$0.row, $0.col] = cellInitializer($0) }
    }
    public var description: String {
        return lazyPositions(self.size)
            .map { (self[$0.row, $0.col].isAlive ? "*" : " ") + ($0.col == self.size.cols - 1 ? "\n" : "") }
            .joined()
    }
    
    private func neighborStates(of pos: GridPosition) -> [CellState] {
        return offsets.map { self[pos.row + $0.row, pos.col + $0.col] }
    }
    
    private func nextState(of pos: GridPosition) -> CellState {
        let iAmAlive = self[pos.row, pos.col].isAlive
        let numLivingNeighbors = neighborStates(of: pos).filter({ $0.isAlive }).count
        switch numLivingNeighbors {
        case 2 where iAmAlive,
             3: return iAmAlive ? .alive : .born
        default: return iAmAlive ? .died  : .empty
        }
    }
    
    public func next() -> Grid {
        var nextGrid = Grid(size) { _ in .empty }
        lazyPositions(self.size).forEach { nextGrid[$0.row, $0.col] = self.nextState(of: $0) }
        return nextGrid
    }
}

extension Grid: Sequence {
    var living: [GridPosition] {
        return lazyPositions(self.size).filter { return  self[$0.row, $0.col] == .alive }
    }
    
    public struct GridIterator: IteratorProtocol {
        private class GridHistory: Equatable {
            let positions: [GridPosition]
            let previous:  GridHistory?
            
            static func == (lhs: GridHistory, rhs: GridHistory) -> Bool {
                return lhs.positions.elementsEqual(rhs.positions, by: ==)
            }
            
            init(_ positions: [GridPosition], _ previous: GridHistory? = nil) {
                self.positions = positions
                self.previous = previous
            }
            
            var hasCycle: Bool {
                var prev = previous
                while prev != nil {
                    if self == prev { return true }
                    prev = prev!.previous
                }
                return false
            }
        }
        
        private var grid: Grid
        private var history: GridHistory!
        
        init(grid: Grid) {
            self.grid = grid
            self.history = GridHistory(grid.living)
        }
        
        public mutating func next() -> Grid? {
            guard !history.hasCycle else { return nil }
            let newGrid = grid.next()
            history = GridHistory(newGrid.living, history)
            grid = newGrid
            return grid
        }
    }
    
    public func makeIterator() -> GridIterator { return GridIterator(grid: self) }
}

public extension Grid {
    public static func gliderInitializer(pos: GridPosition) -> CellState {
        switch pos {
        case GridPosition(row: 0, col: 1), GridPosition(row: 1, col: 2),
             GridPosition(row: 2, col: 0), GridPosition(row: 2, col: 1),
             GridPosition(row: 2, col: 2): return .alive
        default: return .empty
        }
    }
}
var configuration: [String: [[Int]]] = [:]
public extension Grid {
 
    func returnPositions(state: CellState) -> [GridPosition] {
        var cellsPositions: [GridPosition] {
            return lazyPositions(self.size).filter{return  self[$0.row, $0.col] == state}
        }
        return cellsPositions
    }
 
    func setConfiguration(){
        lazyPositions(self.size).forEach {
            switch self[$0.row,$0.col] {
            case .born:
                configuration["born"] = (configuration["born"] ?? []) + [[$0.row, $0.col]]
            case .died:
                configuration["died"] = (configuration["died"] ?? []) + [[$0.row, $0.col]]
            case .alive:
                configuration["alive"] = (configuration["alive"] ?? []) + [[$0.row, $0.col]]
            case .empty:
                ()
            }
        }
    }
    
    public static func variationInitializer(pos: GridPosition) -> CellState {
        switch pos {
        case GridPosition(row: 0, col: 1), GridPosition(row: 1, col: 2),
             GridPosition(row: 2, col: 0), GridPosition(row: 2, col: 1),
             GridPosition(row: 2, col: 2): return .alive
        default: return .empty
        }
    }
}



protocol EngineDelegate {
    func engineDidUpdate(withGrid: GridProtocol)
}

protocol EngineProtocol {
    var delegate: EngineDelegate? { get set }
    var grid: GridProtocol { get set }
    var refreshRate: Double { get set }
    var refreshTimer: Timer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    init(rows: Int, cols: Int)
    func step() -> GridProtocol
}

class StandardEngine: EngineProtocol {
    
    
    
    static var engine: StandardEngine = StandardEngine(rows: 10, cols: 10)
    var delegate: EngineDelegate?
    var grid: GridProtocol {
        didSet {
            delegate?.engineDidUpdate(withGrid: grid)
            let nc = NotificationCenter.default
            let name = Notification.Name(rawValue: "EngineUpdate")
            let n = Notification(name: name,
                                 object: nil,
                                 userInfo: ["engine" : self])
            nc.post(n)
        }
    }
    var rows: Int
    var cols: Int
    var refreshTimer: Timer?
    var refreshRate: TimeInterval = 0.0 {
        didSet {
            if refreshRate > 0.0 {
                refreshTimer = Timer.scheduledTimer(
                    withTimeInterval: refreshRate,
                    repeats: true
                ) { (t: Timer) in
                    _ = self.step()
                }
            }
            else {
                refreshTimer?.invalidate()
                refreshTimer = nil
            }
        }
    }
    
    
    required init(rows: Int, cols: Int) {
        
        self.grid = Grid(GridSize(rows: rows, cols: cols))
        self.rows = rows
        self.cols = cols
    }
    
    func step() -> GridProtocol {
        let newGrid = grid.next()
        grid = newGrid
        return grid
    }
    
}
