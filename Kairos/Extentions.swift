//
//  Extentions.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 25/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation

extension String {
    static func mediumDateShortTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    static func mediumDateNoTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    static func fullDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .full
        return dateFormatter.string(from: date)
    }
}

extension UIColor {
    class func formerColor() -> UIColor {
        return UIColor(red: 0.14, green: 0.16, blue: 0.22, alpha: 1)
    }

    class func formerSubColor() -> UIColor {
        return UIColor(red: 0.9, green: 0.55, blue: 0.08, alpha: 1)
    }

    class func formerHighlightedSubColor() -> UIColor {
        return UIColor(red: 1, green: 0.7, blue: 0.12, alpha: 1)
    }
}

extension UIViewController {
    @IBAction fileprivate func menu() {
    }
    
    @IBAction func showStoryboard(_ segue: UIStoryboardSegue) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = segue.destination
    }
    
    func viewController(fromStoryboard storyboard: String, viewController name: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        return storyboard.instantiateViewController(withIdentifier: name)
    }
    
    func setRootVC(_ storyboard: String) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        if let viewController = storyboard.instantiateInitialViewController() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = viewController
        }
    }
}

extension UITableViewCell {
    func selected() {
    }
}

extension UIView {
    func round() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.clipsToBounds = true
        
    }

    func addBorder(_ color: CGColor) {
        self.layer.borderWidth = 3.0
        self.layer.borderColor = color
    }
}
