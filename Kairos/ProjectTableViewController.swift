//
//  ProjectTableViewController.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class ProjectTableViewController: UITableViewController {

    var projects = [Project]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.projects = ProjectManager.shared.projects(withStatus: .Participating)
        print(projects.count)
        self.title = "Projects"
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 52
        self.tableView.register(UINib(nibName: "ProjectTableViewCell", bundle: nil), forCellReuseIdentifier: "projectCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.projects = ProjectManager.shared.projects(withStatus: .Participating)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///  Reload data notification handler
    ///
    ///  - parameter notification: The notification
    @objc func reloadData(_ notification: Notification) {
        self.projects = ProjectManager.shared.projects(withStatus: .Participating)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectTableViewCell

        // Configure the cell...
        let project = projects[indexPath.row]
        cell.titleLabel.text = project.title
        let members = ProjectManager.shared.allUsers(forProject: project)
        cell.membersLabel.text = String(members.count)
        cell.startLabel.text = String.shortDateNoTime(project.dateStart as! Date)
        cell.endLabel.text = String.shortDateNoTime(project.dateEnd as! Date)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        
        self.performSegue(withIdentifier: "showProjectDetails", sender: cell)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "showProjectDetails" {
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
            let destVC = segue.destination as! ProjectDetailsViewController
            // Pass the selected object to the new view controller.
            destVC.project = projects[indexPath.row]
        }
    }
}

extension ProjectTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Projects")
    }
}
