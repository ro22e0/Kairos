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
    var manager: SessionManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = ""
        
        emailTextField.text = "ronael.bajazet@gmail.com"
        passwordTextField.text = "qwerty123"

        let configuration = URLSessionConfiguration.default
        self.manager = SessionManager(configuration: configuration)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func SignIn(_ sender: UIButton) {
        SignInRequest()
    }
    
    // MARK: - Methods
    fileprivate func SignInRequest() {
        let parameters = ["email": emailTextField.text!, "password": passwordTextField.text!]
        
        UserManager.shared.signIn(parameters as [String : Any]) { (status) in
            switch status {
            case .success:
                UserManager.shared.fetchAll() {
                    self.setRootVC(BoardStoryboardID)
                }
            case .error: break
            }
        }
    }
    
    func networkManager(_ manager: NetworkReachabilityManager, request: Request) {
        manager.listener = { (status) in
            print("Network Status Changed: \(status)")
            switch status {
            case .reachable(.wwan):
                break
            case .reachable(.ethernetOrWiFi):
                break
            case .notReachable:
                manager.startListening()
            default:
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
