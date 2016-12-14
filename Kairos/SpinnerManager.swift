//
//  SpinnerManager.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 22/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import SwiftSpinner
import Whisper

private let font = UIFont.systemFontOfSize(20, weight: UIFontWeightThin)

struct SpinnerManager {

    static func delay(seconds seconds: Double, completion: ()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * seconds))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }

    static func showWithAnimation(title: String) {
        SwiftSpinner.setTitleFont(font)
        SwiftSpinner.show(title)
    }
    
    static func showSpinner(title: String, subtitle: String, completion: ()->()) {
        SwiftSpinner.setTitleFont(font)
        SwiftSpinner.show(title, animated: false).addTapHandler({ completion() }, subtitle: subtitle)
    }

    static func updateTitle(title: String) {
        SwiftSpinner.sharedInstance.title = title
    }
    
    static func showWhistle(title: String, success: Bool = true) {
        var murmur = Murmur(title: title)

        if success {
            murmur.backgroundColor = .cyanColor()
        } else {
            murmur.backgroundColor = .redColor()
        }

        show(whistle: murmur, action: .Show(1.5))
    }
}