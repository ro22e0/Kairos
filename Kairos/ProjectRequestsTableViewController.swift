//
//  ProjectRequestsTableViewController.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class ProjectRequestsTableViewController: UITableViewController {

    var requestedProjects = [Project]()
    var refusedProjects = [Project]()

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: Notifications.ProjectStatusChange.rawValue), object: nil)
        requestedProjects = ProjectManager.shared.projects(withStatus: .Invited)
        refusedProjects = ProjectManager.shared.projects(withStatus: .Refused)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 75
        tableView.register(UINib(nibName: "ProjectRequestCell", bundle: Bundle.main), forCellReuseIdentifier: "projectCell")
        tableView.allowsSelection = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    ///  Reload data notification handler
    ///
    ///  - parameter notification: The notification
    @objc func reloadData(_ notification: Notification) {
        requestedProjects = ProjectManager.shared.projects(withStatus: .Invited)
        refusedProjects = ProjectManager.shared.projects(withStatus: .Refused)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return requestedProjects.count
        }
        return refusedProjects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectRequestCell
        var project: Project

        if indexPath.section == 0 {
            project = requestedProjects[indexPath.row]
            cell.acceptButton.isEnabled = true
            cell.declineButton.isEnabled = true
        } else {
            project = refusedProjects[indexPath.row]
            cell.declineButton.isEnabled = false
            cell.acceptButton.isEnabled = true
        }
        cell.tag = project.projectID!.intValue
        let members = ProjectManager.shared.allUsers(forProject: project)

        if let count = project.tasks?.count, count > 0 {
            cell.tasksLabel.text = String(count) + " tasks"
        } else {
            cell.tasksLabel.text = "No tasks"
        }

        cell.titleLabel.text = project.title
        cell.membersLabel.text = String(members.count)
        cell.dateStartLabel.text = String.shortDateNoTime(project.dateStart as! Date)
        cell.dateEndLabel.text = String.shortDateNoTime(project.dateEnd as! Date)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return requestedProjects.isEmpty ? nil : "REQUESTED"
        }
        return refusedProjects.isEmpty ? nil : "REFUSED"
    }
}

extension ProjectRequestsTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Projects Invitations")
    }
}
