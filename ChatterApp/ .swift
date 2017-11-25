//
//  CuttingProfile.swift
//  ChatterApp
//
//  Created by Developer on 5/15/17.
//  Copyright © 2017 Kendall Lui. All rights reserved.
//

import Foundation
import CoreData

class CuttingProfile: NSManagedObject {
    
    // Insert code here to add functionality to your managed object subclass
    @NSManaged var audioPath: String?
    @NSManaged var profileName: String?
    @NSManaged var spindleSpeed: NSNumber?
    @NSManaged var maxSpindleSpeed: NSNumber?
    @NSManaged var flutes: NSNumber?
}
