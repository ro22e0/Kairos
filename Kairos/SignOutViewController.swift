//
//  SignOutViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 01/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class SignOutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.logout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func logout() {
        Router.needToken = true
        RouterWrapper.sharedInstance.request(.Logout) { (response) in
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    let defautls = NSUserDefaults.standardUserDefaults()
                    defautls.setValue(false, forKey: userLoginKeyConstant)
                    self.setRootVC(LoginStoryboardID)
                    break;
                default:
                    SpinnerManager.showWhistle("kFail", success: false)
                    break;
                }
            case .Failure(let error):
                SpinnerManager.showWhistle("kFail", success: false)
                print(error.localizedDescription)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
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
