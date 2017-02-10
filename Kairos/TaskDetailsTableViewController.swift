//
//  TaskDetailsTableViewController.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Former

class TaskDetailsTableViewController: ButtonBarPagerTabStripViewController {
    
    var project: Project?
    var task: Task?
    var selectedTask: Task?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addSubTaskButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    
    fileprivate lazy var former: Former = Former(tableView: self.tableView)
    
    override func viewDidLoad() {
        customizeBar()
        super.viewDidLoad()

        title = project?.title
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: Notifications.TaskDidChange.rawValue), object: nil)
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            headerHeightConstraint.constant = self.tableView.contentSize.height
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.showTaskDetails(_:)), name: NSNotification.Name(rawValue: "ShowTaskDetails"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ShowTaskDetails"), object: nil)
        selectedTask = nil
    }
    
    ///  Reload data notification handler
    ///
    ///  - parameter notification: The notification
    @objc func reloadData(_ notification: Notification) {
        self.task = Task.find("id = %@", args: self.task?.id) as? Task
        if let task = self.task {
            configureView()
            self.reloadPagerTabStripView()
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.TaskDidChange.rawValue), object: nil)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func showTaskDetails(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let task = userInfo["task"] as? Task {
                selectedTask = task
                
                let storyboard = UIStoryboard(name: StoryboardID.Project.rawValue, bundle: nil)
                let destVC = storyboard.instantiateViewController(withIdentifier: "TaskDetailsTableViewController") as! TaskDetailsTableViewController
                destVC.task = selectedTask
                destVC.project = project
                self.navigationController?.pushViewController(destVC, animated: true)
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
    
    func configureView() {
        guard let task = task else {
            dismiss(animated: true, completion: nil)
            return
        }
        if task.parent != nil {
            buttonBarView.isHidden = true
            containerView.isHidden = true
            addSubTaskButton.isHidden = true
            title = task.parent?.title
        }
        
        self.tableView.tableFooterView = UIView()
        var headerRows = [RowFormer]()
        
        let taskHeader = CustomRowFormer<TaskHeaderCell>(instantiateType: .Nib(nibName: "TaskHeaderCell")) {
            $0.titleLabel.text = task.title
            $0.dateStartLabel.text = String.fullDate(task.dateStart as! Date)
            $0.dateEndLabel.text = String.fullDate(task.dateEnd as! Date)
            $0.selectionStyle = .none
            }.configure {
                $0.rowHeight = UITableViewAutomaticDimension
        }
        headerRows.append(taskHeader)
        let noteRow = TextViewRowFormer<FormTextViewCell>() {
            $0.selectionStyle = .none
            $0.titleLabel?.textColor = .formerColor()
            $0.titleLabel?.font = .boldSystemFont(ofSize: 15)
            }.configure {
                $0.text = task.notes
                $0.rowHeight = UITableViewAutomaticDimension
            }.onUpdate { cell in
                cell.cell.isUserInteractionEnabled = false
        }
        noteRow.update()
        
        let assigneesListRow = CustomRowFormer<UserListCell>(instantiateType: .Nib(nibName: "UserListCell")) {
            $0.users = TaskManager.shared.users(for: task)
            $0.onInfoSelected = {
                self.performSegue(withIdentifier: "showTaskAssignees", sender: $0)
            }
            }.configure {
                $0.rowHeight = 50
        }
        
        let createHeader: ((String) -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>() {
                $0.contentView.backgroundColor = .white
                $0.titleLabel?.textColor = .formerColor()
                $0.titleLabel?.font = .boldSystemFont(ofSize: 15)
                }.configure {
                    $0.viewHeight = 25
                    $0.text = text
            }
        }
        
        if let parentTask = task.parent {
            let parentTaskRow = LabelRowFormer<FormLabelCell>()
                .configure {
                    $0.text = "Parent task"
                    $0.subText = parentTask.title
                }.onSelected { [weak self] _ in
                    self?.former.deselect(animated: true)
            }
            headerRows.append(parentTaskRow)
        }
        
        let sectionHeader = SectionFormer(rowFormers: headerRows).set(headerViewFormer: nil)
        let sectionDescription = SectionFormer(rowFormer: noteRow).set(headerViewFormer: createHeader("Description"))
        
        let sectionAssignees = SectionFormer(rowFormer: assigneesListRow).set(headerViewFormer: createHeader("Assigned to"))
        
        self.former.append(sectionFormer: sectionHeader, sectionDescription, sectionAssignees)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "showEditTask":
                let destVC = segue.destination as! EditTaskTableViewController
                destVC.project = task?.project
                destVC.task = task
            case "showTaskAssignees":
                let destVC = segue.destination as! TaskAssigneesTableViewController
                destVC.task = task
            case "showAddSubTask":
                let navController = segue.destination as! UINavigationController
                let destVC = navController.viewControllers[0] as! EditTaskTableViewController
                destVC.parentTask = task
                destVC.project = project
            default:
                break
            }
        }
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let allTasks = TaskTableViewController(style: .plain, itemInfo: "SUBTASKS")
        if let tasks = task?.childTasks?.allObjects as? [Task] {
            allTasks.tasks = tasks
            allTasks.parentTask = task
        }
        return [allTasks]
    }
}
