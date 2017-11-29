//
//  BaseTabBarController.swift
//  ChatterApp
//
//  Created by Kendall Lui on 11/22/17.
//  Copyright © 2017 Kendall Lui. All rights reserved.
//

import UIKit
import CoreData

class BaseTabBarController: UITabBarController{

    var detector = ChatterDetector();
    var cuttingProfile:NSManagedObject?;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Mark: CoreData
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "CuttingProfile",
                                                in: managedContext)!
        let profile = NSManagedObject(entity: entity,
                                      insertInto: managedContext) //NewProfile

        profile.setValue(name, forKeyPath: "profileName")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func fetch() -> [CuttingProfile]? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let moc = appDelegate.persistentContainer.viewContext
        let cuttingProfileFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CuttingProfile")
        
        do {
            let fetchedCuttingProfile = try moc.fetch(cuttingProfileFetch) as! [CuttingProfile]
            return fetchedCuttingProfile;
        } catch {
            fatalError("Failed to fetch cutting profiles: \(error)")
        }
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
