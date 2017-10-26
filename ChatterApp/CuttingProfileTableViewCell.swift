//
//  CuttingProfileTableViewCell.swift
//  ChatterApp
//
//  Created by Developer on 5/16/17.
//  Copyright © 2017 Kendall Lui. All rights reserved.
//

import UIKit

class CuttingProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var spindleSpeedLabel: UILabel!
    @IBOutlet weak var numberOfFlutesLabel: UILabel!
    
    var profileName = "" {
        didSet {
            profileNameLabel.text = profileName;
        }
    }
    
    var spindleSpeed = 0 {
        didSet {
            spindleSpeedLabel.text = "Spindle Speed: " + String(spindleSpeed);
        }
    }

    var numberofFlutes = 0 {
        didSet {
            numberOfFlutesLabel.text = "Flutes: " + String(numberofFlutes);
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
