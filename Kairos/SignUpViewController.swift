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
import SwiftSpinner
import UITextField_Shake
import JLToast

class SignUpViewController: UIViewController {
    
    // MARK: - UI Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Class Properties
    var manager: Manager?
    var userInfos: [NSObject : AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.backBarButtonItem?.title = ""
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 15.0
        self.manager = Alamofire.Manager(configuration: configuration)
    }
    
    override func viewWillDisappear(animated: Bool) {
        Alamofire.Manager.sharedInstance.session.invalidateAndCancel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions
    @IBAction func unwindSignUp(sender: UIStoryboardSegue) {
        if let sourceVC = sender.sourceViewController as? DefinePasswordViewController {
            userInfos!["password"] = sourceVC.password
            SignUpRequest()
        }
    }
    
    @IBAction func SignUp(sender: UIButton) {
        self.userInfos = ["email": emailTextField.text!, "password": passwordTextField.text!]
        SignUpRequest()
    }

    // MARK: - Methods
    
    private func SignUpRequest() {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        self.manager!.startRequestsImmediately = false
        
        SpinnerManager.showWithAnimation("Creating user account...")
        
        let headers = ["content-type": "application/json"]
        let parameters = ["email": userInfos!["email"]!, "password": userInfos!["password"]!, "password_confirmation": userInfos!["password"]!]
        let request = self.manager!.request(.POST, "http://api.kairos-app.xyz/auth", parameters: parameters, encoding: .JSON, headers: headers).responseJSON { (response) in
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
                        SpinnerManager.delay(seconds: 1.0, completion: {
                            SpinnerManager.show("Completed", subtitle: "Tap to sign in", completion: { () -> () in
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
                                SwiftSpinner.hide()
                                self.setRootVC(BoardStoryboardID)
                            })
                        })
                    default:
                        SpinnerManager.show("The operation can't be completed", subtitle: "Tap to hide", completion: { () -> () in
                            SwiftSpinner.hide()
                        })
                    }
                }
            case .Failure(let error):
                SpinnerManager.show("The operation can't be completed", subtitle: "Tap to hide", completion: { () -> () in
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
    
    func networkManager(manager: NetworkReachabilityManager?, request: Request?) {
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