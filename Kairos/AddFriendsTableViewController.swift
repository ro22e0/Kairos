//
//  AddFriendsTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 03/10/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class AddFriendsTableViewController: UITableViewController {
    
    var searchController: UISearchController!
    var shouldShowSearchResults = false
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSearchController()
        configure()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchController.isActive = true
        DispatchQueue.main.async(execute: {
            self.searchController.searchBar.becomeFirstResponder()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func invite(_ user: User, done: @escaping ()->Void) -> Void {
        let parameters = ["user_id": user.id!]

        FriendManager.shared.invite(parameters) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kFriendSuccess")
                done()
            case .error(let error):
                Spinner.showWhistle("kFriendError", success: false)
                print(error)
            }
        }
    }

    func configure() {
        self.tableView.tableFooterView = UIView()

        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.tableView.backgroundView = blurEffectView

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "userCell")
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shouldShowSearchResults ? self.users.count : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        
        // Configure the cell...
        cell.nameLabel.text = users[indexPath.row].name

        let mutualFriends = users[indexPath.row].mutualFriends?.allObjects as? [User]
        if let number = mutualFriends?.count, number > 0 {
            cell.mutualFriendsLabel.isHidden = false
            cell.mutualFriendsLabel.text = String(number) + " mutual friends"
        } else {
            cell.mutualFriendsLabel.isHidden = true
        }
        cell.onSelected = { user, done in
            self.invite(user) {
                done("Invited")
            }
        }
        cell.tag = Int(users[indexPath.row].id!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
     override func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension AddFriendsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        self.dismiss(animated: true, completion: nil)
    }

    func updateSearchResults(for searchController: UISearchController) {
        if shouldShowSearchResults {
            let searchString = searchController.searchBar.text
            self.users = FriendManager.shared.friendsToAdd(filtered: searchString!)
            tableView.reloadData()
        }
    }
}

extension AddFriendsTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No friends to show.")
    }
}
