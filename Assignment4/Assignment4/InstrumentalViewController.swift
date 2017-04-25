//
//  FirstViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController {
    
    @IBOutlet weak var gridSizeTextField: UITextField!
    @IBOutlet weak var gridSizeStepper: UIStepper!
    @IBOutlet weak var refreshSwitch: UISwitch!
    @IBOutlet weak var refreshRate: UISlider!
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if gridSizeTextField.text?.isEmpty == true {
            gridSizeTextField.text = "15"
        }
        _ = readGridUpdate()
    }
    
    @IBAction func stepUpOrDown(_ sender: UIStepper) {
        gridSizeTextField.text = String(Int(sender.value))
        _ =  notifyTheChange()
        
    }
    
    @IBAction func refreshChanged(_ sender: UISwitch) {
        //        _ = readFromSimulationView()
        _ = notifyTheChange()
        if refreshSwitch.isOn == true {
            print ("switch is on")
        } else {
            print ("switch is off")
        }
    }
    
    @IBAction func editingDidEndOnExit(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = self.gridSizeTextField.text
            }
            return
        }
        gridSizeTextField.text = String(val)
        gridSizeStepper.value = Double(val)
        _ =  notifyTheChange()
        
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
    
    func notifyTheChange() {
        let fiNc = NotificationCenter.default
        let fiName = Notification.Name(rawValue: "FieldsUpdate")
        let fiN = Notification(name: fiName,
                               object: nil,
                               userInfo: ["textField" : gridSizeTextField.text!,
                                          "switch" : refreshSwitch!,
                                          "refreshRate": refreshRate!])
        fiNc.post(fiN)
    }
    
    func readFromSimulationView(){
        
        //from StandardEngine
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "EngineUpdate"), object: nil, queue: nil) { notification in
  
        }
        
        //end from StandardEngine
    }
    
    func readGridUpdate(){
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "GridSizeUpdate"), object: nil, queue: nil) { notification in
            let userInfo = notification.userInfo!
            print("\(String(describing: userInfo["gridSize"] as? String))")
            self.gridSizeTextField.text = userInfo["gridSize"] as? String
            let gridSizeToDouble = userInfo["gridSize"] as? String
            self.gridSizeStepper.value = Double(gridSizeToDouble!)!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

