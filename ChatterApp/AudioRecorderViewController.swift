//
//  AudioRecorderViewController.swift
//  ChatterApp
//
//  Created by Kendall Lui on 9/29/16.
//  Copyright © 2016 Kendall Lui. All rights reserved.
//

import UIKit

class AudioRecorderViewController: UIViewController, AudioManagerDelegate {
    
    var audioManager = AudioManager()
    var timer:Timer? = nil;
    var peakPower:[Double] = [];
    var times:[Double] = [];
    var recording = false;
    var hasRecording = false {
        didSet {
            checkActivateSave()
        }
    }
    var waveformIndex = 0;
    var recordingLine = 0;
    let recordLength = 10.0;
    fileprivate var audioFilePath:String?;
    fileprivate var profileName:String?;
    
    @IBOutlet weak var timecode: UILabel!
    
    @IBOutlet weak var AudioPlotter: GraphView!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var analyzeButton: UIButton!
    
    
    @IBAction func record(_ sender: AnyObject) {
        if(!recording)
        {
            AudioPlotter.clearAllPlots()
            recording = true;
            audioManager.reset();
            audioManager.record(recordLength)
            AudioPlotter.autoscaleAxis = false
            AudioPlotter.x_min = 0
            AudioPlotter.x_max = recordLength;
            recordButton.setTitle("Stop", for: UIControlState())
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(AudioRecorderViewController.updateDisplay), userInfo: nil, repeats: true)
            waveformIndex = AudioPlotter.addPlot([0], y_coors: [0], color: (0,0,255))
            recordingLine = AudioPlotter.addPlot([0,0], y_coors:[1,-1], color:(255,0,0))
            //updateDisplay()
            hasRecording = false;
            
        } else {
            audioDidFinishRecording()
        }
    }
    
    @IBAction func save(_ sender: UIButton) {
        let profileNameFromTextBox = UUID().uuidString;
        if((profileNameFromTextBox) != nil)
        {
            audioFilePath = audioManager.saveAudio(profileNameFromTextBox) //path //test
            profileName = profileNameFromTextBox
        }
        performSegue(withIdentifier: "ShowChatterDetector", sender: sender)

    }
    
    
    func updateDisplay()
    {
        let time = audioManager.getTimecode()
        let channelPower = audioManager.getChannelPowerValue()
        AudioPlotter.addPointToPlotAtIndex(waveformIndex, x: time, y: channelPower)
        AudioPlotter.addPointToPlotAtIndex(waveformIndex, x: time, y: -channelPower)
        AudioPlotter.replacePlotAtIndex(recordingLine, x: [time,time], y:[-1,1])
        if(time > AudioPlotter.x_max)
        {
            AudioPlotter.shiftPlots(-0.05, y: 0.0)
        }
        timecode.text = stringFromTimeInterval(time)
        if(time >= recordLength) {
            timecode.text = stringFromTimeInterval(10.0)
        }
    }
    
    func stringFromTimeInterval(_ interval:TimeInterval) -> String {
        let ti = NSInteger(interval)
        let ms = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        let seconds = ti % 60
        return String(format: "%0.2d:%0.2d",seconds,ms)
    }

//MARK: Standard ViewController Functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Recorder"
        audioManager.delegate = self;
        //checkActivateSave()
//        profileNameTextbox.addTarget(self, action: #selector(AudioRecorderViewController.profileNameDidEdit) , for: UIControlEvents.editingChanged)
        AudioPlotter.x_min = 0.0

        // Do any additional setup after loading the view, typically from a nib.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChatterDetector"
        {
            if let destinationVC = ((segue.destination as? UITabBarController)?.childViewControllers[0] as? UINavigationController)?.topViewController as? ChatterDetectorViewController {
                destinationVC.audioFilePath = audioFilePath;
                destinationVC.profileName = profileName;
                print("\(audioFilePath)")

            }
        }
    }
    
    
    fileprivate func checkActivateSave()
    {
        if(hasRecording) {
            analyzeButton.isEnabled = true;
        } else {
            analyzeButton.isEnabled = false;
        }

    }
    
    
//MARK: AudioManagerDelegate
    func audioDidFinishRecording() {
        let time = audioManager.getTimecode()
        timer?.invalidate()
        if(time >= recordLength) {
            timecode.text = stringFromTimeInterval(recordLength)
        }
        recording = false;
        peakPower = []
        times = []
        audioManager.stopRecording()
        recordButton.setTitle("Record", for: UIControlState())
        hasRecording = true;
    }
    
    
}

