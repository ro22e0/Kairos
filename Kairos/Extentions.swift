//
//  Extentions.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 25/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation

extension String {
    static func mediumDateShortTime(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = .currentLocale()
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter.stringFromDate(date)
    }
    
    static func mediumDateNoTime(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = .currentLocale()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter.stringFromDate(date)
    }
    
    static func fullDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = .currentLocale()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .FullStyle
        return dateFormatter.stringFromDate(date)
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
    @IBAction private func menu() {
    }
    
    @IBAction func showStoryboard(segue: UIStoryboardSegue) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = segue.destinationViewController
    }
    
    func viewController(fromStoryboard storyboard: String, viewController name: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        return storyboard.instantiateViewControllerWithIdentifier(name)
    }
    
    func setRootVC(storyboard: String) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        if let viewController = storyboard.instantiateInitialViewController() {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
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
        self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2
        self.clipsToBounds = true
        
    }

    func addBorder(color: CGColor) {
        self.layer.borderWidth = 3.0
        self.layer.borderColor = color
    }
}