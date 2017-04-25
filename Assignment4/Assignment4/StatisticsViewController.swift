//
//  StatisticsViewController.swift
//  Assignment4
//
//  Created by Bobby Blankenship on 4/18/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var countEmpty: UITextField!
    @IBOutlet weak var countLiving: UITextField!
    @IBOutlet weak var countBorn: UITextField!
    @IBOutlet weak var countDead: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //observer for the statistics
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "StatisticsUpdate")
        nc.addObserver(forName: name, object: nil, queue: nil) { notification in
            let userInfo = notification.userInfo!
            self.countEmpty.text = userInfo["numEmpty"] as? String
            self.countLiving.text = userInfo["numLiving"] as? String
            self.countBorn.text = userInfo["numBorn"] as? String
            self.countDead.text = userInfo["numDead"] as? String
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
}
