//
//  Spinner.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 22/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import SwiftSpinner
import Whisper

private let font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightThin)

struct Spinner {

    static func delay(_ seconds: Double, completion: @escaping ()->()) {
        let popTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * seconds)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }

    static func showWithAnimation(_ title: String) {
        SwiftSpinner.setTitleFont(font)
        SwiftSpinner.show(title)
    }

    static func showSpinner(_ title: String, subtitle: String, completion: @escaping ()->()) {
        SwiftSpinner.setTitleFont(font)
        SwiftSpinner.show(title, animated: false).addTapHandler({ completion() }, subtitle: subtitle)
    }

    static func updateTitle(_ title: String) {
        SwiftSpinner.sharedInstance.title = title
    }
    
    static func showWhistle(_ title: String, success: Bool = true) {
        var murmur = Murmur(title: title)

        if success {
            murmur.backgroundColor = .cyan
        } else {
            murmur.backgroundColor = .red
        }

        show(whistle: murmur, action: .show(1.5))
    }
    
    static func shout(message: Message) {
        let anno = Announcement(title: "My title", subtitle: "My subtitle", image: UIImage(), duration: 3.0)

        if let rootViewController = UIApplication.topViewController()?.navigationController {
            show(shout: anno, to: rootViewController)
        }
    }
}
