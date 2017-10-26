//
//  CuttingProfileTableViewController.swift
//  ChatterApp
//
//  Created by Developer on 5/16/17.
//  Copyright © 2017 Kendall Lui. All rights reserved.
//

import UIKit
import CoreData


class CuttingProfileTableViewController: UITableViewController {
    // Using Core Data
    var cuttingProfiles: [CuttingProfile] = [];

    override func viewDidLoad() {
        super.viewDidLoad()

        cuttingProfiles = fetch()!
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func fetch() -> [CuttingProfile]? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let moc = appDelegate.managedObjectContext
        let cuttingProfileFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CuttingProfile")
        
        do {
            let fetchedCuttingProfile = try moc.fetch(cuttingProfileFetch) as! [CuttingProfile]
            for cp in fetchedCuttingProfile {
                print(cp.profileName!);
            }
            return fetchedCuttingProfile;
            
        } catch {
            fatalError("Failed to fetch cutting profiles: \(error)")
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cuttingProfiles.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CuttingProfileCell"

        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CuttingProfileTableViewCell else {
            fatalError("not deque ")
        }

        // Configure the cell...
        let currentCuttingProfile = cuttingProfiles[indexPath.row];
        cell.numberofFlutes = currentCuttingProfile.flutes as! Int
        cell.spindleSpeed = currentCuttingProfile.spindleSpeed as! Int
        cell.profileName = currentCuttingProfile.profileName!
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    /*
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.performSegue(withIdentifier: "CuttingProfileShow", sender: self)
    }
*/

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
            case "CuttingProfileShow":
                guard let chatterProfileDetailViewController = segue.destination as? ChatterDetectorViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                let indexPath = self.tableView.indexPathForSelectedRow!
                let CuttingProfile = self.cuttingProfiles[indexPath.row]
                chatterProfileDetailViewController.cuttingProfile = CuttingProfile
            
        default:
            break;
        }
    }
    

}
