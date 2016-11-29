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
    
    private var sectionParticipants: SectionFormer!
    private var rows = [RowFormer]()
    private var addPerson: RowFormer!
    private var deleteRow: RowFormer?
    
    private var addedUsers = [User: UserStatus]()
    
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
                $0.titleLabel.textAlignment = .Center
                $0.titleLabel.textColor = .redColor()
                }
                .configure { row in
                    row.text = "Delete calendar"
                }.onSelected { row in
                    self.delete()
            }
        }
        self.configure()
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
            $0.textField.font = .systemFontOfSize(15)
            }.configure {
                $0.placeholder = "Name"
                $0.text = calendar?.name
            }.onTextChanged { (text) in
                self.calendar?.name = text
        }
        setParticipants()
        
        addPerson = LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .orangeColor()
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            }.configure {
                $0.text = "Add participant..."
                $0.cell.accessoryType = .DisclosureIndicator
                $0.cell.selectionStyle = .None
                $0.rowHeight = 44
            }.onSelected { [weak self] _ in
                let storyboard = UIStoryboard(name: FriendsStoryboardID, bundle: nil)
                let destVC = storyboard.instantiateViewControllerWithIdentifier("FriendsInviteTableViewController") as! FriendsInviteTableViewController
                destVC.onSelected = { user, done in
                    self?.invite(user, done: done)
                }
                let nvc = UINavigationController(rootViewController: destVC)
                self?.presentViewController(nvc, animated: true, completion: nil)
        }
        rows.append(addPerson)
        
        let colorRow = LabelRowFormer<LabelColorCell>(instantiateType: .Nib(nibName: "LabelColorCell")){
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.colorImageView.round()
            if let color = self.calendar?.color {
                $0.colorImageView.backgroundColor = DynamicColor(hexString: CalendarManager.sharedInstance.colors[color]!)
            }
            }.configure {
                $0.text = "Change color"
                $0.cell.accessoryType = .DisclosureIndicator
                $0.cell.selectionStyle = .None
                $0.rowHeight = 44
            }.onSelected { [weak self] cell in
                let storyboard = UIStoryboard(name: CalendarStoryboardID, bundle: nil)
                let destVC = storyboard.instantiateViewControllerWithIdentifier("ColorSelectionViewController") as! ColorSelectionViewController
                destVC.onSelected = { color in
                    self?.calendar?.color = color
                    cell.update() {
                        $0.cell.colorImageView.backgroundColor = DynamicColor(hexString: CalendarManager.sharedInstance.colors[color]!)
                    }
                }
                destVC.modalPresentationStyle = .OverCurrentContext
                destVC.preferredContentSize = CGSizeMake(self!.view.frame.width, 43)
                let popoverPC = destVC.popoverPresentationController
                
                popoverPC?.permittedArrowDirections = .Up
                popoverPC?.delegate = self
                popoverPC?.sourceView = cell.cell
                popoverPC?.sourceRect = CGRect(x: cell.cell.frame.width / 2, y: cell.cell.frame.height, width: 1, height: 1)
                self!.presentViewController(destVC, animated: true, completion: nil)
        }
        // Create Headers
        
        let createHeader: (String -> ViewFormer) = { text in
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
    
    private func setParticipants() {
        let users = CalendarManager.sharedInstance.users(forCalendar: calendar!)
        for user in users {
            let participant = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                switch user.status! {
                case UserStatus.Invited.rawValue:
                    $0.statusColorView.backgroundColor = .orangeColor()
                case UserStatus.Participating.rawValue:
                    $0.statusColorView.backgroundColor = UIColor.greenColor()
                case UserStatus.Refused.rawValue:
                    $0.statusColorView.backgroundColor = .redColor()
                case UserStatus.Owner.rawValue:
                    $0.statusColorView.backgroundColor = .cyanColor()
                default: break
                }
                $0.statusColorView.round()
                }.configure {
                    $0.text = user.user?.name
                    $0.subText = user.status
                    $0.rowHeight = 60
                }.onSelected{ [weak self] cell in
                    self!.selectedUser(user.user!, cell: cell)
            }
            rows.append(participant)
        }
    }
    
    private func invite(user: User, done: ()->Void) -> Void {
        let isIn = addedUsers.contains { (u, _) -> Bool in
            return user == u
        }
        if !isIn {
            addedUsers[user] = .Invited
            if !CalendarManager.sharedInstance.userIsIn(calendar!, user: user) {
                let participant = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                    $0.statusColorView.backgroundColor = .orangeColor()
                    $0.statusColorView.round()
                    }.configure {
                        $0.text = user.name
                        $0.subText = "invited"
                        $0.rowHeight = 60
                    }.onSelected{ [weak self] cell in
                        self!.selectedUser(user, cell: cell)
                }
                SpinnerManager.showWhistle("kCalendarSuccess")
                done()
                former.insertUpdate(rowFormer: participant, above: addPerson, rowAnimation: .Automatic)
                former.reload(sectionFormer: sectionParticipants)
            }
        } else {
            SpinnerManager.showWhistle("kCalendarError", success: false)
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
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Navigation
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    private func selectedUser(user: User, cell: LabelRowFormer<CollaboratorTableViewCell>) {
        let storyboard = UIStoryboard(name: CalendarStoryboardID, bundle: nil)
        let destVC = storyboard.instantiateViewControllerWithIdentifier("UserCalendarActionTableViewController") as! UserCalendarActionTableViewController
        destVC.user = user
        destVC.calendar = self.calendar
        destVC.remove = { user in
            if self.addedUsers[user] == UserStatus.Invited {
                self.addedUsers.removeValueForKey(user)
            } else {
                self.addedUsers[user] = UserStatus.Removed
            }
            self.former.removeUpdate(rowFormer: cell)
        }
        destVC.modalPresentationStyle = .Popover
        destVC.preferredContentSize = CGSizeMake(self.view.frame.width, 43)
        let popoverPC = destVC.popoverPresentationController
        
        popoverPC?.permittedArrowDirections = .Up
        popoverPC?.delegate = self
        popoverPC?.sourceView = cell.cell
        popoverPC?.sourceRect = CGRect(x: cell.cell.frame.width / 2, y: cell.cell.frame.height, width: 1, height: 1)
        self.presentViewController(destVC, animated: true, completion: nil)
    }
    
    private func delete() {
        let parameters = ["id": calendar!.id!]
        
        CalendarManager.sharedInstance.delete(parameters) { (status) in
            switch status {
            case .Success:
                SpinnerManager.showWhistle("kCalendarSuccess")
                self.calendar?.delete()
                UserCalendar.count()
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CalendarDidChange.rawValue, object: nil)
                if self.presentingViewController is UITabBarController {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.navigationController!.popViewControllerAnimated(true)
                }
            case .Error(let error):
                SpinnerManager.showWhistle("kCalendarError", success: false)
                print(error)
            }
        }
    }
    
    private func create() {
        var parameters = calendar!.dictionaryWithValuesForKeys(["name"])
        var invited = [Int]()
        var removed = [Int]()
        var owners = [Int]()
        
        addedUsers.forEach { (user, status) in
            switch status {
            case .Invited:
                invited.append(user.id!.integerValue)
            case .Removed:
                removed.append(user.id!.integerValue)
            case .Owner:
                owners.append(user.id!.integerValue)
            default:
                break
            }
        }
        parameters["invited"] = invited
        parameters["removed"] = removed
        parameters["owners"] = owners
        parameters["color"] = calendar?.color
        
        CalendarManager.sharedInstance.create(parameters) { (status) in
            switch status {
            case .Success:
                SpinnerManager.showWhistle("kCalendarSuccess")
                self.calendar?.save()
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CalendarDidChange.rawValue, object: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
            case .Error(let error):
                SpinnerManager.showWhistle("kCalendarError", success: false)
                print(error)
            }
        }
    }
    
    private func update() {
        var parameters = calendar!.dictionaryWithValuesForKeys(["id", "name"])
        var invited = [Int]()
        var removed = [Int]()
        var owners = [Int]()
        
        addedUsers.forEach { (user, status) in
            switch status {
            case .Invited:
                invited.append(user.id!.integerValue)
            case .Removed:
                removed.append(user.id!.integerValue)
            case .Owner:
                owners.append(user.id!.integerValue)
            default:
                break
            }
        }
        parameters["invited"] = invited
        parameters["removed"] = removed
        parameters["owners"] = owners
        parameters["color"] = calendar?.color
        
        CalendarManager.sharedInstance.update(parameters) { (status) in
            switch status {
            case .Success:
                SpinnerManager.showWhistle("kCalendarSuccess")
                for userId in removed {
                    if let user = User.find("id == %@", args: userId) as? User {
                        CalendarManager.sharedInstance.deleteUser(user, forCalendar: self.calendar!)
                    }
                }
                self.calendar?.save()
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CalendarDidChange.rawValue, object: nil)
                self.navigationController!.popViewControllerAnimated(true)
            case .Error(let error):
                SpinnerManager.showWhistle("kCalendarError", success: false)
                print(error)
            }
        }
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        let isPresentingInAddEventMode = presentingViewController is UITabBarController
        
        if isPresentingInAddEventMode {
            create()
        } else {
            update()
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        let isPresentingInAddEventMode = presentingViewController is UITabBarController
        
        if isPresentingInAddEventMode {
            calendar!.delete()
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            let changedValues = calendar!.changedValuesForCurrentEvent()
            for (key, value) in changedValues {
                calendar!.setValue(value, forKey: key)
            }
            navigationController!.popViewControllerAnimated(true)
        }
    }
}
