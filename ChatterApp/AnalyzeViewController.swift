//
//  AnalyzeViewController.swift
//  ChatterApp
//
//  Created by Kendall Lui on 11/22/17.
//  Copyright © 2017 Kendall Lui. All rights reserved.
//

import UIKit

class AnalyzeViewController: UIViewController {

    var detector:ChatterDetector?;
    
    @IBOutlet weak var audioPlotIndicator: UIActivityIndicatorView!
    @IBOutlet weak var waveformPlot: GraphView!
    @IBOutlet weak var FFTPlot: GraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tabBar = tabBarController as! BaseTabBarController;
        detector = tabBar.detector
        audioPlotIndicator.hidesWhenStopped = true;
        updateAudioWaveformPlot()
        updateAudioFrequencyPlot();

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateAudioWaveformPlot()
    {
        waveformPlot.clearAllPlots()
        waveformPlot.x_min = 0
        waveformPlot.x_max = 1
        waveformPlot.y_min = -1
        waveformPlot.y_max = 1
        print(detector?.audioSampleData[0].count);
        let scaleFactor = max(Int(ceil(Double((detector?.audioSampleData[0].count)!)/3000)),1) //discreet number of plot points
        let cutAudioData_y = stride(from: 1, to: (detector?.audioSampleData[0].count)!, by: scaleFactor).map {
            Double((detector?.audioSampleData[0][$0])!)} //Skips every scaleFactor.
        let audioData_x = (0...cutAudioData_y.count - 1).map{Double($0)}
        let queue = DispatchQueue.main;
        audioPlotIndicator.startAnimating();
        queue.async {
            self.waveformPlot.addPlot(audioData_x, y_coors: cutAudioData_y, color: (20,200,200));
            self.audioPlotIndicator.stopAnimating();
        }
        detector?.calculateFrequencies()
    }

    
    func updateAudioFrequencyPlot()
    {
        if(detector?.fftStatus == ChatterDetector.FFTSTATUS.unknown) {
            detector?.calculateFrequencies();
        }
        while(detector?.fftStatus == ChatterDetector.FFTSTATUS.calculating) {
            
        }

        FFTPlot.clearAllPlots()
        let scaleFactor = max(Int(ceil(Double((detector?.amplitudes.count)!))),1)
        let audioData_y = stride(from: 1, to: (detector?.amplitudes.count)!, by:scaleFactor).map{
            Double((detector?.amplitudes[$0])!)
        }
        let audioData_x = stride(from: 1, to: (detector?.amplitudes.count)!, by:scaleFactor).map{
            Double((detector?.frequencies[$0])!)
        }
        
        let maxY = audioData_y.max()!
        if((detector?.chatterFrequency) != nil) { // Prevent from crash if chatter not detected.
            FFTPlot.addPlot([Double((detector?.chatterFrequency)!),Double((detector?.chatterFrequency)!)], y_coors: [0.0,maxY], color: (255,0,0))
        }
        /*
        for frq in (detector?.forcedFrequencies)! {
            FFTPlot.addPlot([Double(frq),Double(frq)], y_coors: [0.0,maxY], color: (0,255,0))
        }
 */
        FFTPlot.addPlot(audioData_x, y_coors: audioData_y, color: (0,0,255))
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}