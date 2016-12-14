//
//  FriendsInviteTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 08/10/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class FriendsInviteTableViewController: UITableViewController {
    
    var searchController: UISearchController!
    var shouldShowSearchResults = true
    
    var friends = [User]()
    var onSelected: ((User, ()->Void) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.friends = FriendManager.sharedInstance.friends()
        configureSearchController()
        configure()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        searchController.active = true
//        dispatch_async(dispatch_get_main_queue(), {
//            self.searchController.searchBar.becomeFirstResponder()
//        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure() {
        self.tableView.tableFooterView = UIView()

        let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        self.tableView.backgroundView = blurEffectView
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        tableView.registerNib(UINib(nibName: "UserTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "userCell")
        tableView.allowsSelection = false
    }

    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        
        // Place the search bar view to the tableview headerview.
        self.navigationItem.titleView = searchController.searchBar
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shouldShowSearchResults ? self.friends.count : 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserTableViewCell
        
        // Configure the cell...
        cell.nameLabel.text = friends[indexPath.row].name
        
        //        let mutualFriends = friends[indexPath.row].mutualFriends?.allObjects as? [User]
        //        if let number = mutualFriends?.count where number > 0 {
        //            cell.mutualFriendsLabel.hidden = false
        //            cell.mutualFriendsLabel.text = String(number)  + "mutual friends"
        //        } else {
                    cell.mutualFriendsLabel.hidden = true
        //        }
        cell.onSelected = { user, done in
            self.onSelected!(user) {
                done()
            }
        }
        cell.tag = Int(friends[indexPath.row].id!)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
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

extension FriendsInviteTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if shouldShowSearchResults {
            let searchString = searchController.searchBar.text
            if !searchString!.isEmpty {
                self.friends = FriendManager.sharedInstance.all(filtered: searchString!, forFriends: true)
            } else {
                self.friends = FriendManager.sharedInstance.friends()
            }
            tableView.reloadData()
        }
    }
}

extension FriendsInviteTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No friends to show.")
    }
}