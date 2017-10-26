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
    
    @IBOutlet weak var plotLoadingIndicator:UIActivityIndicatorView!
    var detector = ChatterDetector();
    var audioFilePath:String?;
    var profileName:String? {
        didSet {
        }
    }
    @IBOutlet weak var profileNameLabel: UILabel!
    
    var isAudioFrequencyDataCalculated = false;
    var audio: AVAudioFile!{
        didSet
        {
            
        }
    }

    @IBOutlet weak var AudioPlots: GraphView!
    
    //MARK: Parameter Fields
    
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


    @IBOutlet weak var plotChangeToggle: UISegmentedControl!
    
    @IBAction func PlotChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        	case 0:
                updateAudioWaveformPlot()
                break;
        	case 1:
            	updateAudioFrequencyPlot()
                break;
        	default:
            	break;
        }
    }
    //Calculates chatter, switches to display FFT plot.
    @IBAction func calculateChatter(_ sender: AnyObject) {
        plotLoadingIndicator.startAnimating()
        if(spindleSpeed > 0 && maxSpindleSpeed  > 0  && numberOfFlutes > 0) {
        	detector.detectChatter(spindleSpeed, maxSpindleSpeed: maxSpindleSpeed, numberOfFlutes: numberOfFlutes)
            isAudioFrequencyDataCalculated = true;
            updateAudioFrequencyPlot()
            newSpindleSpeed = Int(detector.adjustedSpindleSpeed)
        }
        let message = String(detector.chatterFrequency) + "\n" + String(detector.forcedFrequencies[1])
        
        let alert = UIAlertController(title: "Chatter Details", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        

        plotLoadingIndicator.stopAnimating()

    }
    
	func updateAudioWaveformPlot()
    {
        AudioPlots.clearAllPlots()
        //Resets Audio Plots min and max because Frequency plots changes the range significantly
        AudioPlots.x_min = 0
        AudioPlots.x_max = 1
        AudioPlots.y_min = -1
        AudioPlots.y_max = 1

        let scaleFactor = max(Int(ceil(Double(detector.audioSampleData[0].count)/1000)),1) //discreet number of plot points
        let cutAudioData_y = stride(from: 1, to: detector.audioSampleData[0].count, by: scaleFactor).map {
            Double(detector.audioSampleData[0][$0])} //Skips every scaleFactor.
        let audioData_x = (0...cutAudioData_y.count - 1).map{Double($0)}
        AudioPlots.addPlot(audioData_x, y_coors: cutAudioData_y, color: (20,200,200))
    }
    
    func updateAudioFrequencyPlot()
    {
        if(!isAudioFrequencyDataCalculated) {return}
        AudioPlots.clearAllPlots()
        let scaleFactor = max(Int(ceil(Double(detector.amplitudes.count)/1000)),1)
        let audioData_y = stride(from: 1, to: detector.amplitudes.count, by:scaleFactor).map{
        	Double(detector.amplitudes[$0])
        }
        let audioData_x = stride(from: 1, to: detector.amplitudes.count, by:scaleFactor).map{
            Double(detector.frequencies[$0])
        }
		let maxY = audioData_y.max()!
        if((detector.chatterFrequency) != nil) { // Prevent from crash if chatter not detected.
        	AudioPlots.addPlot([Double(detector.chatterFrequency),Double(detector.chatterFrequency)], y_coors: [0.0,maxY], color: (255,0,0))
        }
        for frq in detector.forcedFrequencies {
            AudioPlots.addPlot([Double(frq),Double(frq)], y_coors: [0.0,maxY], color: (0,255,0))

        }

        AudioPlots.addPlot(audioData_x, y_coors: audioData_y, color: (0,0,255))
        plotChangeToggle.selectedSegmentIndex = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newSpindleSpeedTextField.isEnabled = false;
        self.title = "Chatter Detector"
        plotLoadingIndicator.hidesWhenStopped = true
        plotLoadingIndicator.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        profileNameLabel.text = profileName;
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

    @IBAction func sendEmail(sender: UIButton) {
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            //Set the subject and message of the email
            mailComposer.setSubject("Chatter Data: " + profileName!)
            mailComposer.setMessageBody("Spindle Speed: " + String(spindleSpeed) +
                "\n Number of Flutes: " + String(numberOfFlutes) + "\n Max Spindle Speed: " + String(maxSpindleSpeed), isHTML: false)
            if let fileData = NSData(contentsOfFile: audioFilePath!) {
                    mailComposer.addAttachmentData(fileData as Data, mimeType: "audio/aiff", fileName: "chatterRecording.aiff")
                }
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
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


