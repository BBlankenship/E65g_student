//
//  GridEditorViewController.swift
//  FinalProject
//
//  Created by Bobby Blankenship on 5/6/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController, GridViewDataSource {
    
    @IBOutlet weak var variationValueName: UILabel!
    @IBOutlet weak var gridViewEditor: GridView!
    
    var variationValue: String?
    var engine: EngineProtocol!
    var gridVariations: GridVariation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //access to StandardEngine static instance
        engine = StandardEngine.engine
        
        //access to the GridVariations (json and user saved data) static instance
        gridVariations = GridVariation.gridVariationSingleton
        
        //gridDataSource delegate
        gridViewEditor.gridDataSource = self
        
        //navigation controller bar
        navigationController?.isNavigationBarHidden = false
        
        //assign grid to the selected variation, if there is any
        if let variationValue = variationValue {
            variationValueName.text = variationValue
            gridVariations?.selectedVariation = variationValue
            guard let newConfiguration = gridVariations?.createVariationGrid() else {return}
            engine.grid = newConfiguration
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
        //observer for the EngineUpdate
        NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue: "EngineUpdate"),
            object: nil,
            queue: nil) { (n) in
                self.gridViewEditor.setNeedsDisplay()
        }
        
        //observer for the GridUpdate in GridView
        NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue: "GridUpdate"),
            object: nil,
            queue: nil) { (n) in
                self.gridViewEditor.setNeedsDisplay()
        }
        NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue: "GridEditorEngineUpdate"),
            object: nil,
            queue: nil) { notification in
                self.engine.grid = notification.userInfo?["lastGrid"] as! GridProtocol
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    
    @IBAction func saveUserGridVariation(_ sender: Any) {
        let lastGrid: GridProtocol = engine.grid
        
        //post notification GridEditorEngineUpdate
        let nge = NotificationCenter.default
        let notificationGE = Notification(name: Notification.Name(rawValue: "GridEditorEngineUpdate"),
                                          object: nil,
                                          userInfo: ["lastGrid" : lastGrid])
        nge.post(notificationGE)
        
        
        //create a name
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM/dd/yy h:mm a Z"
        let now = dateformatter.string(from: NSDate() as Date)
        let newName = variationValueName.text! + " " + now
        
        //createa configuration
        configuration.removeAll()
        _ = engine.grid.setConfiguration()
        
        //update gridVariations instance
        if configuration.keys.first != nil {
            gridVariations?.variationsData.updateValue(configuration, forKey: newName)
        }
        
        //make a mark that the instance has been saved
        gridVariations?.savedVariation = true
        
        //return to the InstrumenatationViewController
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Protocols
    
    //conforming to GridViewDataSource protocol
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
}
