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
    enum FFTSTATUS {
        case unknown
        case calculating
        case calculated
    }
    var audioSampleData = [[Float]]();
    //Plot Data
    var forcedFrequencies = [Float]();
    var amplitudes = [Float]();
    var frequencies:[Float] = [Float]()
    var fileLoaded = false;
    var chatterFrequency:Float! = 0.0;
    var adjustedSpindleSpeed:Float = 0.0;
    var fftStatus = FFTSTATUS.unknown;
    
    
    fileprivate var n:Int = 0;

    init(audioFile:AVAudioFile){
        loadDataFromAudioFile(audioFile);
    }
    
    init() {
        
    }

    func loadDataFromAudioFile(_ audioFile:AVAudioFile)
    {
        audioSampleData = extractAudioSampleData(audioFile);
        fileLoaded = true;
    }
    
    func forcedFrequencyCalculator(_ spindleSpeed:Int, numberOfFlutes: Int)
    {
        forcedFrequencies = [Float]();
        // f = spindleSpeed * Flutes/ 60 see report
        let firstHarmonicFrequency = (Float)(spindleSpeed * numberOfFlutes) / 60.0;
        //for( ; i < 10; i += 1)
        for i in 0..<20
        {
            forcedFrequencies.append( (firstHarmonicFrequency * Float(i)));
        }
    }
    
    fileprivate func extractAudioSampleData(_ audioFile: AVAudioFile) -> [[Float]]
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
        
        //Extracts buffer data as float pointer
        let data = audio_buffer.floatChannelData
        var floatArray = [[Float]]() //Each channel has its own array.
        for index in 0...Int(audioFile.processingFormat.channelCount) - 1 {
            let buffer = UnsafeBufferPointer(start: data?.advanced(by: index).pointee, count: Int(audioFrameBufferLength))
            floatArray.append(Array(buffer))
        }
        return floatArray
    }
    
    
    func calculateFrequencies()
    { // Calculates the Fourier Transform
        if(fileLoaded) {
            let queue = DispatchQueue(label: "io.thekendall.fft");
            self.fftStatus = FFTSTATUS.calculating
            queue.async {
                let log2n = Int(ceil(log2(Float(self.audioSampleData[0].count))));
                self.n = 1 << log2n
                
                //let absFFT = fftAbsoluteMagnitude(audioSampleData[0][0...audioSampleData.count],Int32(log2n)) as [AnyObject] as [Float]; //Converts OBJ-C to [Float]
                let padding  = [Float](repeating: 0.0, count: (self.n-self.audioSampleData[0].count));
                let data = [Float](self.audioSampleData[0]) + padding
                let absFFT = fftAbsoluteMagnitude(data, Int32(log2n)) as [AnyObject] as! [Float];
                self.amplitudes = Array(absFFT[0 ..< (self.n / 2)]) // "J", "Q"
                self.frequencies = (0...self.amplitudes.count-1).map()
                    { (index) -> Float in
                        return Float(index) * 44100.0 / Float(self.n); // For 44100 Sample rate
                };
                self.fftStatus = FFTSTATUS.calculated
            }

        }
    }
    
    func detectChatter(_ currentSpindleSpeed:Int, maxSpindleSpeed:Int, numberOfFlutes: Int)
    {

        switch fftStatus {
        case FFTSTATUS.unknown:
            calculateFrequencies();
        case FFTSTATUS.calculating:
                while(FFTSTATUS.calculating == FFTSTATUS.calculating) {}
            default:
                break;
        }
        forcedFrequencyCalculator(currentSpindleSpeed, numberOfFlutes: numberOfFlutes)
        var fftAmps = amplitudes;
        var fftFreqs = frequencies;

        var validChatter = false;
        var count = 0;
        var maxAmpFreq:Float

        repeat {
            let indexMax = fftAmps.index(of: fftAmps.max()!)!;
            maxAmpFreq = fftFreqs.remove(at: indexMax);
            if fftAmps.remove(at: indexMax) < 1000 {break};
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
            count += 1;
            
        } while !validChatter || count > fftAmps.count;
        if !validChatter
        {
            chatterFrequency = nil
        } else {
            chatterFrequency = maxAmpFreq;
            var newSpeed = chatterFrequency! * 60.0 / Float(numberOfFlutes);
            count = 1;
            print("newspeed \(newSpeed * Float(count))")
            print("maxSpeed \(maxSpindleSpeed)")
            var temp_speed = newSpeed
            while (temp_speed) < Float(maxSpindleSpeed)
            {
                temp_speed = newSpeed * Float(count);
                count += 1;
            }
            count = 1;
            while (temp_speed) > Float(maxSpindleSpeed)
            {
                temp_speed = newSpeed / Float(count);
                count += 1;
            }
            count = 1;
            newSpeed = temp_speed
            adjustedSpindleSpeed = newSpeed;
        }
        print(adjustedSpindleSpeed)
    }
    


}
