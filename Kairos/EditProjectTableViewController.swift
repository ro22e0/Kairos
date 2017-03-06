//
//  EditProjectTableViewController.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former
import DynamicColor

class EditProjectTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    var project: Project?

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
        
        if self.project == nil {
            self.navigationItem.title = "New Project"
            self.project = Project.temporary()
        } else {
            self.navigationItem.title = "Edit Project"
            deleteRow = LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.textAlignment = .center
                $0.titleLabel.textColor = .red
                }
                .configure { row in
                    row.text = "Delete project"
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
                $0.placeholder = "Project Name"
                $0.text = project?.title
            }.onTextChanged { (text) in
                self.project?.title = text
        }

        let noteRow = TextViewRowFormer<FormTextViewCell>() {
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            $0.selectionStyle = .none
            }.configure {
                $0.placeholder = "Description"
                $0.text = project?.notes
                $0.rowHeight = 80
            }.onTextChanged { (text) in
                self.project?.notes = text
        }
        
        let startRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Start date"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFont(ofSize: 15)
            $0.selectionStyle = .none
            }.configure {
                if let date = project?.dateStart {
                    $0.date = date as Date
                } else {
                    self.project?.dateStart = $0.date as NSDate?
                }
            }.inlineCellSetup {
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
                if let date = project?.dateEnd {
                    $0.date = date as Date
                } else {
                    self.project?.dateEnd = $0.date as NSDate?
                }
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .date
            }.displayTextFromDate(String.mediumDateNoTime)
        
        endRow.onDateChanged { date in
            if startRow.date.compare(date) == .orderedDescending {
                startRow.update {
                    $0.date = date
                }
            }
            self.project?.dateEnd = date as NSDate?
        }
        
        startRow.onDateChanged { date in
            if endRow.date.compare(date) == .orderedAscending {
                endRow.update {
                    $0.date = date
                }
            }
            self.project?.dateStart = date as NSDate?
        }
        
        let pm = ProjectManager.shared
        set(members: pm.users(withStatus: .Owner, forProject: project!), status: .Owner)
        set(members: pm.users(withStatus: .Participating, forProject: project!), status: .Participating)
        set(members: pm.users(withStatus: .Invited, forProject: project!), status: .Invited)
        set(members: pm.users(withStatus: .Refused, forProject: project!), status: .Refused)
        
        addPerson = LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .orange
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            }.configure {
                $0.text = "Add teammate..."
                $0.cell.accessoryType = .disclosureIndicator
                $0.cell.selectionStyle = .none
                $0.rowHeight = 44
            }.onSelected { [weak self] _ in
                let storyboard = UIStoryboard(name: FriendsStoryboardID, bundle: nil)
                let destVC = storyboard.instantiateViewController(withIdentifier: "FriendsInviteTableViewController") as! FriendsInviteTableViewController
                destVC.friends = FriendManager.shared.friends()
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
        sectionMembers = SectionFormer(rowFormers: rows).set(headerViewFormer: createHeader("TEAMMATES"))
        former.append(sectionFormer: sectionHeader, sectionDates, sectionMembers)
        
        if let delRow = deleteRow {
            sectionDelete = SectionFormer(rowFormer: delRow).set(headerViewFormer: createHeader(""))
            former.append(sectionFormer: sectionDelete)
        }
    }
    
    func set(members: [User], status: UserStatus) {
        for user in members {
            addedUsers[user] = status
            let member = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                switch status {
                case .Invited:
                    $0.statusColorView.backgroundColor = .orange
                case .Participating:
                    $0.statusColorView.backgroundColor = UIColor.green
                case .Refused:
                    $0.statusColorView.backgroundColor = .red
                case .Owner:
                    $0.statusColorView.backgroundColor = .cyan
                default: break
                }
                $0.statusColorView.round()
                }.configure {
                    $0.text = user.name
                    $0.subText = status.rawValue
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
        for (user, status) in addedUsers {
            let member = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                switch status {
                case .Invited:
                    $0.statusColorView.backgroundColor = .orange
                case .Participating:
                    $0.statusColorView.backgroundColor = UIColor.green
                case .Refused:
                    $0.statusColorView.backgroundColor = .red
                case .Owner:
                    $0.statusColorView.backgroundColor = .cyan
                default: break
                }
                $0.statusColorView.round()
                }.configure {
                    $0.text = user.name
                    $0.subText = status.rawValue
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
            addedUsers[user] = .Invited
            //            if !ProjectManager.shared.userIsIn(project!, user: user) {
            let member = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                $0.statusColorView.backgroundColor = .orange
                $0.statusColorView.round()
                }.configure {
                    $0.text = user.name
                    $0.subText = "invited"
                    $0.rowHeight = 45
                }.onSelected{ [weak self] cell in
                    self!.selectedUser(user, cell: cell)
            }
            Spinner.showWhistle("kProjectSuccess")
            done("Invited")
            former.insertUpdate(rowFormer: member, above: addPerson, rowAnimation: .automatic)
            former.reload(sectionFormer: sectionMembers)
            // }
        } else {
            Spinner.showWhistle("kProjectAlreadyAdded", success: false)
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
        let destVC = storyboard.instantiateViewController(withIdentifier: "UserProjectActionTableViewController") as! UserProjectActionTableViewController
        destVC.user = user
        destVC.project = self.project
        destVC.remove = { user in
            //            if self.addedUsers[user] == UserStatus.Invited {
            //                if let user = User.find("id == %@", args: user) as? User {
            //                    ProjectManager.shared.delete(user: user, fromProject: self.project!)
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
                self.former.reload(sectionFormer: self.sectionMembers)
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
        let parameters = ["id": project!.id!]
        
        ProjectManager.shared.delete(parameters) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kProjectSuccess")
//                print(DataSync.dataStack().viewContext)
//                print(DataSync.dataStack().mainContext)
                self.project?.delete()
                self.project?.save()
                print(self.project?.title)
                print(self.project?.owners?.count)
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.ProjectDidChange.rawValue), object: nil)
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
                Spinner.showWhistle("kProjectError", success: false)
                print(error)
            }
        }
    }
    
    fileprivate func create() {
        var parameters = project!.dictionaryWithValues(forKeys: ["title"])
        parameters["description"] = project!.notes
        parameters["date_start"] = String.formatDateApi(project!.dateStart! as Date)
        parameters["date_end"] = String.formatDateApi(project!.dateEnd! as Date)
        var invited = [Int]()
        var removed = [Int]()
        var owners = [Int]()
        
        addedUsers.forEach { (user, status) in
            switch status {
            case .Invited:
                invited.append(user.id!.intValue)
            case .Removed:
                removed.append(user.id!.intValue)
            case .Owner:
                owners.append(user.id!.intValue)
            default:
                break
            }
        }
        parameters["invited"] = invited
        parameters["removed"] = removed
        parameters["owners"] = owners
        
        ProjectManager.shared.create(parameters as [String : Any]) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kProjectSuccess")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.ProjectDidChange.rawValue), object: nil)
                self.dismiss(animated: true, completion: nil)
            case .error(let error):
                Spinner.showWhistle("kProjectError", success: false)
                print(error)
            }
        }
    }
    
    fileprivate func update() {
        var parameters = project!.dictionaryWithValues(forKeys: ["id", "title"])
        parameters["description"] = project!.notes
        parameters["date_start"] = String.formatDateApi(project!.dateStart! as Date)
        parameters["date_end"] = String.formatDateApi(project!.dateEnd! as Date)
        var invited = [Int]()
        var removed = [Int]()
        var owners = [Int]()
        
        addedUsers.forEach { (user, status) in
            switch status {
            case .Invited:
                invited.append(user.id!.intValue)
            case .Removed:
                removed.append(user.id!.intValue)
            case .Owner:
                owners.append(user.id!.intValue)
            default:
                break
            }
        }
        parameters["invited"] = invited
        parameters["removed"] = removed
        parameters["owners"] = owners
        
        ProjectManager.shared.update(parameters as [String : Any]) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kProjectSuccess")
                for userId in removed {
                    if let user = User.find("id == %@", args: userId) as? User {
                        ProjectManager.shared.delete(user: user, fromProject: self.project!)
                    }
                }
                self.project?.save()
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.ProjectDidChange.rawValue), object: nil)
                self.navigationController!.popViewController(animated: true)
            case .error(let error):
                Spinner.showWhistle("kProjectError", success: false)
                print(error)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        let isPresentingInAddEventMode = presentingViewController is UITabBarController
        
        if isPresentingInAddEventMode {
            create()
        } else {
            update()
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        let isPresentingInAddEventMode = presentingViewController is UITabBarController
        
        if isPresentingInAddEventMode {
            dismiss(animated: true, completion: nil)
        } else {
            let changedValues = project!.changedValues()
            for (key, _) in changedValues {
                let oldValues = project?.committedValues(forKeys: [key])
                project!.setValue(oldValues?[key], forKey: key)
            }
            navigationController!.popViewController(animated: true)
        }
    }
}
