//
//  EditTaskTableViewController.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class EditTaskTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    var project: Project?
    var task: Task?
    
    fileprivate lazy var former: Former = Former(tableView: self.tableView)
    fileprivate var sectionMembers: SectionFormer!
    fileprivate var sectionDelete: SectionFormer!
    fileprivate var rows = [RowFormer]()
    fileprivate var addPerson: RowFormer!
    fileprivate var deleteRow: RowFormer?
    
    fileprivate var addedUsers = [User: UserStatus]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if self.task == nil {
            self.navigationItem.title = "New Task"
            self.task = Task.temporary()
            set(users: [UserManager.shared.current.user!])
        } else {
            self.navigationItem.title = "Edit Task"
            deleteRow = LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.textAlignment = .center
                $0.titleLabel.textColor = .red
                }
                .configure { row in
                    row.text = "Delete task"
                }.onSelected { row in
                    self.delete()
            }
        }
        configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure() {
        self.tableView.contentInset.top = -10
        self.tableView.tableFooterView = UIView()
        tableView.backgroundColor = .background()
        
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        //        self.tableView.estimatedRowHeight = 44
        
        let nameRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 20)
            }.configure {
                $0.placeholder = "Task Name"
                $0.text = task?.title
            }.onTextChanged { (text) in
                self.task?.title = text
        }
        
        let noteRow = TextViewRowFormer<FormTextViewCell>() {
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            $0.selectionStyle = .none
            }.configure {
                $0.placeholder = "Description"
                $0.text = task?.notes
                $0.rowHeight = 100
            }.onTextChanged { (text) in
                self.task?.notes = text
        }

        let startRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Start date"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFont(ofSize: 15)
            $0.selectionStyle = .none
            }.configure {
                if let date = task?.dateStart {
                    $0.date = date as Date
                } else {
                    $0.date = self.project!.dateStart! as Date
                    self.task?.dateStart = $0.date as NSDate?
                }
            }.inlineCellSetup {
                $0.datePicker.minimumDate = self.project!.dateStart! as Date
                $0.datePicker.maximumDate = self.project!.dateEnd! as Date
                $0.datePicker.datePickerMode = .date
            }.displayTextFromDate(String.mediumDateNoTime)
        
        let endRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "End date"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFont(ofSize: 15)
            $0.selectionStyle = .none
            }.configure {
                if let date = task?.dateEnd {
                    $0.date = date as Date
                } else {
                    $0.date = self.project!.dateStart! as Date
                    self.task?.dateEnd = $0.date as NSDate?
                }
            }.inlineCellSetup {
                $0.datePicker.minimumDate = self.project!.dateStart! as Date
                $0.datePicker.maximumDate = self.project!.dateEnd! as Date
                $0.datePicker.datePickerMode = .date
            }.displayTextFromDate(String.mediumDateNoTime)
        
        endRow.onDateChanged { date in
            if startRow.date.compare(date) == .orderedDescending {
                startRow.update {
                    $0.date = date
                }
            }
            self.task?.dateEnd = date as NSDate?
        }
        
        startRow.onDateChanged { date in
            if endRow.date.compare(date) == .orderedAscending {
                endRow.update {
                    $0.date = date
                }
            }
            self.task?.dateStart = date as NSDate?
        }
        
        let tm = TaskManager.shared
        set(users: tm.users(for: task!))
        
        addPerson = LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .orange
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            }.configure {
                $0.text = "Assign to..."
                $0.cell.accessoryType = .disclosureIndicator
                $0.cell.selectionStyle = .none
                $0.rowHeight = 44
            }.onSelected { [weak self] _ in
                let storyboard = UIStoryboard(name: FriendsStoryboardID, bundle: nil)
                let destVC = storyboard.instantiateViewController(withIdentifier: "FriendsInviteTableViewController") as! FriendsInviteTableViewController
                destVC.friends = ProjectManager.shared.users(withStatus: .Participating, forProject: self!.project!)
                destVC.onSelected = { user, done in
                    self?.invite(user, done: done)
                }
                let nvc = UINavigationController(rootViewController: destVC)
                self?.present(nvc, animated: true, completion: nil)
        }
        rows.append(addPerson)
        
        // Create Headers
        
        let createHeader: ((String) -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>() {
                $0.contentView.backgroundColor = .background()
                }
                .configure {
                    $0.viewHeight = 30
                    $0.text = text
            }
        }
        
        // Create SectionFormers
        
        let sectionHeader = SectionFormer(rowFormers: [nameRow, noteRow]).set(headerViewFormer: createHeader("DETAILS"))
        let sectionDates = SectionFormer(rowFormers: [startRow, endRow]).set(headerViewFormer: createHeader("PERIOD"))
        sectionMembers = SectionFormer(rowFormers: rows).set(headerViewFormer: createHeader("ASSIGNEES"))
        former.append(sectionFormer: sectionHeader, sectionDates, sectionMembers)
        
        if let delRow = deleteRow {
            sectionDelete = SectionFormer(rowFormer: delRow).set(headerViewFormer: createHeader(""))
            former.append(sectionFormer: sectionDelete)
        }
    }
    
    func set(users: [User]) {
        for user in users {
            addedUsers[user] = .Participating
            let member = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                $0.statusColorView.isHidden = true
                $0.statusLabel.isHidden = true
                }.configure {
                    $0.text = user.name
                    $0.rowHeight = 45
            }
            if !user.isEqual(UserManager.shared.current.user) {
                member.onSelected{ [weak self] cell in
                    self!.selectedUser(user, cell: cell)
                }
            }
            rows.append(member)
        }
    }
    
    func reloadMembers() {
        former.remove(rowFormers: sectionMembers.rowFormers)
        rows.removeAll()
        for (user, _) in addedUsers {
            let member = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                $0.statusColorView.isHidden = true
                $0.statusLabel.isHidden = true
                }.configure {
                    $0.text = user.name
                    $0.rowHeight = 45
            }
            if !user.isEqual(UserManager.shared.current.user) {
                member.onSelected{ [weak self] cell in
                    self!.selectedUser(user, cell: cell)
                }
            }
            rows.append(member)
        }
        rows.append(addPerson)
        sectionMembers.add(rowFormers: rows)
        former.reload(sectionFormer: sectionMembers)
        //        rows.append(addPerson)
    }
    
    fileprivate func invite(_ user: User, done: (String)->Void) -> Void {
        
        let isIn = addedUsers.contains { (u, status) -> Bool in
            return user == u && status != .Removed
        }

        if !isIn {
            addedUsers[user] = .Participating
            //            if !TaskManager.shared.userIsIn(task!, user: user) {
            let member = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                $0.statusColorView.isHidden = true
                $0.statusLabel.isHidden = true
                }.configure {
                    $0.text = user.name
                    $0.rowHeight = 45
                }.onSelected{ [weak self] cell in
                    self!.selectedUser(user, cell: cell)
            }
            Spinner.showWhistle("kTaskSuccess")
            done("Added")
            former.insertUpdate(rowFormer: member, above: addPerson, rowAnimation: .automatic)
            former.reload(sectionFormer: sectionMembers)
            // }
        } else {
            Spinner.showWhistle("kTaskAlreadyAdded", success: false)
            done("Already added")
        }
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
    
    // MARK: - Navigation
    
    fileprivate func selectedUser(_ user: User, cell: LabelRowFormer<CollaboratorTableViewCell>) {
        let storyboard = UIStoryboard(name: ProjectStoryboardID, bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "UserTaskActionTableViewController") as! UserTaskActionTableViewController
        destVC.user = user
        destVC.task = self.task
        destVC.remove = { user in
            //            if self.addedUsers[user] == UserStatus.Invited {
            //                if let user = User.find("id == %@", args: user) as? User {
            //                    TaskManager.shared.delete(user: user, fromTask: self.task!)
            //                }
            //                self.addedUsers.removeValue(forKey: user)
            //            } else {
            self.addedUsers[user] = .Removed
            //            }
            self.former.removeUpdate(rowFormer: cell)
        }
        if addedUsers[user] == .Participating {
            destVC.owner = { user in
                self.addedUsers[user] = .Owner
                self.reloadMembers()
            }
        }
        
        destVC.modalPresentationStyle = .popover
        destVC.preferredContentSize = CGSize(width: self.view.frame.width, height: 43)
        let popoverPC = destVC.popoverPresentationController
        
        popoverPC?.permittedArrowDirections = .up
        popoverPC?.delegate = self
        popoverPC?.sourceView = cell.cell
        popoverPC?.sourceRect = CGRect(x: cell.cell.frame.width / 2, y: cell.cell.frame.height, width: 1, height: 1)
        self.present(destVC, animated: true, completion: nil)
    }
    
    fileprivate func delete() {
        let parameters = ["id": task!.id, "project_id": project!.id]
        
        TaskManager.shared.delete(parameters) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kTaskSuccess")
                print(DataSync.dataStack().viewContext)
                print(DataSync.dataStack().mainContext)
                self.task?.delete()
                self.task?.save()
                print(self.task?.title)
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.TaskDidChange.rawValue), object: nil)
                if self.presentingViewController is UITabBarController {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController!.popViewController(animated: true)
                }
                //                do {
                //                    try DataSync.dataStack().mainContext.save()
                //                } catch (let error) {
                //                    print(error)
            //                }
            case .error(let error):
                Spinner.showWhistle("kTaskError", success: false)
                print(error)
            }
        }
    }
    
    fileprivate func create() {
        var parameters = task!.dictionaryWithValues(forKeys: ["title"])
        parameters["project_id"] = project!.id
        parameters["parent_id"] = nil
        parameters["description"] = task!.notes
        parameters["date_start"] = String.formatDateApi(task!.dateStart! as Date)
        parameters["date_end"] = String.formatDateApi(task!.dateEnd! as Date)
        var added = [Int]()
        var removed = [Int]()
        
        addedUsers.forEach { (user, status) in
            switch status {
            case .Participating:
                added.append(user.id!.intValue)
            case .Removed:
                removed.append(user.id!.intValue)
            default:
                break
            }
        }
        parameters["added"] = added
        parameters["removed"] = removed
        
        TaskManager.shared.create(parameters as [String : Any]) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kTaskSuccess")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.TaskDidChange.rawValue), object: nil)
                self.dismiss(animated: true, completion: nil)
            case .error(let error):
                Spinner.showWhistle("kTaskError", success: false)
                print(error)
            }
        }
    }
    
    fileprivate func update() {
        var parameters = task!.dictionaryWithValues(forKeys: ["id", "title"])
        parameters["project_id"] = project!.id
        parameters["parent_id"] = nil
        parameters["description"] = task!.notes
        parameters["date_start"] = String.formatDateApi(task!.dateStart! as Date)
        parameters["date_end"] = String.formatDateApi(task!.dateEnd! as Date)
        var added = [Int]()
        var removed = [Int]()
        
        addedUsers.forEach { (user, status) in
            switch status {
            case .Participating:
                added.append(user.id!.intValue)
            case .Removed:
                removed.append(user.id!.intValue)
            default:
                break
            }
        }
        parameters["added"] = added
        parameters["removed"] = removed
        
        TaskManager.shared.update(parameters as [String : Any]) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kTaskSuccess")
                for userId in removed {
                    if let user = User.find("id == %@", args: userId) as? User {
                        TaskManager.shared.delete(user: user, from: self.task!)
                    }
                }
                self.task?.save()
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.TaskDidChange.rawValue), object: nil)
                self.navigationController!.popViewController(animated: true)
            case .error(let error):
                Spinner.showWhistle("kTaskError", success: false)
                print(error)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBAction func cancel(_ sender: Any) {
        let isPresentingInAddEventMode = presentingViewController is UITabBarController
        
        if isPresentingInAddEventMode {
            dismiss(animated: true, completion: nil)
        } else {
            let changedValues = task!.changedValues()
            for (key, _) in changedValues {
                let oldValues = task?.committedValues(forKeys: [key])
                project!.setValue(oldValues?[key], forKey: key)
            }
            navigationController!.popViewController(animated: true)
        }
    }
    
    @IBAction func done(_ sender: Any) {
        let isPresentingInAddEventMode = presentingViewController is UITabBarController
        
        if isPresentingInAddEventMode {
            create()
        } else {
            update()
        }
    }
}
