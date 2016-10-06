//
//  FriendActionPopoverTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 21/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class FriendActionPopoverTableViewController: FormViewController {
    
    var friend: Friend?
    
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

    private func configure() {
//        title = "Complete your profile"

//        former = Former(tableView: UITableView())
        // Create RowFomers

        let remove = LabelRowFormer<UnfriendTableViewCell>(instantiateType: .Nib(nibName: "UnfriendTableViewCell")) {
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFontOfSize(15)
        }.configure {
            $0.text = "Unfriend" + " " + self.friend!.name!
            $0.rowHeight = 44
        }
        
        let section = SectionFormer(rowFormer: remove)
        former.append(sectionFormer: section)
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
