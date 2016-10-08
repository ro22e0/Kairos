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
import JLToast

class SignUpViewController: UIViewController {
    
    // MARK: - UI Properties
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    
    // MARK: - Class Properties
    var manager: Manager?
    var userInfos: [NSObject : AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.facebookButton.round()
        self.googleButton.round()
        
        self.navigationItem.backBarButtonItem?.title = ""
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 15.0
        self.manager = Alamofire.Manager(configuration: configuration)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.handleGoogleSignUp(_:)), name:kUSER_GOOGLE_AUTH_NOTIFICATION, object: nil)
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
            SpinnerManager.showWithAnimation("Retrieving informations...")
            googleFetch(user, completion: { () -> Void in
                self.performSegueWithIdentifier("kShowDefinePasswordSegue", sender: self)
            })
        } else {
            let error = userInfo["error"] as! NSError
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Actions
    @IBAction func unwindSignUp(sender: UIStoryboardSegue) {
        if let sourceVC = sender.sourceViewController as? DefinePasswordViewController {
            userInfos!["password"] = sourceVC.password
            SignUpRequest()
        }
    }
    
    @IBAction func SignUp(sender: UIButton) {
        self.userInfos = ["name": fullnameTextField.text!, "email": emailTextField.text!, "password": passwordTextField.text!]
        SignUpRequest()
    }
    
    @IBAction func GoogleSignUp(sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func FbSignUp(sender: UIButton) {
        fbSignIn()
    }
    
    // MARK: - Methods
    
    func fbSignIn() {
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = .SystemAccount
        
        let permissions = ["public_profile", "email"]
        loginManager.logInWithReadPermissions(permissions, fromViewController: self) { (result, error) -> Void in
            if error != nil {
                SpinnerManager.showSpinner("The operation can't be completed", subtitle: "Tap to dismiss", completion: { () -> () in
                    SwiftSpinner.hide()
                })
                print(error.localizedDescription)
            } else if !result.isCancelled {
                self.userInfos = ["type": LoginSDK.Facebook.rawValue, "data": result]
                SpinnerManager.showWithAnimation("Retrieving informations...")
                self.facebookFetch(result, completion: { () -> Void in
                    self.performSegueWithIdentifier("kShowDefinePasswordSegue", sender: self)
                })
            } else {
                print("Cancelled")
            }
        }
    }
    
    private func googleFetch(user: GIDGoogleUser, completion: () -> Void) {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        self.manager!.startRequestsImmediately = false
        
        let parameters = ["access_token": user.authentication.accessToken]
        let request = self.manager!.request(.GET, "https://www.googleapis.com/oauth2/v3/userinfo", parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    self.userInfos = ["name": json["given_name"].stringValue + json["family_name"].stringValue, "email": json["email"].stringValue, "password": ""]
                    SwiftSpinner.hide()
                    if json["email"].stringValue != "" {
                        completion()
                    } else {
                        GIDSignIn.sharedInstance().signIn()
                    }
                }
            case .Failure(let error):
                SpinnerManager.showSpinner("The operation can't be completed", subtitle: "Tap to dismiss", completion: { () -> () in
                    SwiftSpinner.hide()
                })
                print(error)
            }
            manager?.stopListening()
        }
        debugPrint(request)
        
        networkManager(manager, request: request)
        request.resume()
    }
    
    private func facebookFetch(result: FBSDKLoginManagerLoginResult, completion: () -> Void) {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        networkManager(manager, request: nil)
        
        let parameters = ["fields": "email,first_name,last_name"]
        let request = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            if error == nil {
                if let value = result as? NSDictionary {
                    let json = JSON(value)
                    self.userInfos = ["name": json["first_name"].stringValue + json["last_name"].stringValue, "email": json["email"].stringValue, "password": ""]
                    SwiftSpinner.hide()
                    if json["email"].stringValue != "" {
                        completion()
                    } else {
                        self.fbSignIn()
                    }
                }
            } else {
                SpinnerManager.showSpinner("The operation can't be completed", subtitle: "Tap to dismiss", completion: { () -> () in
                    SwiftSpinner.hide()
                })
                print(error)
            }
            manager?.stopListening()
        }
    }
    
    private func SignUpRequest() {
        let parameters = ["name": userInfos!["name"]!,"email": userInfos!["email"]!, "password": userInfos!["password"]!, "password_confirmation": userInfos!["password"]!]

        UserManager.sharedInstance.signUp(parameters) { (status) in
            switch status {
            case .Success:
                self.performSegueWithIdentifier("showCompleteProfile", sender: self)
            case .Error: break
            }
        }
    }
    
    func networkManager(manager: NetworkReachabilityManager?, request: Request?) {
        manager?.listener = { (status) in
            print("Network Status Changed: \(status)")
            switch status {
            case .Reachable(.WWAN):
                request?.resume()
            case .Reachable(.EthernetOrWiFi):
                request?.resume()
            case .NotReachable:
                SpinnerManager.showSpinner("The Internet connection appears to be offline", subtitle: "Tap to dismiss", completion: { () -> () in
                    SwiftSpinner.hide()
                })
                request?.cancel()
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
