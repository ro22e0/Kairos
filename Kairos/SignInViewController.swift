//
//  SignInViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 17/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftyJSON
import SwiftSpinner

class SignInViewController: UIViewController {
    
    // MARK: - UI Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Class Properties
    var manager: Manager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text = "rona@mail.com"
        passwordTextField.text = "qwerty123"

        self.navigationItem.backBarButtonItem?.title = ""

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 15.0
        self.manager = Alamofire.Manager(configuration: configuration)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.handleGoogleSignIn(_:)), name:kUSER_GOOGLE_AUTH_NOTIFICATION, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Notifications methods
    @objc func handleGoogleSignIn(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let success = userInfo["success"] as! Bool
        
        if success {
            let user = userInfo["user"] as! GIDGoogleUser
            googleSignIn(user)
        } else {
            let error = userInfo["error"] as! NSError
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Actions
    @IBAction func SignIn(sender: UIButton) {
        SignInRequest()
    }
    
    @IBAction func GoogleSignIn(sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func FbSignIn(sender: UIButton) {
        fbSignIn()
    }
    
    // MARK: - Methods
    func fbSignIn() {
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
                print(FBSDKAccessToken.currentAccessToken().tokenString)
                print(FBSDKAccessToken.currentAccessToken().debugDescription)
            } else {
                print("Cancelled")
            }
        }
    }
    
    private func googleSignIn(user: GIDGoogleUser) {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        self.manager!.startRequestsImmediately = false
        
        print(user.authentication.idToken)
    }
    
    private func SignInRequest() {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        self.manager!.startRequestsImmediately = false
        
        SpinnerManager.showWithAnimation("Connecting to Kairos...")
        
        let headers = ["content-type": "application/json"]
        let parameters = ["email": emailTextField.text!, "password": passwordTextField.text!]
        let request = self.manager!.request(.POST, "http://api.kairos-app.xyz/auth/sign_in", parameters: parameters, encoding: .JSON, headers: headers).responseJSON { (response) in
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print("JSON: \(json)")
                    switch response.response!.statusCode {
                    case 200:
                        if let plist = Plist(name: "User-Info") {
                            let dict = plist.getMutablePlistFile()!
                            dict["access-token"] = response.response?.allHeaderFields["access-token"]
                            dict["client"] = response.response?.allHeaderFields["client"]
                            dict["uid"] = response.response?.allHeaderFields["uid"]
                            dict["id"] = json["data"]["id"].stringValue
                            do {
                                try plist.addValuesToPlistFile(dict)
                            } catch {
                                print(error)
                            }
                        } else {
                            print("Unable to get Plist")
                        }
                        self.setRootVC(BoardStoryboardID)
                    default:
                        SpinnerManager.show("Failed to connect", subtitle: "Tap to hide", completion: { () -> () in
                            SwiftSpinner.hide()
                        })
                    }
                }
            case .Failure(let error):
                SpinnerManager.show("Failed to connect", subtitle: "Tap to hide", completion: { () -> () in
                    SwiftSpinner.hide()
                })
                print(error)
            }
        }
        debugPrint(request)
        
        networkManager(manager!, request: request)
        
        manager?.startListening()
        request.resume()
    }
    
    func networkManager(manager: NetworkReachabilityManager?, request: Request) {
        manager!.listener = { (status) in
            print("Network Status Changed: \(status)")
            switch status {
            case .Reachable(.WWAN):
                break
            case .Reachable(.EthernetOrWiFi):
                break
            case .NotReachable:
                manager!.startListening()
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

extension SignInViewController: GIDSignInUIDelegate {
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

