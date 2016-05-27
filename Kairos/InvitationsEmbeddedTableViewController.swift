//
//  InvitationsEmbeddedTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 25/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class InvitationsEmbeddedTableViewController: UITableViewController {
    
    // MARK: - Class Properties
    let requestCellID = "invitationCell"
    let pendingCellID = "sentInvitationCell"
    var itemInfo = IndicatorInfo(title: "View")
    
    var requestedFriends: [Friend]
    var pendingFriends: [Friend]
    
    // MARK: - Constructors
    
    init(style: UITableViewStyle, itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        pendingFriends = OwnerManager.sharedInstance.getFriends(withStatus: .Pending)
        requestedFriends = OwnerManager.sharedInstance.getFriends(withStatus: .Requested)
        
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationController?.navigationBar.translucent = false
        tableView.registerNib(UINib(nibName: "InvitationTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: requestCellID)
        tableView.registerNib(UINib(nibName: "SentInvitationTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: pendingCellID)
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pendingFriends.count
        }
        return requestedFriends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(requestCellID, forIndexPath: indexPath) as! InvitationTableViewCell
            
            cell.nameLabel.text = requestedFriends[indexPath.row].name
            cell.tag = Int(requestedFriends[indexPath.row].id!)
            
            return cell
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(pendingCellID, forIndexPath: indexPath) as! SentInvitationTableViewCell
        
        cell.nameLabel.text = pendingFriends[indexPath.row].name
        cell.tag = Int(pendingFriends[indexPath.row].id!)

        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

extension InvitationsEmbeddedTableViewController: IndicatorInfoProvider {
    // MARK: - IndicatorInfoProvider
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}