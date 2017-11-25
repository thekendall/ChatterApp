//
//  ReportTableTableViewController.swift
//  ChatterApp
//
//  Created by Kendall Lui on 11/22/17.
//  Copyright © 2017 Kendall Lui. All rights reserved.
//

import UIKit

class ReportTableTableViewController: UITableViewController {
    
    @IBOutlet weak var toolLengthSelectorButton: SelectorButton!
    @IBOutlet weak var depthOfCutSelectorButton: SelectorButton!
    @IBOutlet weak var widthOfCutSelectorButton: SelectorButton!
    @IBOutlet weak var feedrateUnitSelectorButon: SelectorButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReportTableTableViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        toolLengthSelectorButton.selectorValues = standardDisplacementUnits;
        depthOfCutSelectorButton.selectorValues = machinistDisplacementUnits;
        widthOfCutSelectorButton.selectorValues = machinistDisplacementUnits;
        feedrateUnitSelectorButon.selectorValues = standardVelocityUnits;
    }
    
    
    @IBAction func toggleSelectorButton(_ sender: SelectorButton) {
        sender.selectorState += 1;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Dismisses Keyboard
    func dismissKeyboard() {
        self.view.endEditing(true) //This will hide the keyboard
    }
    
    //MARK: Unit UI
    let standardDisplacementUnits = ["in","mm"];
    let machinistDisplacementUnits = ["in", "mm", "thou", "mil"];
    let standardVelocityUnits = ["in/s","mm/s"];

    
}
