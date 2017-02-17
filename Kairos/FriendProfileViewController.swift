//
//  FriendProfileViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 17/02/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class FriendProfileViewController: UIViewController {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!

    @IBOutlet weak var tableView: UITableView!

    fileprivate lazy var former: Former = Former(tableView: self.tableView)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        acceptButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func accept(_ sender: Any) {
    }
    @IBAction func decline(_ sender: Any) {
    }
    @IBAction func invite(_ sender: Any) {
    }
    @IBAction func remove(_ sender: Any) {
    }
}
