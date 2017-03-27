//
//  ForgotPasswordViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 27/03/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Arrow

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func forgotPass(_ sender: Any) {
        let params = ["email": emailTextField.text!]
        
        RouterWrapper.shared.request(.resetPass(params)) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        //TODO : Show SafariVC
                    }
                default:
                    break
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
