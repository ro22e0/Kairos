//
//  LoadingViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 17/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    // MARK: - UI Properties
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
            self.loadingActivityIndicator.startAnimating()
            self.loadingActivityIndicator.alpha = 1.0
        }) { (completed) -> Void in
            if completed {
                self.checkStart()
            }
        }
    }
    
    // MARK: - Methods
    func checkStart() {
        var storyboard: UIStoryboard
        let defautls = UserDefaults.standard
        if let userHasLogged = defautls.bool(forKey: userLoginKey) as? Bool {
            storyboard = userHasLogged ? UIStoryboard(name: BoardStoryboardID, bundle: nil) : UIStoryboard(name: LoginStoryboardID, bundle: nil)
        } else {
            storyboard = UIStoryboard(name: LoginStoryboardID, bundle: nil)
        }
        // storyboard = UIStoryboard(name: BoardStoryboardID, bundle: nil) // COMMENT
        if let viewController = storyboard.instantiateInitialViewController() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = viewController
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
