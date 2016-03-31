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
        
        // Do any additional setup after loading the view.
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
