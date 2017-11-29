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


class ChatterDetectorViewController: UIViewController , MFMailComposeViewControllerDelegate {
    
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

        let scaleFactor = max(Int(ceil(Double((detector?.audioSampleData[0].count)!)/2000)),1) //discreet number of plot points
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

    @IBOutlet weak var feedrateSelectorButton: SelectorButton!
    @IBOutlet weak var feedrateUnits: UILabel!
    
    @IBAction func feedrateSelectorToggle(_ sender: SelectorButton) {
        sender.selectorState += 1
        feedrateUnits.text = feedrateSelectorButton.currentTitle;
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
        feedrateSelectorButton.selectorValues = ["in/s","mm/s"]
        
//        //Unit Picker Setup
//        feedrateUnitPicker.frame = CGRect(x:0,y:self.view.frame.height, width:self.view.frame.width, height:UIScreen.main.bounds.height/2.65)
//        feedrateUnitPicker.dataSource = self;
//        feedrateUnitPicker.delegate = self;
//        feedrateUnitPicker.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        feedrateUnitPicker.isHidden = true;
//        self.view.addSubview(feedrateUnitPicker)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated:Bool) {
        super.viewWillDisappear(animated)
        let tab = tabBarController as! BaseTabBarController;
        tab.detector = detector!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
//        self.dismissUIPicker()
    }
    
//    func dismissUIPicker() {
//        print("Second")
//        if(feedRateUnit.isHighlighted) {return}
//        UIView.animate(
//            withDuration: 0.1,
//            delay: 0.0,
//            options: .curveEaseOut,
//            animations: {
//                self.feedrateUnitPicker.frame.origin.y = self.view.frame.maxY;
//        }) { (completed) in
//            self.tabBarController?.tabBar.isHidden = false;
//            self.feedrateUnitPicker.isHidden = true;
//        }
//
//    }
//    
//    // MARK: UIPickerView Delegation
//    
//    @IBOutlet weak var feedRateUnit: UIButton!
    
//    var feedrateUnitPicker: UIPickerView = UIPickerView()
//    let feedRateUnits = ["in/s","mm/s"];
//    
//
//    @IBAction func pickFeedRateUnits(_ sender: Any) {
//        if(feedrateUnitPicker.isHidden) {
//            self.tabBarController?.tabBar.isHidden = true;
//            self.feedrateUnitPicker.frame.origin.y = self.view.frame.height;
//            self.feedrateUnitPicker.frame.origin.x = 0;
//            let calculatedSection = (self.view.frame.height) - self.feedrateUnitPicker.frame.height
//            
//            feedrateUnitPicker.isHidden = false;
//            self.feedrateUnitPicker.frame.origin.y = self.view.frame.maxY;
//            UIView.animate(
//                withDuration: 0.2,
//                delay: 0.0,
//                options: .curveEaseIn,
//                animations: {
//                    self.feedrateUnitPicker.frame.origin.y = calculatedSection;
//            }) { (completed) in
//                
//            }
//        }
////        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatterDetectorViewController.dismissUIPicker))
////        view.addGestureRecognizer(tap);
//    }
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1;
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return feedRateUnits.count;
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return feedRateUnits[row];
//
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        feedRateUnit.setTitle(feedRateUnits[row], for: UIControlState.normal);
//    }
//    


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




