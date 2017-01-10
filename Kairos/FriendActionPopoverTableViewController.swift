//
//  FriendActionPopoverTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 21/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class FriendActionPopoverTableViewController: UITableViewController {
    
    var friend: User?
    
    fileprivate lazy var former: Former = Former(tableView: self.tableView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredContentSize: CGSize {
        get {
            let height = self.tableView.rect(forSection: 0).height - 1
            return CGSize(width: super.preferredContentSize.width, height: height)
        }
        set { super.preferredContentSize = newValue }
    }
    
    fileprivate func configure() {
        //        title = "Complete your profile"
        tableView.tableFooterView = UIView()
        tableView.backgroundView?.backgroundColor = .white
        // Create RowFomers

        let remove = LabelRowFormer<UserActionTableViewCell>(instantiateType: .Nib(nibName: "UserActionTableViewCell")) {
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            }.configure {
                $0.text = "Unfriend" + " " + self.friend!.name!
                $0.rowHeight = 44
            }.onSelected {_ in
                self.removeFriend()
        }
        
        let section = SectionFormer(rowFormer: remove).set(headerViewFormer: nil)
        former.append(sectionFormer: section)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    fileprivate func removeFriend() {
        let user = User.find("id == %@", args: friend!.id!) as! User
        let parameters = ["user_id": user.id!]
        
        FriendManager.shared.remove(parameters) { (status) in
            switch status {
            case .success:
                SpinnerManager.showWhistle("kFriendSuccess")
            case .error(let error):
                SpinnerManager.showWhistle("kFriendError", success: false)
                print(error)
            }
        }
    }
}
