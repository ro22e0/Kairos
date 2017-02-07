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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
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
        searchController.delegate = self
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
    
    @IBAction func done(_ sender: Any) {
                self.dismiss(animated: true, completion: nil)
    }
}

extension AddFriendsTableViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
