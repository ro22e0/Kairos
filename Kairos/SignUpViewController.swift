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

class SignUpViewController: UIViewController {
    
    // MARK: - UI Properties
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    
    // MARK: - Class Properties
    var manager: SessionManager?
    var userInfos: [AnyHashable: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.facebookButton.round()
        self.googleButton.round()
        
        self.navigationItem.backBarButtonItem?.title = ""
        
        let configuration = URLSessionConfiguration.default
        self.manager = SessionManager(configuration: configuration)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.handleGoogleSignUp(_:)), name:NSNotification.Name(rawValue: kUSER_GOOGLE_AUTH_NOTIFICATION), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        manager?.session.invalidateAndCancel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Notifications methods
    @objc func handleGoogleSignUp(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let success = userInfo["success"] as! Bool
        
        if success {
            let user = userInfo["user"] as! GIDGoogleUser
            Spinner.showWithAnimation("Retrieving informations...")
            googleFetch(user, completion: { () -> Void in
                self.performSegue(withIdentifier: "kShowDefinePasswordSegue", sender: self)
            })
        } else {
            let error = userInfo["error"] as! NSError
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Actions
    @IBAction func unwindSignUp(_ sender: UIStoryboardSegue) {
        if let sourceVC = sender.source as? DefinePasswordViewController {
            userInfos!["password"] = sourceVC.password
            SignUpRequest()
        }
    }
    
    @IBAction func SignUp(_ sender: UIButton) {
        self.userInfos = ["name": fullnameTextField.text!, "email": emailTextField.text!, "password": passwordTextField.text!]
        SignUpRequest()
    }
    
    @IBAction func GoogleSignUp(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func FbSignUp(_ sender: UIButton) {
        fbSignIn()
    }
    
    // MARK: - Methods
    
    func fbSignIn() {
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = .systemAccount
        
        let permissions = ["public_profile", "email"]
        loginManager.logIn(withReadPermissions: permissions, from: self) { (result, error) -> Void in
            if error != nil {
                Spinner.showSpinner("The operation can't be completed", subtitle: "Tap to dismiss", completion: { () -> () in
                    SwiftSpinner.hide()
                })
                print(error!.localizedDescription)
            } else if !result!.isCancelled {
                self.userInfos = ["type": LoginSDK.Facebook.rawValue, "data": result!]
                Spinner.showWithAnimation("Retrieving informations...")
                self.facebookFetch(result!, completion: { () -> Void in
                    self.performSegue(withIdentifier: "kShowDefinePasswordSegue", sender: self)
                })
            } else {
                print("Cancelled")
            }
        }
    }
    
    fileprivate func googleFetch(_ user: GIDGoogleUser, completion: @escaping () -> Void) {
        self.userInfos = ["name": user.profile.name, "email": user.profile.email, "password": ""]
        SwiftSpinner.hide()
        if user.profile.email != "" {
            completion()
        } else {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    fileprivate func facebookFetch(_ result: FBSDKLoginManagerLoginResult, completion: @escaping () -> Void) {
        let parameters = ["fields": "email,first_name,last_name"]
        let request = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
        request!.start(completionHandler: { (connection, result, error) in
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
                Spinner.showSpinner("The operation can't be completed", subtitle: "Tap to dismiss", completion: { () -> () in
                    SwiftSpinner.hide()
                })
            }
        })
    }
    
    fileprivate func SignUpRequest() {
        let parameters = ["name": userInfos!["name"]!,"email": userInfos!["email"]!, "password": userInfos!["password"]!, "password_confirmation": userInfos!["password"]!]
        
        UserManager.shared.signUp(parameters as [String : Any]) { (status) in
            switch status {
            case .success:
                self.performSegue(withIdentifier: "showCompleteProfile", sender: self)
            case .error: break
            }
        }
    }
    
    func networkManager(_ manager: NetworkReachabilityManager?, request: Request?) {
        manager?.listener = { (status) in
            print("Network Status Changed: \(status)")
            switch status {
            case .reachable(.wwan):
                request?.resume()
            case .reachable(.ethernetOrWiFi):
                request?.resume()
            case .notReachable:
                Spinner.showSpinner("The Internet connection appears to be offline", subtitle: "Tap to dismiss", completion: { () -> () in
                    SwiftSpinner.hide()
                })
                request?.cancel()
            case .unknown:
                break
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

extension SignUpViewController: GIDSignInUIDelegate {
    // MARK: - GIDSignInUIDelegate
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
}
