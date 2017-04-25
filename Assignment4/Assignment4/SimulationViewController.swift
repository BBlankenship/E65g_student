//
//  SecondViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate {
    
    
    @IBOutlet weak var gridView: GridView!
    
    var engine: EngineProtocol!
    var timer: Timer?
    var secondTimer: Timer?
    
    struct CellCounts {
        var numLiving: Int = 0
        var numEmpty: Int = 0
        var numBorn: Int = 0
        var numDead: Int = 0
    }
    var steppedGrid = CellCounts()
    
    
    func countCells(state: CellState)->Int{
        var cellNum: Int {
            return engine.reduce2(gridView.size, gridView.size) { total, row, col in
                return self.engine.grid[row,col] == state ? total+1: total
            }
        }
        print ("The number of cells (state - \(state) ) is \(cellNum)")
        return cellNum
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let size = gridView.size
        engine = StandardEngine(rows: size, cols: size)
        engine.delegate = self
        gridView.gridDataSource = self
        
        //observer for the EngineUpdate
        NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue: "EngineUpdate"),
            object: nil,
            queue: nil) { (n) in
                self.gridView.setNeedsDisplay()
        }
        
        //notification for the statistics
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "StatisticsUpdate")
        let myCounts : (Timer) -> Void = { timer in
            let userInfo = ["cellCount": self.steppedGrid,
                            "numEmpty": String(self.steppedGrid.numEmpty),
                            "numLiving": String(self.steppedGrid.numLiving),
                            "numBorn": String(self.steppedGrid.numBorn),
                            "numDead": String(self.steppedGrid.numDead)] as [String : Any]
            let notificationStats = Notification (name: name, object: nil, userInfo: userInfo)
            nc.post(notificationStats)
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: myCounts)
        
        //notification for the gridSize
        let myGridSize : (Timer) -> Void = { timer in
            let userInfo = ["gridSize": String(self.gridView.size)] as [String : Any]
            let notificationSize = Notification (name: Notification.Name(rawValue: "GridSizeUpdate"), object: nil, userInfo: userInfo)
            nc.post(notificationSize)
        }
        
        secondTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: myGridSize)
        
        //observer for the gridSize, refreshRate and Swutch value from the InstrumentationView
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "FieldsUpdate"), object: nil, queue: nil) { fiN in
            let userInfo = fiN.userInfo!
            let updatedSize = userInfo["textField"] as? String
            self.gridView.size = Int(updatedSize!)!
            self.gridView.setNeedsDisplay()
            let updatedRate = userInfo["refreshRate"] as? UISlider
            self.engine.refreshRate = Double((updatedRate?.value)!)
            let updatedSwitch = userInfo["switch"] as! UISwitch
            if updatedSwitch.isOn == false {
                self.engine.refreshRate = 0.0
            } else {
                self.engine.refreshRate = Double((updatedRate?.value)!)
                _ = self.stepUp()
            }
            
        }
    }
    //conforming to Engine Delegate protocol
    func engineDidUpdate(withGrid: GridProtocol) {
        self.gridView.setNeedsDisplay()
    }
    //conforming to GridViewDataSource protocol
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func stepUp (){
        _ = engine.step()
        gridView.setNeedsDisplay()
        steppedGrid.numEmpty = countCells(state: .empty)
        steppedGrid.numLiving = countCells(state: .alive)
        steppedGrid.numBorn = countCells(state: .born)
        steppedGrid.numDead = countCells(state: .died)
    }
    
    @IBAction func stepDelegate(_ sender: Any) {
        _ = stepUp()
        
    }
    
}

