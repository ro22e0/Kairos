//
//  SpinnerManager.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 22/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import SwiftSpinner

private let font = UIFont.systemFontOfSize(20, weight: UIFontWeightThin)

class SpinnerManager {

    class func delay(seconds seconds: Double, completion: ()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }

    class func showWithAnimation(title: String) {
        SwiftSpinner.setTitleFont(font)
        SwiftSpinner.show(title)
    }
    
    class func show(title: String, subtitle: String, completion: ()->()) {
        SwiftSpinner.setTitleFont(font)
        SwiftSpinner.show(title, animated: false).addTapHandler({ completion() }, subtitle: subtitle)
    }
    
    class func updateTitle(title: String) {
        SwiftSpinner.sharedInstance.title = title
    }
}