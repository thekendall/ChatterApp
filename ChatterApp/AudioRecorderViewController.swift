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
    var timer:NSTimer? = nil;
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
    private var audioFilePath:String?;
    private var profileName:String?;
    
    @IBOutlet weak var timecode: UILabel!
    
    @IBOutlet weak var AudioPlotter: GraphView!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var profileNameTextbox: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    @IBAction func record(sender: AnyObject) {
        if(!recording)
        {
            AudioPlotter.clearAllPlots()
            recording = true;
            audioManager.reset();
            audioManager.record(recordLength)
            AudioPlotter.autoscaleAxis = false
            AudioPlotter.x_min = 0
            AudioPlotter.x_max = recordLength;
            recordButton.setTitle("Stop", forState: .Normal)
            timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("updateDisplay"), userInfo: nil, repeats: true)
            waveformIndex = AudioPlotter.addPlot(x_coors: [0], y_coors: [0], color: (0,0,255))
            recordingLine = AudioPlotter.addPlot(x_coors: [0,0], y_coors:[1,-1], color:(255,0,0))
            //updateDisplay()
            hasRecording = false;
            
        } else {
            audioDidFinishRecording()
        }
    }
    
    @IBAction func save(sender: UIButton) {
        let profileNameFromTextBox = profileNameTextbox.text;
        if((profileNameFromTextBox) != nil)
        {
            //let path = NSBundle.mainBundle().pathForResource("wavTones.com.unregistred.dualfreq_600Hz_-6dBFS_1200Hz_-18dBFS_5s", ofType: ".wav")
            audioFilePath = audioManager.saveAudio(profileNameFromTextBox!) //path //test
            profileName = profileNameFromTextBox
        }
        performSegueWithIdentifier("ShowChatterDetector", sender: sender)

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
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> String {
        let ti = NSInteger(interval)
        let ms = Int((interval % 1) * 100)
        let seconds = ti % 60
        return String(format: "%0.2d:%0.2d",seconds,ms)
    }

//MARK: Standard ViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioManager.delegate = self;
        checkActivateSave()
        profileNameTextbox.addTarget(self, action: Selector("profileNameDidEdit") , forControlEvents: UIControlEvents.EditingChanged)
        AudioPlotter.x_min = 0.0
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowChatterDetector"
        {
            if let destinationVC = segue.destinationViewController as? ChatterDetectorViewController {
                destinationVC.audioFilePath = audioFilePath;
                destinationVC.profileName = profileName;
                print("\(audioFilePath)")

            }
        }
    }
    
    func profileNameDidEdit()
    {
        print("Did Edit")
        checkActivateSave()
    }
    
    private func checkActivateSave()
    {
        if(profileNameTextbox.text != "" && profileNameTextbox.text != nil && hasRecording) {
            saveButton.enabled = true;
        } else {
            saveButton.enabled = false;
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
        recordButton.setTitle("Record", forState: .Normal)
        hasRecording = true;
    }
    
    
}

