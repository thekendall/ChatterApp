//
//  AudioRecorderAndEditor.swift
//  AudioRecordingAndEditor
//
//  Created by Kendall Lui on 8/31/16.
//  Copyright © 2016 thekendall. All rights reserved.
//

import Foundation
import AVFoundation

class AudioManager: NSObject, AVAudioRecorderDelegate {
    
    var recorder: AVAudioRecorder!
    var player:AVAudioPlayer!
    var audioSession: AVAudioSession!
    var recordingEnabled = false
    var audioPeak:[Double] = []
    var delegate:AudioManagerDelegate?;
    
    var validPlaybackAudioFile = false
    var recordedToTemp = false
    private var audioFileStringName = "temp.aiff"
    
    func record(recordDuration: Double) {
        if recorder == nil {
            startRecording(recordDuration)
        }
    }
    
    func stopRecording()
    {
        if(recorder != nil)
        {
            self.finishRecording(success:true)
        }
    }
    
    override init() {
        // Do any additional setup after loading the view, typically from a nib.
        super.init()
        audioSession = AVAudioSession.sharedInstance()
        //Defaults
        validPlaybackAudioFile = false
        audioFileStringName = "temp.aiff"
        
        do { //Initialize audio session
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() {
                [unowned self] (allowed:Bool) -> Void in //We don't have access to self in a queue so we pass it unowned self.
                dispatch_async(dispatch_get_main_queue()){
                    if allowed {
                        self.recordingEnabled = true; //unownedself
                    } else {
                        print("Failed to Record")
                    }
                }
            }
        } catch{
            print("Failed to Record")
        }
    }
    
    func startRecording() {
        startRecording(10.0)
    }
    
    func startRecording(forDuration: Double) {
        let audioFilename = getTemporaryDirectory().stringByAppendingString("/temp.aiff")
        let audioURL = NSURL(fileURLWithPath: audioFilename)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),//kAudioFormatLinearPCM
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: true,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMIsNonInterleaved: false,
        ]
        
        do {
            recorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            recorder.delegate = self;
            recorder.meteringEnabled = true
            recorder.delegate = self
            recorder.recordForDuration(forDuration)
            
        } catch {
            print("Error info: \(error)")
            finishRecording(success: false)
        }
    }
    
    
    func finishRecording(success success: Bool) {
        recorder.stop()
        recorder = nil
        validPlaybackAudioFile = success
        let audioFilename = getTemporaryDirectory().stringByAppendingString("/temp.aiff")
        loadAudioFile(audioFilename)
        print("\(audioFilename)")
        playback()
    }
    
    func getChannelPowerValue() -> Double
    {
        recorder.updateMeters()
        //print(Double(pow(10.0,(recorder.peakPowerForChannel(0)/20))))
        return Double(pow(10.0,(recorder.averagePowerForChannel(0)/20)))//peakPowerForChannel(0))
    }
    
    //MARK: Playback
    // Handles Playing Forward Pausing and Stopping.
    
    var audioFilePathString:String?
    
    func loadAudioFile(audioFilePathString: String) -> Bool
    {
        do {
            if(player != nil)
            {
                player.stop()
            }
            player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioFilePathString))
            player.prepareToPlay()
            self.audioFilePathString = audioFilePathString
        } catch {
            print("Error info: \(error)")
            return false
        }
        return true
    }
    
    func saveAudio(filename: String) -> String?
    {
        if(!recordedToTemp){return nil}
        do {
            let newPath = getDocumentsDirectory().stringByAppendingString("/\(filename).aiff")
            try NSFileManager.defaultManager().moveItemAtPath(audioFilePathString!, toPath: newPath)
            print("Made it here!")
            return newPath;
        } catch let error as NSError {
            print(error)
        }
        return nil;
        
    }
    
    func playback(time: Double = 0.0) {
        print("playback")
        if((player) != nil) {
            //player.playAtTime(time)
            player.play()
        }
    }
    
    func pausePlayback()
    {
        if((player) != nil) {
            player.pause()
        }
    }
    
    func stopPlayback()
    {
        if player != nil {
            player.stop()
            player = nil
        }
    }
    
    func getTimecode() -> NSTimeInterval
    {
        if player != nil && player.playing{
            return player.currentTime
        } else if recorder != nil {
            return recorder.currentTime
        }
        return 0.0
    }
    
    func getAudioLength() -> NSTimeInterval
    {
        if player != nil {
            return player.duration
        }
        return 0.0
    }
    
    func getAudioFilePath() -> String?
    {
        return audioFilePathString
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
        delegate?.audioDidFinishRecording()
        recordedToTemp = true;
    }
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getTemporaryDirectory() -> String { //gives us the directory
        return getDocumentsDirectory() //+ "/Temp" < Add this later...
    }
    
    func reset(){
        stopPlayback()
        stopRecording()
    }
    
    
}

protocol AudioManagerDelegate {
    func audioDidFinishRecording();
}


