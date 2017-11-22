//
//  ViewController.swift
//  ChatterApp
//
//  Created by Kendall Lui on 3/30/16.
//  Copyright (c) 2016 Kendall Lui. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI


class ChatterDetectorViewController: UIViewController , MFMailComposeViewControllerDelegate{
    
    var detector:ChatterDetector?; // Comes from Tab BAR
    var audioFilePath:String?;
    var profileName:String?
    var isAudioFrequencyDataCalculated = false;
    var audio: AVAudioFile!

    @IBOutlet weak var audioPlotIndicator: UIActivityIndicatorView!
    @IBOutlet weak var AudioPlots: GraphView!
    
    //MARK: Parameter Fields
    
    @IBOutlet weak var newFeedrateTextField: UITextField!
    @IBOutlet weak var feedrateTextField: UITextField!
    @IBOutlet weak var spindleSpeedTextField: UITextField!
    @IBOutlet weak var maxSpindleSpeedTextField: UITextField!
    @IBOutlet weak var numberOfFlutesTextField: UITextField!
    @IBOutlet weak var newSpindleSpeedTextField: UITextField!
    @IBOutlet weak var calculateButton: UIButton!
    
    fileprivate var spindleSpeed:Int {
        get {
            if(spindleSpeedTextField.text != nil && spindleSpeedTextField.text != "") {
                return Int(spindleSpeedTextField.text!)!
            }
            return 0;
        }
    }
    
    fileprivate var maxSpindleSpeed:Int {
        get {
            if(maxSpindleSpeedTextField.text != nil && maxSpindleSpeedTextField.text != "") {
                return Int(maxSpindleSpeedTextField.text!)!
            }
            return 0;
        }
    }

    fileprivate var numberOfFlutes:Int {
        get {
            if(numberOfFlutesTextField.text != nil && numberOfFlutesTextField.text != "") {
                return Int(numberOfFlutesTextField.text!)!
            }
            return 0;
        }
    }
    
    fileprivate var newSpindleSpeed:Int {
        get {
            if(newSpindleSpeedTextField.text != nil && newSpindleSpeedTextField.text != "") {
                return Int(newSpindleSpeedTextField.text!)!
            }
            return 0;
        }
        set(item) {
            newSpindleSpeedTextField.text = "\(item)"
        }
    }
    fileprivate var newFeedrate:Int {
        get {
            if(newFeedrateTextField.text != nil && newFeedrateTextField.text != "") {
                return Int(newFeedrateTextField.text!)!
            }
            return 0;
        }
        set(item) {
            newFeedrateTextField.text = "\(item)"
        }
    }
    
    //Calculates chatter, switches to display FFT plot.
    func calculateChatter() {
        if(spindleSpeed > 0 && maxSpindleSpeed  > 0  && numberOfFlutes > 0) {
        	detector?.detectChatter(spindleSpeed, maxSpindleSpeed: maxSpindleSpeed, numberOfFlutes: numberOfFlutes)
            isAudioFrequencyDataCalculated = true;
            //updateAudioFrequencyPlot()
            newSpindleSpeed = Int((detector?.adjustedSpindleSpeed)!)
        }

        let message = String(describing: detector?.chatterFrequency) + "\n" + String(describing: detector?.forcedFrequencies[1])
        
        let alert = UIAlertController(title: "Chatter Details", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
	func updateAudioWaveformPlot()
    {
        AudioPlots.clearAllPlots()
        //Resets Audio Plots min and max because Frequency plots changes the range significantly
        AudioPlots.x_min = 0
        AudioPlots.x_max = 1
        AudioPlots.y_min = -1
        AudioPlots.y_max = 1

        let scaleFactor = max(Int(ceil(Double((detector?.audioSampleData[0].count)!)/3000)),1) //discreet number of plot points
        let cutAudioData_y = stride(from: 1, to: (detector?.audioSampleData[0].count)!, by: scaleFactor).map {
            Double((detector?.audioSampleData[0][$0])!)} //Skips every scaleFactor.
        let audioData_x = (0...cutAudioData_y.count - 1).map{Double($0)}
        let queue = DispatchQueue.main;
        audioPlotIndicator.startAnimating();
        queue.async {
            self.AudioPlots.addPlot(audioData_x, y_coors: cutAudioData_y, color: (20,200,200));
            self.audioPlotIndicator.stopAnimating();
        }
        detector?.calculateFrequencies()
    }
    func textFieldDidChange(_ textField: UITextField) { //For recaculating after parameters changed
        if(maxSpindleSpeed != 0 && spindleSpeed != 0 && numberOfFlutes != 0) {
            calculateChatter();
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = tabBarController as! BaseTabBarController;
        detector = tabBar.detector
        
        audioPlotIndicator.hidesWhenStopped = true;
        newSpindleSpeedTextField.isEnabled = false;
        newFeedrateTextField.isEnabled = false;
        self.title = "Chatter Detector"
        // Used for detecting when to refresh
        spindleSpeedTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
        maxSpindleSpeedTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for:  .editingDidEnd)
        numberOfFlutesTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for:  .editingDidEnd)
        feedrateTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for:  .editingDidEnd)


    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let toneURL = URL(fileURLWithPath: audioFilePath! )
        let error: NSErrorPointer = nil;
        do {
            audio = try AVAudioFile(forReading: toneURL, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: true)
        } catch let error1 as NSError {
            error?.pointee = error1
            audio = nil
        }
        detector = ChatterDetector(audioFile: audio);
        updateAudioWaveformPlot()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }

}


//Helper Function turns AudioSample Data into a [[Float]]
//Should Consider making it a double instead so we don't have to do conversions in the future.
private func extractAudioSampleData(_ audioFile: AVAudioFile) -> [[Float]]
{
    let error: NSErrorPointer? = nil
    let audioFrameBufferLength = AVAudioFrameCount(audioFile.length)
    //Creates an audio Buffer
    let audio_buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: audioFrameBufferLength)
    
    do {
        try audioFile.read(into: audio_buffer)
    } catch let error1 as NSError {
        error??.pointee = error1
    }
    //data.advancedBy(index).pointee
    //Extracts buffer data as float pointer
    let data = audio_buffer.floatChannelData
    var floatArray = [[Float]]() //Each channel has its own array.
    for index in 0...Int(audioFile.processingFormat.channelCount) - 1 {
        let buffer = UnsafeBufferPointer(start: data?.advanced(by: index).pointee  , count: Int(audioFrameBufferLength))
        floatArray.append(Array(buffer))
    }
    return floatArray
}




