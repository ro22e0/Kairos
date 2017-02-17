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
import Fabric
import Crashlytics
import SwiftRecord
import DynamicColor
import Sync
import DATAStack
import PonyDebugger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.NS
        
        // Fetch update

//        let defautls = UserDefaults.standard
//        if let isLogged = defautls.value(forKey: userLoginKey) as? Bool, isLogged { // TODO
//            UserManager.shared.fetchAll()
//        }
        
        
        
        
        
        
        let debugger = PDDebugger.defaultInstance()
        
        // Enable Network debugging, and automatically track network traffic that comes through any classes that implement either NSURLConnectionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate or NSURLSessionDataDelegate methods.
        debugger?.enableNetworkTrafficDebugging()
        debugger?.forwardAllNetworkTraffic()
        
        // Enable Core Data debugging, and broadcast the main managed object context.
        debugger?.enableCoreDataDebugging()
        debugger?.add(dataStack.mainContext, withName: "Kairos")
        
        // Enable View Hierarchy debugging. This will swizzle UIView methods to monitor changes in the hierarchy
        // Choose a few UIView key paths to display as attributes of the dom nodes
        debugger?.enableViewHierarchyDebugging()
        debugger?.setDisplayedViewAttributeKeyPaths(["frame", "hidden", "alpha", "opaque", "accessibilityLabel", "text"])
    
        // Connect to a specific host
        // Or auto connect via bonjour discovery
        debugger?.autoConnect()
        // Or to a specific ponyd bonjour service
        //[debugger autoConnectToBonjourServiceNamed:@"MY PONY"];
        
        // Enable remote logging to the DevTools Console via PDLog()/PDLogObjects().
        debugger?.enableRemoteLogging()
        
        
        
        
        
        
        
        
        

        UINavigationBar.appearance().tintColor = .orangeTint()
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight),
            NSForegroundColorAttributeName: UIColor.orangeTint()
        ]
        UINavigationBar.appearance().isTranslucent = false
        UITabBar.appearance().backgroundColor = .white
        UITabBar.appearance().tintColor = .orangeTint()
        UITabBar.appearance().isTranslucent = false
        
        UIButton.appearance().tintColor = .orangeTint()
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
            ], for: .normal)
        
        //        UINavigationBar.appearance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeNotification), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: self.dataStack.mainContext)
        
        SwiftRecord.generateRelationships = true
        SwiftRecord.sharedRecord.managedObjectContext = self.dataStack.mainContext
        
        // Fabric
        Fabric.with([Crashlytics.self])
        
        // IQKeyboardManagerSwift
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
        // JLToast
        //        JLToastView.setDefaultValue(13, forAttributeName: JLToastViewCornerRadiusAttributeName, userInterfaceIdiom: .Unspecified)
        //        JLToastView.setDefaultValue(UIFont.systemFontOfSize(12, weight: UIFontWeightLight), forAttributeName: JLToastViewFontAttributeName, userInterfaceIdiom: .Unspecified)
        
        // Alamofire network manager
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        // Initialize Google sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self

        // Configure FBSDK
        FBSDKLoginButton.classForCoder()
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    var dataStack: DATAStack = {
        let dataStack = DATAStack(modelName: "Kairos")
        
        return dataStack
    }()
    
    func changeNotification(_ notification: Notification) {
        let deletedObjects = notification.userInfo![NSDeletedObjectsKey]
        print(deletedObjects)
        let insertedObjects = notification.userInfo![NSInsertedObjectsKey]
        print(insertedObjects)
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        try! self.dataStack.mainContext.save()
    }
}

extension AppDelegate: GIDSignInDelegate {
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation){
            return true
        } else if FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        return false
    }
    
    func application(_ application: UIApplication,
                     open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        
        if GIDSignIn.sharedInstance().handle(url,
                                                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                annotation: options[UIApplicationOpenURLOptionsKey.annotation]) {
            return true
        } else if FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?, annotation: options[UIApplicationOpenURLOptionsKey.annotation]) {
            return true
        }
        return false
    }
    
    // MARK: - GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            NotificationCenter.default.post(name: Notification.Name(rawValue: kUSER_GOOGLE_AUTH_NOTIFICATION), object: nil, userInfo:["success": true, "user": user])
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kUSER_GOOGLE_AUTH_NOTIFICATION), object: nil, userInfo:["success": false, "error": error])
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
              withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // [START_EXCLUDE]
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil,
            userInfo: ["statusText": "User has disconnected."])
        // [END_EXCLUDE]
    }
}

