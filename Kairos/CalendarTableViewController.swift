//
//  CalendarTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 10/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former
import DynamicColor

class CalendarTableViewController: FormViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var calendar: Calendar?
    
    fileprivate var sectionParticipants: SectionFormer!
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
        
        if self.calendar == nil {
            self.saveButton.title = "Save"
            self.navigationItem.title = "New Calendar"
            self.calendar = Calendar.create() as? Calendar
        } else {
            self.saveButton.title = "Update"
            deleteRow = LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.textAlignment = .center
                $0.titleLabel.textColor = .red
                }
                .configure { row in
                    row.text = "Delete calendar"
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
        self.title = "Edit Calendar"
        self.tableView.tableFooterView = UIView()
        
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        //        self.tableView.estimatedRowHeight = 44
        
        let nameRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Name"
                $0.text = calendar?.name
            }.onTextChanged { (text) in
                self.calendar?.name = text
        }
        
        let cm = CalendarManager.shared
        
        set(participants: cm.users(withStatus: .Owner, forCalendar: calendar!), rows: &rows, status: .Owner)
        set(participants: cm.users(withStatus: .Participating, forCalendar: calendar!), rows: &rows, status: .Participating)
        set(participants: cm.users(withStatus: .Invited, forCalendar: calendar!), rows: &rows, status: .Invited)
        set(participants: cm.users(withStatus: .Refused, forCalendar: calendar!), rows: &rows, status: .Refused)
        
        addPerson = LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .orange
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            }.configure {
                $0.text = "Add participant..."
                $0.cell.accessoryType = .disclosureIndicator
                $0.cell.selectionStyle = .none
                $0.rowHeight = 44
            }.onSelected { [weak self] _ in
                let storyboard = UIStoryboard(name: FriendsStoryboardID, bundle: nil)
                let destVC = storyboard.instantiateViewController(withIdentifier: "FriendsInviteTableViewController") as! FriendsInviteTableViewController
                destVC.onSelected = { user, done in
                    self?.invite(user, done: done)
                }
                let nvc = UINavigationController(rootViewController: destVC)
                self?.present(nvc, animated: true, completion: nil)
        }
        rows.append(addPerson)
        
        let colorRow = LabelRowFormer<LabelColorCell>(instantiateType: .Nib(nibName: "LabelColorCell")){
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.colorImageView.round()
            if let color = self.calendar?.color {
                $0.colorImageView.backgroundColor = DynamicColor(hexString: CalendarManager.shared.colors[color]!)
            }
            }.configure {
                $0.text = "Change color"
                $0.cell.accessoryType = .disclosureIndicator
                $0.cell.selectionStyle = .none
                $0.rowHeight = 44
            }.onSelected { [weak self] cell in
                let storyboard = UIStoryboard(name: CalendarStoryboardID, bundle: nil)
                let destVC = storyboard.instantiateViewController(withIdentifier: "ColorSelectionViewController") as! ColorSelectionViewController
                destVC.onSelected = { color in
                    self?.calendar?.color = color
                    cell.update() {
                        $0.cell.colorImageView.backgroundColor = DynamicColor(hexString: CalendarManager.shared.colors[color]!)
                    }
                }
                destVC.modalPresentationStyle = .overCurrentContext
                destVC.preferredContentSize = CGSize(width: self!.view.frame.width, height: 43)
                let popoverPC = destVC.popoverPresentationController
                
                popoverPC?.permittedArrowDirections = .up
                popoverPC?.delegate = self
                popoverPC?.sourceView = cell.cell
                popoverPC?.sourceRect = CGRect(x: cell.cell.frame.width / 2, y: cell.cell.frame.height, width: 1, height: 1)
                self!.present(destVC, animated: true, completion: nil)
        }
        // Create Headers
        
        let createHeader: ((String) -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 40
                    $0.text = text
            }
        }
        
        // Create SectionFormers
        
        let sectionHeader = SectionFormer(rowFormer: nameRow).set(headerViewFormer: createHeader(""))
        let colorHeader = SectionFormer(rowFormer: colorRow).set(headerViewFormer: createHeader(""))
        sectionParticipants = SectionFormer(rowFormers: rows).set(headerViewFormer: createHeader("SHARED WITH:"))
        former.append(sectionFormer: sectionHeader, colorHeader, sectionParticipants)
        
        if let delRow = deleteRow {
            let deleteSection = SectionFormer(rowFormer: delRow).set(headerViewFormer: createHeader(""))
            former.append(sectionFormer: deleteSection)
        }
    }
    
    func set(participants: [User], rows: inout [RowFormer], status: UserStatus) {
        for user in participants {
            addedUsers[user] = status
            let participant = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
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
                }.onSelected{ [weak self] cell in
                    self!.selectedUser(user, cell: cell)
            }
            rows.append(participant)
        }
    }
    
    fileprivate func invite(_ user: User, done: (String)->Void) -> Void {
        let isIn = addedUsers.contains { (u, _) -> Bool in
            return user == u
        }
        
        if !isIn {
            addedUsers[user] = .Invited
            //            if !CalendarManager.shared.userIsIn(calendar!, user: user) {
            let participant = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                $0.statusColorView.backgroundColor = .orange
                $0.statusColorView.round()
                }.configure {
                    $0.text = user.name
                    $0.subText = "invited"
                    $0.rowHeight = 45
                }.onSelected{ [weak self] cell in
                    self!.selectedUser(user, cell: cell)
            }
            SpinnerManager.showWhistle("kCalendarSuccess")
            done("Invited")
            former.insertUpdate(rowFormer: participant, above: addPerson, rowAnimation: .automatic)
            former.reload(sectionFormer: sectionParticipants)
            // }
        } else {
            SpinnerManager.showWhistle("kCalendarAlreadyAdded", success: false)
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    fileprivate func selectedUser(_ user: User, cell: LabelRowFormer<CollaboratorTableViewCell>) {
        let storyboard = UIStoryboard(name: CalendarStoryboardID, bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "UserCalendarActionTableViewController") as! UserCalendarActionTableViewController
        destVC.user = user
        destVC.calendar = self.calendar
        destVC.remove = { user in
            //            if self.addedUsers[user] == UserStatus.Invited {
            //                if let user = User.find("id == %@", args: user) as? User {
            //                    CalendarManager.shared.delete(user: user, fromCalendar: self.calendar!)
            //                }
            //                self.addedUsers.removeValue(forKey: user)
            //            } else {
            self.addedUsers[user] = UserStatus.Removed
            //            }
            self.former.removeUpdate(rowFormer: cell)
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
        let parameters = ["id": calendar!.id!]
        
        CalendarManager.shared.delete(parameters) { (status) in
            switch status {
            case .success:
                SpinnerManager.showWhistle("kCalendarSuccess")
                self.calendar?.delete()
                Calendar.count()
                if self.presentingViewController is UITabBarController {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController!.popViewController(animated: true)
                }
            case .error(let error):
                SpinnerManager.showWhistle("kCalendarError", success: false)
                print(error)
            }
        }
    }
    
    fileprivate func create() {
        var parameters = calendar!.dictionaryWithValues(forKeys: ["name"])
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
        parameters["color"] = calendar?.color
        
        CalendarManager.shared.create(parameters as [String : Any]) { (status) in
            switch status {
            case .success:
                SpinnerManager.showWhistle("kCalendarSuccess")
                self.calendar?.save()
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.CalendarDidChange.rawValue), object: nil)
                self.dismiss(animated: true, completion: nil)
            case .error(let error):
                SpinnerManager.showWhistle("kCalendarError", success: false)
                print(error)
            }
        }
    }
    
    fileprivate func update() {
        var parameters = calendar!.dictionaryWithValues(forKeys: ["id", "name"])
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
        parameters["color"] = calendar?.color
        
        CalendarManager.shared.update(parameters as [String : Any]) { (status) in
            switch status {
            case .success:
                SpinnerManager.showWhistle("kCalendarSuccess")
                for userId in removed {
                    if let user = User.find("id == %@", args: userId) as? User {
                        CalendarManager.shared.delete(user: user, fromCalendar: self.calendar!)
                    }
                }
                self.calendar?.save()
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.CalendarDidChange.rawValue), object: nil)
                self.navigationController!.popViewController(animated: true)
            case .error(let error):
                SpinnerManager.showWhistle("kCalendarError", success: false)
                print(error)
            }
        }
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
            calendar!.delete()
            dismiss(animated: true, completion: nil)
        } else {
            let changedValues = calendar!.changedValuesForCurrentEvent()
            for (key, value) in changedValues {
                calendar!.setValue(value, forKey: key)
            }
            navigationController!.popViewController(animated: true)
        }
    }
}
