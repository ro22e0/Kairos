//
//  ProjectDetailsViewController.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ProjectDetailsViewController: ButtonBarPagerTabStripViewController {
    
    // MARK: - Details view
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tasksLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var shadowView: UIView!
    
    var project: Project?
    var selectedTask: Task?
    
    override func viewDidLoad() {
        customizeBar()
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: Notifications.ProjectDidChange.rawValue), object: nil)
        configureDetailsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: Notifications.ProjectStatusChange.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showTaskDetails(_:)), name: NSNotification.Name(rawValue: "ShowTaskDetails"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.ProjectStatusChange.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowTaskDetails"), object: nil)
        selectedTask = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///  Reload data notification handler
    ///
    ///  - parameter notification: The notification
    @objc func reloadData(_ notification: Notification) {
        self.project = Project.find("id = %@", args: self.project?.id) as? Project
        if let project = self.project, project.userStatus != UserStatus.Refused.rawValue {
            configureDetailsView()
            self.reloadPagerTabStripView()
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.ProjectDidChange.rawValue), object: nil)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func showTaskDetails(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let task = userInfo["task"] as? Task {
                selectedTask = task
                self.performSegue(withIdentifier: "showTaskDetails", sender: self)
            }
        }
    }
    
    func configureDetailsView() {
        if let project = self.project, project.userStatus == UserStatus.Owner.rawValue {
            editButton.isEnabled = true
            editButton.tintColor = nil
        } else {
            editButton.isEnabled = false
            editButton.tintColor = .clear
        }
        
        acceptButton.setImage(UIImage(named: "Checkmark"), for: UIControlState())
        acceptButton.setImage(UIImage(named: "Checkmark Filled"), for: .disabled)
        declineButton.setImage(UIImage(named: "Delete"), for: UIControlState())
        declineButton.setImage(UIImage(named: "Delete Filled"), for: .disabled)
        acceptButton.isEnabled = false
        
        titleView.text = project?.title
        descriptionLabel.text = project?.notes
        if let count = project?.tasks?.count, count > 0 {
            tasksLabel.text = String(count) + " tasks"
        } else {
            tasksLabel.text = "No tasks"
        }
        let members = ProjectManager.shared.allUsers(forProject: project!)
        membersLabel.text = String(members.count)
        startLabel.text = String.shortDateNoTime(project!.dateStart as! Date)
        endLabel.text = String.shortDateNoTime(project!.dateEnd as! Date)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "showProjectMembers":
                let destVC = segue.destination as! ProjectMembersTableViewController
                destVC.project = project
            case "showEditProject":
                let destVC = segue.destination as! EditProjectTableViewController
                destVC.project = project
            case "showAddTask":
                let navController = segue.destination as! UINavigationController
                let destVC = navController.viewControllers[0] as! EditTaskTableViewController
                destVC.project = project
            case "showTaskDetails":
                let destVC = segue.destination as! TaskDetailsTableViewController
                destVC.task = selectedTask
            default:
                break
            }
        }
    }
    
    func customizeBar() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = .orangeTint()
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 1.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = .orangeTint()
        }
    }
    
    @IBAction func accept(_ sender: Any) {
        let parameters = ["id": project!.id!]
        
        ProjectManager.shared.accept(parameters) { (status) in
            switch status {
            case .success:
                self.acceptButton.isEnabled = false
                self.declineButton.isEnabled = true
                Spinner.showWhistle("kProjectSuccess")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.ProjectStatusChange.rawValue), object: nil)
            case .error(let error):
                Spinner.showWhistle("kProjectError", success: false)
                print(error)
            }
        }
    }
    
    @IBAction func decline(_ sender: Any) {
        let parameters = ["id": project!.id!]
        
        ProjectManager.shared.refuse(parameters) { (status) in
            switch status {
            case .success:
                self.declineButton.isEnabled = false
                self.acceptButton.isEnabled = true
                Spinner.showWhistle("kProjectSuccess")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.ProjectStatusChange.rawValue), object: nil)
            case .error(let error):
                Spinner.showWhistle("kProjectError", success: false)
                print(error)
            }
        }
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let allTasks = TaskTableViewController(style: .plain, itemInfo: "ALL TASKS")
        let tm = TaskManager.shared
        allTasks.tasks = tm.tasks(for: project!)
        let myTasks = TaskTableViewController(style: .plain, itemInfo: "MY TASKS")
        myTasks.tasks = tm.tasks(for: project!, assignedTo: UserManager.shared.current.user)
        return [allTasks, myTasks]
    }
}
