//
//  ChatterDetector.swift
//  ChatterApp
//
//  Created by Kendall Lui on 3/30/16.
//  Copyright (c) 2016 Kendall Lui. All rights reserved.
//

import Foundation
import AVFoundation

class ChatterDetector{
    
    var audioSampleData = [[Float]]();
    //Plot Data
    var forcedFrequencies = [Float]();
    var amplitudes = [Float]();
    var frequencies:[Float] = [Float]()

    var fileLoaded = false;
    var chatterFrequency:Float! = 0.0;
    var adjustedSpindleSpeed:Float = 0.0;
    
    private var n:Int = 0;

    init(audioFile:AVAudioFile){
        loadDataFromAudioFile(audioFile);
    }
    
    init() {
        
    }
    
    // Load sample data from a buffer.
//    init() {
//        
//    }

    
    func loadDataFromAudioFile(audioFile:AVAudioFile)
    {
        audioSampleData = extractAudioSampleData(audioFile);
        fileLoaded = true;
    }
    
    func forcedFrequencyCalculator(spindleSpeed:Int, numberOfFlutes: Int)
    {
        forcedFrequencies = [Float]();
        // f = spindleSpeed * Flutes/ 60 see report
        let firstHarmonicFrequency = (Float)(spindleSpeed * numberOfFlutes) / 60.0;
        var i = 0;
        for( ; i < 10; i++){
            forcedFrequencies.append( (firstHarmonicFrequency * Float(i)));
        }
    }
    
    private func extractAudioSampleData(audioFile: AVAudioFile) -> [[Float]]
    {
        let error: NSErrorPointer = nil
        let audioFrameBufferLength = AVAudioFrameCount(audioFile.length)
        //Creates an audio Buffer
        let audio_buffer = AVAudioPCMBuffer(PCMFormat: audioFile.processingFormat, frameCapacity: audioFrameBufferLength)
        
        do {
            try audioFile.readIntoBuffer(audio_buffer)
        } catch let error1 as NSError {
            error.memory = error1
        }
        
        //Extracts buffer data as float pointer
        let data = audio_buffer.floatChannelData
        var floatArray = [[Float]]() //Each channel has its own array.
        for index in 0...Int(audioFile.processingFormat.channelCount) - 1 {
            let buffer = UnsafeBufferPointer(start: data.advancedBy(index).memory, count: Int(audioFrameBufferLength))
            floatArray.append(Array(buffer))
        }
        return floatArray
    }
    
    
    func calculateFrequencies()
    {
        let log2n = Int(ceil(log2(Float(audioSampleData[0].count))));
        n = 1 << log2n
        
        //let absFFT = fftAbsoluteMagnitude(audioSampleData[0][0...audioSampleData.count],Int32(log2n)) as [AnyObject] as [Float]; //Converts OBJ-C to [Float]
        let padding  = [Float](count: (n-audioSampleData[0].count), repeatedValue:0.0);
        let data = [Float](audioSampleData[0]) + padding
        let absFFT = fftAbsoluteMagnitude(data, Int32(log2n)) as [AnyObject] as! [Float];
        amplitudes = Array(absFFT[0 ..< (n / 2)]) // "J", "Q"
        frequencies = (0...amplitudes.count-1).map()
        { (index) -> Float in
                return Float(index) * 44100.0 / Float(self.n);
        };
    }
    
    func detectChatter(currentSpindleSpeed:Int, maxSpindleSpeed:Int, numberOfFlutes: Int)
    {
        calculateFrequencies();
        forcedFrequencyCalculator(currentSpindleSpeed, numberOfFlutes: numberOfFlutes)
        var fftAmps = amplitudes;
        var fftFreqs = frequencies;

        var validChatter = false;
        var count = 0;
        var maxAmpFreq:Float

        repeat {
            let indexMax = fftAmps.indexOf(fftAmps.maxElement()!)!;
            maxAmpFreq = fftFreqs.removeAtIndex(indexMax);
            if fftAmps.removeAtIndex(indexMax) < 1000 {break};
            fftFreqs[fftFreqs.count - 1 ] = 0.0
            fftAmps[fftAmps.count - 1 ] = 0.0
            var valid = true;
            for forced in forcedFrequencies
            {
                if forced*0.999 <= maxAmpFreq && maxAmpFreq <= forced*1.0002
                {
                    valid = false
                    break;
                }
                if forced*1.0002 > maxAmpFreq {break}
            }
            validChatter = valid;
            count++;
            
        } while !validChatter || count > fftAmps.count;
        if !validChatter
        {
            chatterFrequency = nil
        } else {
            chatterFrequency = maxAmpFreq;
            var newSpeed = chatterFrequency! * 60.0 / Float(numberOfFlutes);
            count = 1;
            while newSpeed * Float(count) < Float(maxSpindleSpeed)
            {
                newSpeed *= Float(count);
                count++;
            }
            count = 1;
            while newSpeed / Float(count) > Float(maxSpindleSpeed) && !(newSpeed * Float(count) < Float(maxSpindleSpeed))
            {
                newSpeed /= Float(count);
                count++;
            }
            adjustedSpindleSpeed = newSpeed;
        }
        print(adjustedSpindleSpeed)
    }
    


}