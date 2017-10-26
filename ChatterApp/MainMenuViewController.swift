//
//  MainMenuViewController.swift
//  ChatterApp
//
//  Created by Kendall Lui on 9/29/16.
//  Copyright © 2016 Kendall Lui. All rights reserved.
//

import UIKit
import AVFoundation

class MainMenuViewController: UIViewController {
    @IBOutlet weak var loadAudioProfileButton: UIButton!
    @IBOutlet weak var recordNewAudioProfileButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    
    override func viewDidLoad() {
        AVAudioSession.sharedInstance().requestRecordPermission () {
            [unowned self] allowed in
            if allowed {
                // Microphone allowed, do what you like!
                
            } else {
                // User denied microphone. Tell them off!
                
            }
        }
        self.title = "Main Menu"
    }
}
