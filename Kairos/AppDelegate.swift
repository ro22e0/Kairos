//
//  AppDelegate.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 17/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import CoreData
import AlamofireNetworkActivityIndicator
import FBSDKLoginKit
import IQKeyboardManagerSwift
import JLToast
import SideMenu
import Fabric
import Crashlytics
import SwiftRecord
import DATAStack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.NS
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(20, weight: UIFontWeightLight)
        ]
        
        // SideMenu
        let storyboard = UIStoryboard(name: MenuStoryboardID, bundle: nil)
        let menuLeftNavigationController = storyboard.instantiateViewControllerWithIdentifier("LeftMenuNavigationController") as? UISideMenuNavigationController
        SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
        menuLeftNavigationController!.leftSide = true
        
        //        SideMenuManager.menuPresentMode = .ViewSlideOut
        //        SideMenuManager.menuAllowPushOfSameClassTwice = true
        //        SideMenuManager.menuAllowPopIfPossible = false
        //        SideMenuManager.menuWidth = max(round(min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height) * 0.75), 240)
        //        SideMenuManager.menuPresentMode = .MenuSlideIn
        //        SideMenuManager.menuAnimationPresentDuration = 0.35
        //        SideMenuManager.menuAnimationDismissDuration = 0.35
        //        SideMenuManager.menuAnimationFadeStrength = 0.5
        //        SideMenuManager.menuAnimationShrinkStrength = 0.90
        SideMenuManager.menuAnimationBackgroundColor = nil
        //        SideMenuManager.menuShadowOpacity = 0.5
        //        SideMenuManager.menuShadowColor = UIColor.darkGrayColor()
        //        SideMenuManager.menuShadowRadius = 10
        //        SideMenuManager.menuParallaxStrength = 1
        //        SideMenuManager.menuFadeStatusBar = true
        //        SideMenuManager.menuBlurEffectStyle = .Dark // Note: if you want cells in a UITableViewController menu to look good, make them a subclass of UITableViewVibrantCell!
        
        SwiftRecord.generateRelationships = true
        SwiftRecord.sharedRecord.managedObjectContext = self.dataStack.mainContext

        // Fabric
        Fabric.with([Crashlytics.self])
        
        // IQKeyboardManagerSwift
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
        // JLToast
        JLToastView.setDefaultValue(13, forAttributeName: JLToastViewCornerRadiusAttributeName, userInterfaceIdiom: .Unspecified)
        JLToastView.setDefaultValue(UIFont.systemFontOfSize(12, weight: UIFontWeightLight), forAttributeName: JLToastViewFontAttributeName, userInterfaceIdiom: .Unspecified)
        
        // Alamofire network manager
        NetworkActivityIndicatorManager.sharedManager.isEnabled = true
        
        // Initialize Google sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        
        // Configure FBSDK
        FBSDKLoginButton.classForCoder()
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack

    var dataStack: DATAStack = {
        let dataStack = DATAStack(modelName: "Kairos")
        
        return dataStack
    }()
    
    // MARK: - Core Data Saving support

    func saveContext() {
        try! self.dataStack.mainContext.save()
    }
}

extension AppDelegate: GIDSignInDelegate {
    func application(application: UIApplication,
                     openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        } else if FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        return false
    }
    
    func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        if GIDSignIn.sharedInstance().handleURL(url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String?, annotation: options[UIApplicationOpenURLOptionsAnnotationKey]) {
            return true
        } else if FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String?, annotation: options[UIApplicationOpenURLOptionsAnnotationKey]) {
            return true
        }
        return false
    }
    
    // MARK: - GIDSignInDelegate
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            NSNotificationCenter.defaultCenter().postNotificationName(kUSER_GOOGLE_AUTH_NOTIFICATION, object: nil, userInfo:["success": true, "user": user])
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(kUSER_GOOGLE_AUTH_NOTIFICATION, object: nil, userInfo:["success": false, "error": error])
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // [START_EXCLUDE]
        NSNotificationCenter.defaultCenter().postNotificationName(
            "ToggleAuthUINotification",
            object: nil,
            userInfo: ["statusText": "User has disconnected."])
        // [END_EXCLUDE]
    }
}

