//
//  Common.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 17/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import SideMenu
import CoreData

let MainStoryboardID = "Main"
let CalendarStoryboardID = "Calendar"
let LoginStoryboardID = "Login"
let BoardStoryboardID = "Board"
let MenuStoryboardID = "Menu"
let FriendsStoryboardID = "Friends"
let ProfileStoryboardID = "Profile"
let SettingsStoryboardID = "Settings"

let kUSER_GOOGLE_AUTH_NOTIFICATION = "kUserGoogleAuth"

let kEventWillSaveNotification = "EventWillSave"
let kCalendarWillSaveNotification = "CalendarWillSave"

let userLoginKeyConstant = "userLoginKey"

enum LoginSDK: String {
    case Facebook = "Facebook"
    case Google = "Google"
}

enum FriendStatus: String {
    case Pending
    case Requested
    case Blocked
    case Accepted
}

extension UIViewController {
    @IBAction private func menu() {
        presentViewController(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
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