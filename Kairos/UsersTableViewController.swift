//
//  UsersTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 03/10/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class UsersTableViewController: UITableViewController {
    
    var searchController: UISearchController!
    var shouldShowSearchResults = false
    
    var users = [User]()
    var filteredUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if users.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }

    //    override func viewWillDisappear(_ animated: Bool) {
    //        searchController.isActive = false
    //        super.viewWillDisappear(animated)
    //    }
    
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
    
    func configureView() {
        self.tableView.tableFooterView = UIView()
        
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
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Name or email address"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        self.definesPresentationContext = true
        
        let searchBar = searchController.searchBar
        searchBar.tintColor = .orangeTint()
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .background()
        
        // Place the search bar view to the tableview headerview.
        tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shouldShowSearchResults ? filteredUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        
        // Configure the cell...
        let user = shouldShowSearchResults ? filteredUsers[indexPath.row] : users[indexPath.row]
        
        cell.configure(user: user)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        self.performSegue(withIdentifier: "showUserProfileSegue", sender: cell)
    }
    
    
    //    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        let additionalSeparatorThickness = CGFloat(5)
    //        let frame = CGRect(x: 0, y: cell.frame.size.height - additionalSeparatorThickness, width: cell.frame.size.width, height: additionalSeparatorThickness)
    //        let additionalSeparator = UIView(frame: frame)
    //        additionalSeparator.backgroundColor = .background()
    //        cell.addSubview(additionalSeparator)
    //    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UsersTableViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        if searchString != "" {
            shouldShowSearchResults = true
            self.filteredUsers = UserManager.shared.filtered(users: users, with: searchString!)
        } else {
            shouldShowSearchResults = false
        }
        tableView.reloadData()
    }
}

extension UsersTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No friends to show.")
    }
}
