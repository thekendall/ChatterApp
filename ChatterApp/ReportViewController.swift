//
//  ReportViewController.swift
//  ChatterApp
//
//  Created by Kendall Lui on 11/22/17.
//  Copyright © 2017 Kendall Lui. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {
//    @IBAction func sendEmail(sender: UIButton) {
//        //Check to see the device can send email.
//        if( MFMailComposeViewController.canSendMail() ) {
//            let mailComposer = MFMailComposeViewController()
//            mailComposer.mailComposeDelegate = self
//            //Set the subject and message of the email
//            mailComposer.setSubject("Chatter Data: " + profileName!)
//            mailComposer.setMessageBody("Spindle Speed: " + String(spindleSpeed) +
//                "\n Number of Flutes: " + String(numberOfFlutes) + "\n Max Spindle Speed: " + String(maxSpindleSpeed), isHTML: false)
//            if let fileData = NSData(contentsOfFile: audioFilePath!) {
//                mailComposer.addAttachmentData(fileData as Data, mimeType: "audio/aiff", fileName: "chatterRecording.aiff")
//            }
//            self.present(mailComposer, animated: true, completion: nil)
//        }
//    }
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        self.dismiss(animated: true, completion: nil)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
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
