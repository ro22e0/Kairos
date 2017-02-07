//
//  FriendsRequestsTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 25/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DZNEmptyDataSet

class FriendsRequestsTableViewController: UITableViewController {
    
    // MARK: - Class Properties
    let requestCellID = "invitationCell"
    let pendingCellID = "sentInvitationCell"
    var itemInfo = IndicatorInfo(title: "View")
    
    var requestedFriends = [User]()
    var pendingFriends = [User]()
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        configureView()
        self.pendingFriends = FriendManager.shared.friends(withStatus: .Pending)
        self.requestedFriends = FriendManager.shared.friends(withStatus: .Requested)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        self.tableView.tableFooterView = UIView()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 74
        self.navigationController?.navigationBar.isTranslucent = false
        tableView.register(UINib(nibName: "InvitationTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: requestCellID)
        tableView.register(UINib(nibName: "SentInvitationTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: pendingCellID)
        tableView.allowsSelection = false
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return requestedFriends.count
        }
        return pendingFriends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: requestCellID, for: indexPath) as! InvitationTableViewCell
            
            cell.nameLabel.text = requestedFriends[indexPath.row].name
            let mutualFriends = requestedFriends[indexPath.row].mutualFriends?.allObjects as? [User]
            if let number = mutualFriends?.count, number > 0 {
                cell.mutualFriendsLabel.isHidden = false
                cell.mutualFriendsLabel.text = String(number)  + " mutual friends"
            } else {
                cell.mutualFriendsLabel.isHidden = true
            }
            
            cell.tag = Int(requestedFriends[indexPath.row].id!)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: pendingCellID, for: indexPath) as! SentInvitationTableViewCell
        
        cell.nameLabel.text = pendingFriends[indexPath.row].name
        cell.tag = Int(pendingFriends[indexPath.row].id!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return requestedFriends.isEmpty ? nil : "REQUESTED"
        }
        return pendingFriends.isEmpty ? nil : "INVITED"
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FriendsRequestsTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No requests")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "When you have friends requests, you'll see them here.")
    }
}
