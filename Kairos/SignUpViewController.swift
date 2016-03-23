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
import FBSDKCoreKit
import SwiftSpinner
import UITextField_Shake

class SignUpViewController: UIViewController {
    
    // MARK: - UI Properties
    @IBOutlet weak var password: UITextField!
    
    // MARK: - Class Properties
    var manager: Manager?
    var userInfos: [NSObject : AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 15.0
        self.manager = Alamofire.Manager(configuration: configuration)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleGoogleSignUp:", name:kUSER_GOOGLE_AUTH_NOTIFICATION, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        Alamofire.Manager.sharedInstance.session.invalidateAndCancel()
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
                SpinnerManager.showWithAnimation("Retrieving informations...")
                let result = userInfos!["data"] as! FBSDKLoginManagerLoginResult
                facebookFetch(result, password: sourceVC.password!, completion: { () -> Void in
                    self.SignUpRequest()
                })
            case LoginSDK.Google.rawValue:
                SpinnerManager.showWithAnimation("Retrieving informations...")
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
        SpinnerManager.showWithAnimation("Processing...")
                self.password.shake(10,              // 10 times
                    withDelta: 5.0,  // 5 points wide
                    speed: 0.03,     // 30ms per shake
                    shakeDirection: ShakeDirection.Horizontal
                )
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
                SpinnerManager.show("The operation can't be completed", subtitle: "Tap to hide", completion: { () -> () in
                    SwiftSpinner.hide()
                })
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
        self.manager!.startRequestsImmediately = false
        
        let parameters = ["access_token": user.authentication.accessToken]
        let request = self.manager!.request(.GET, "https://www.googleapis.com/oauth2/v3/userinfo", parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    self.userInfos = ["first_name": json["given_name"].stringValue, "last_name": json["family_name"].stringValue, "email": json["email"].stringValue, "password" : password]
                    completion()
                }
            case .Failure(let error):
                SpinnerManager.show("The operation can't be completed", subtitle: "Tap to hide", completion: { () -> () in
                    SwiftSpinner.hide()
                })
                print(error)
            }
        }
        debugPrint(request)
        
        networkManager(request)
        request.resume()
        SpinnerManager.delay(seconds: 7.0, completion: {
            SpinnerManager.updateTitle("It's taking longer than expected...")
        })
    }
    
    func facebookFetch(result: FBSDKLoginManagerLoginResult, password: String, completion: () -> Void) {
        networkManager(nil)
        
        let parameters = ["fields": "email,first_name,last_name"]
        let request = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            if error == nil {
                if let value = result as? NSDictionary {
                    let json = JSON(value)
                    self.userInfos = ["first_name": json["first_name"].stringValue, "last_name": json["last_name"].stringValue, "email": json["email"].stringValue, "password" : password]
                    completion()
                }
            } else {
                SpinnerManager.show("The operation can't be completed", subtitle: "Tap to hide", completion: { () -> () in
                    SwiftSpinner.hide()
                })
                print(error)
            }
        }
    }
    
    func SignUpRequest() {
        self.manager!.startRequestsImmediately = false
        
        SpinnerManager.updateTitle("Trying to create user account")
        
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
                    SpinnerManager.delay(seconds: 1.0, completion: {
                        SpinnerManager.show("Completed", subtitle: "Tap to sign in", completion: { () -> () in
                            SwiftSpinner.hide()
                        })
                    })
                }
            case .Failure(let error):
                SpinnerManager.show("The operation can't be completed", subtitle: "Tap to hide", completion: { () -> () in
                    SwiftSpinner.hide()
                })
                print(error)
            }
        }
        debugPrint(request)
        
        networkManager(request)
        request.resume()
        SpinnerManager.delay(seconds: 7.0, completion: {
            SpinnerManager.updateTitle("It's taking longer than expected...")
        })
    }
    
    func networkManager(request: Request?) {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        
        manager?.listener = { (status) in
            print("Network Status Changed: \(status)")
            switch status {
            case .Reachable(.WWAN):
                request?.resume()
            case .Reachable(.EthernetOrWiFi):
                request?.resume()
            case .NotReachable:
                SpinnerManager.show("The Internet connection appears to be offline", subtitle: "Tap to hide", completion: { () -> () in
                    SwiftSpinner.hide()
                })
                manager?.startListening()
                request?.suspend()
            default:
                break
            }
        }
        manager?.startListening()
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
