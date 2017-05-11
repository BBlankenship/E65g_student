//
//  FirstViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

let finalProjectURL = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"


class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tabViewController: UITabBarController!
    
    @IBOutlet weak var gridRowsTextField: UITextField!
    @IBOutlet weak var gridColsTextField: UITextField!
    @IBOutlet weak var gridRowsStepper: UIStepper!
    @IBOutlet weak var gridColsStepper: UIStepper!
    @IBOutlet weak var refreshRate: UISlider!
    @IBOutlet weak var refreshSwitch: UISwitch!
    @IBOutlet weak var refreshRateLabel: UILabel!
    @IBOutlet weak var congifurationsView: UITableView!
    
    var engine: EngineProtocol!
    var timer: Timer?
    var gridVariations: GridVariation!
    var sectionHeaders: [String] = []
    var gridVariationValue : String = ""
    var jsonDictionaryArray: [String : [[Int]]] = [:]
    
    var rows:Int = 5
    var cols:Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigation controller bar
        navigationController?.isNavigationBarHidden = true
        
        //solution for the notifications to work without prior clicking to the tabs after loading
        OperationQueue.main.addOperation {
            self.tabViewController?.selectedIndex = 1
            self.tabViewController?.selectedIndex = 2
            self.tabViewController?.selectedIndex = 0
        }
        
        
        //fetcher
        let fetcher = Fetcher()
        fetcher.fetchJSON(url: URL(string:finalProjectURL)!) { (json: Any?, message: String?) in
            guard message == nil else {
                print(message ?? "nil")
                return
            }
            //guard
            guard let json = json else {
                print("no json")
                return
            }
            //guard
            let jsonArray = json as! NSArray
            OperationQueue.main.addOperation {
                
                if (jsonArray.count != 0) {
                    for i in 0..<jsonArray.count {
                        let jsonDictionary = jsonArray[i] as! NSDictionary
                        self.jsonDictionaryArray.updateValue(jsonDictionary["contents"] as! [[Int]], forKey: jsonDictionary["title"] as! String)
                    }
                    //jsonArray
                    for (name, variation) in self.jsonDictionaryArray {
                        let fullStack = ["alive": variation]
                        self.gridVariations.variationsData.updateValue(fullStack, forKey: name)
                    }
                    //dict
                    self.gridVariations.variationsData["initial row"] = nil
                }
                //end if
                
                self.congifurationsView.reloadData()
                
            }
        }
        
        //access to the GridVariations (json and user saved data) static instance
        gridVariations = GridVariation.gridVariationSingleton
        gridVariations.variationsUpdateClosure = { (gridVariations) in
            self.sectionHeaders = Array(gridVariations.keys)
            self.congifurationsView.reloadData()
        }
        
        //access to StandardEngine static instance
        engine = StandardEngine.engine
        gridRowsTextField.text = String(self.engine.grid.size.rows)
        gridColsTextField.text = String(self.engine.grid.size.cols)
        gridRowsStepper.value = Double(self.engine.grid.size.rows)
        gridColsStepper.value = Double(self.engine.grid.size.cols)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //navigation controller bar
        navigationController?.isNavigationBarHidden = true
        
        //observer for the GridUpdate in GridView
        NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue: "GridUpdate"),
            object: nil,
            queue: nil) { (n) in
                self.gridRowsTextField.text = String(self.engine.grid.size.rows)
                self.gridColsTextField.text = String(self.engine.grid.size.cols)
                self.gridRowsStepper.value = Double(self.engine.grid.size.rows)
                self.gridColsStepper.value = Double(self.engine.grid.size.cols)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: AlertController Handling
    
    func showErrorAlert(withMessage msg:String, action: (() -> Void)? ) {
        let alert = UIAlertController(
            title: "Alert",
            message: msg,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true) { }
            OperationQueue.main.addOperation { action?() }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func createEmptyGridAlert() {
        let alertController = UIAlertController(title: "Create an empty grid!", message: "The size of the grid is 10 x 10 cells", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            alert -> Void in
            let userConfigName = alertController.textFields![0] as UITextField
            self.gridVariations.variationsData.updateValue([:], forKey: userConfigName.text!)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        alertController.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Configuration Name"
        })
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: - Actions
    
    @IBAction func rowsEditingEnded(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = self.gridRowsTextField.text
            }
            return
        }
        gridRowsTextField.text = String(val)
        gridRowsStepper.value = Double(val)
        
        self.engine.grid.size.rows = Int(val)
        self.rows = Int(val)
        self.engine.grid = Grid(GridSize(rows: self.rows, cols: self.cols))
    }
    
    
    @IBAction func colsEditingEnded(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = self.gridColsTextField.text
            }
            return
        }
        gridColsTextField.text = String(val)
        gridColsStepper.value = Double(val)
        
        self.engine.grid.size.cols = Int(val)
        self.cols = Int(val)
        self.engine.grid = Grid(GridSize(rows: self.rows, cols: self.cols))
    }
    
    @IBAction func rowsStepperChange(_ sender: UIStepper) {
        gridRowsTextField.text = String(Int(sender.value))
        gridRowsStepper.value = sender.value
        
        self.engine.grid.size.rows = Int(sender.value)
        self.rows = Int(sender.value)
        self.engine.grid = Grid(GridSize(rows: self.rows, cols: self.cols))
    }
    
    @IBAction func colsStepperChange(_ sender: UIStepper) {
        gridColsTextField.text = String(Int(sender.value))
        gridColsStepper.value = sender.value
        
        self.engine.grid.size.cols = Int(sender.value)
        self.cols = Int(sender.value)
        self.engine.grid = Grid(GridSize(rows: self.rows, cols: self.cols))
    }
    
    @IBAction func refreshRateChanged(_ sender: UISlider) {
        self.refreshRateLabel.text = String(format: "%.2f", sender.value)
        if self.refreshSwitch.isOn == true {
            self.engine.refreshRate = TimeInterval(sender.value)
        }
    }
    
    @IBAction func refreshSwitchChanged(_ sender: UISwitch) {
        if refreshSwitch.isOn == true {
            self.engine.refreshRate = Double(self.refreshRate.value)
        } else {
            self.engine.refreshRate = 0.0
        }
    }
    
    @IBAction func addVariation(_ sender: UIButton) {
        OperationQueue.main.addOperation {
            _ = self.createEmptyGridAlert()
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionHeaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basic"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = sectionHeaders[indexPath.row]
        
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.congifurationsView.indexPathForSelectedRow
        if let indexPath = indexPath {
            gridVariations.selectedVariation = sectionHeaders[indexPath.row]
            
            if let vc = segue.destination as? GridEditorViewController {
                vc.variationValue = gridVariations.selectedVariation
            }
        }
    }
    
}

