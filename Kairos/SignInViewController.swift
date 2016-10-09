//
//  SignInViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 17/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Alamofire
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
        self.manager = Alamofire.Manager(configuration: configuration)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func SignIn(sender: UIButton) {
        SignInRequest()
    }
    
    // MARK: - Methods
    private func SignInRequest() {
        let parameters = ["email": emailTextField.text!, "password": passwordTextField.text!]
        
        UserManager.sharedInstance.signIn(parameters) { (status) in
            switch status {
            case .Success:
                self.setRootVC(BoardStoryboardID)
            case .Error: break
            }
        }
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
