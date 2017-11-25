//
//  SelectorButton.swift
//  ChatterApp
//
//  Created by Kendall Lui on 11/24/17.
//  Copyright © 2017 Kendall Lui. All rights reserved.
//

import UIKit

class SelectorButton: UIButton {
    var selectorState:Int = 0 {
        didSet{
            self.setTitle(selectorValue, for: .normal)
        }
    }
    var selectorValue:String {
        get {
            return selectorValues[selectorState%selectorValues.count];
        }
    }
    
    var selectorValues:[String] = [""];
    
}
