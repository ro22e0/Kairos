//
//  DefinePasswordViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 19/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class DefinePasswordViewController: UIViewController {
    
    // MARK: - UI Properties
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    
    // MARK: - Class Properties
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        contentView.layer.cornerRadius = 20
        closeButton.round()
        
        addBlurEffect()
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.view.addSubview(blurView)
        
        self.view.addSubview(contentView)
        self.view.addSubview(closeButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func cancel(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "This will cancel the sign up process, are you sure ?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Continue", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: UIButton) {
        password = passwordTextField.text
        performSegue(withIdentifier: "unwindToSignUpSegue", sender: self)
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
