//
//  MainMenuViewController.swift
//  ChatterApp
//
//  Created by Kendall Lui on 9/29/16.
//  Copyright © 2016 Kendall Lui. All rights reserved.
//

import UIKit
class MainMenuViewController: UIViewController {
    @IBOutlet weak var loadAudioProfileButton: UIButton!
    @IBOutlet weak var recordNewAudioProfileButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    
    override func viewDidLoad() {
        self.title = "Main Menu"
    }
}