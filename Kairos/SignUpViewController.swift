//
//  SignUpViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 17/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FBSDKLoginKit

class SignUpViewController: UIViewController {
    
    // MARK: - UI Properties
    
    // MARK: - Class Properties
    var manager: Manager?
    var userInfos: [NSObject : AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.manager = Alamofire.Manager(configuration: configuration)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleGoogleSignUp:", name:kUSER_GOOGLE_AUTH_NOTIFICATION, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Notifications methods
    @objc func handleGoogleSignUp(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let success = userInfo["success"] as! Bool
        
        if success {
            let user = userInfo["user"] as! GIDGoogleUser
            userInfos = ["type": LoginSDK.Google.rawValue, "data": user]
            performSegueWithIdentifier("kShowDefinePasswordSegue", sender: self)
        } else {
            let error = userInfo["error"] as! NSError
            
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Actions
    @IBAction func unwindSignUp(sender: UIStoryboardSegue) {
        if let sourceVC = sender.sourceViewController as? DefinePasswordViewController {
            let type = userInfos!["type"] as! String
            
            switch type {
            case LoginSDK.Facebook.rawValue:
                let result = userInfos!["data"] as! FBSDKLoginManagerLoginResult
                facebookFetch(result, password: sourceVC.password!, completion: { () -> Void in
                    self.SignUpRequest()
                })
            case LoginSDK.Google.rawValue:
                let user = userInfos!["data"] as! GIDGoogleUser
                googleFetch(user, password: sourceVC.password!, completion: { () -> Void in
                    self.SignUpRequest()
                })
            default:
                break
            }
        }
    }
    
    @IBAction func SignUp(sender: UIButton) {
        SignUpRequest()
    }
    
    @IBAction func GoogleSignUp(sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func FbSignUp(sender: UIButton) {
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = .SystemAccount
        
        let permissions = ["public_profile", "email"]
        loginManager.logInWithReadPermissions(permissions, fromViewController: self) { (result, error) -> Void in
            if error != nil {
                print(error.localizedDescription)
            } else if !result.isCancelled {
                self.userInfos = ["type": LoginSDK.Facebook.rawValue, "data": result]
                self.performSegueWithIdentifier("kShowDefinePasswordSegue", sender: self)
            } else {
                print("Cancelled")
            }
        }
    }
    
    // MARK: - Methods
    func googleFetch(user: GIDGoogleUser, password: String, completion: () -> Void) {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        self.manager!.startRequestsImmediately = false
        
        let parameters = ["access_token": user.authentication.accessToken]
        
        let request = self.manager!.request(.GET, "https://www.googleapis.com/oauth2/v3/userinfo", parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    self.userInfos = ["firstname": json["given_name"].stringValue, "lastname": json["family_name"].stringValue, "email": json["email"].stringValue, "password" : password]
                }
            case .Failure(let error):
                print(error)
            }
            completion()
        }
        debugPrint(request)
        
        networkManager(manager!, request: request)
        
        manager?.startListening()
        request.resume()
    }
    
    
    func facebookFetch(result: FBSDKLoginManagerLoginResult, password: String, completion: () -> Void) {
    }
    
    func SignUpRequest() {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        
        self.manager!.startRequestsImmediately = false
        let request = self.manager!.request(.GET, "https://demo1935961.mockable.io/hello").responseJSON { (response) in
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print("JSON: \(json)")
                }
            case .Failure(let error):
                print(error)
            }
        }
        debugPrint(request)
        
        networkManager(manager!, request: request)
        
        manager?.startListening()
        request.resume()
    }
    
    func networkManager(manager: NetworkReachabilityManager, request: Request) {
        manager.listener = { (status) in
            print("Network Status Changed: \(status)")
            switch status {
            case .Reachable(.WWAN):
                break
            case .Reachable(.EthernetOrWiFi):
                break
            case .NotReachable:
                manager.startListening()
            default:
                break
            }
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}

extension SignUpViewController: GIDSignInUIDelegate {
    // MARK: - GIDSignInUIDelegate
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
        presentViewController viewController: UIViewController!) {
            self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
        dismissViewController viewController: UIViewController!) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
}
