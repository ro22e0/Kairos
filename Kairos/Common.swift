//
//  Common.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 17/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import SideMenu

let MainStoryboardID = "Main"
let CalendarStoryboardID = "Calendar"
let LoginStoryboardID = "Login"
let BoardStoryboardID = "Board"
let MenuStoryboardID = "Menu"
let FriendsStoryboardID = "Friends"
let ProfileStoryboardID = "Profile"
let SettingsStoryboardID = "Settings"

let kSEARCH_FRIENDS_NOTIFICATION = "kSearchFriends"

let kUSER_GOOGLE_AUTH_NOTIFICATION = "kUserGoogleAuth"
let kUSER_FB_AUTH_NOTIFICATION = "kUserFbAuth"

enum LoginSDK: String {
    case Facebook = "Facebook"
    case Google = "Google"
}

extension UIViewController {
    @IBAction private func menu() {
        presentViewController(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }

    @IBAction func showStoryboard(segue: UIStoryboardSegue) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = segue.destinationViewController
    }
    
    func setRootVC(storyboard: String) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)

        if let viewController = storyboard.instantiateInitialViewController() {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = viewController
        }
    }
}