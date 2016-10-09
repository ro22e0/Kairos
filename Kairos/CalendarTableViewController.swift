//
//  CalendarTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 10/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class CalendarTableViewController: FormViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var calendar: Calendar?
    private var invitedUsers = [User]()
    private var sectionParticipants: SectionFormer!
    private var rows = [RowFormer]()
    private var addPerson: RowFormer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if self.calendar == nil {
            self.saveButton.title = "Save"
            //            self.calendar = Calendar.create() as? Calendar
        } else {
            self.saveButton.title = "Update"
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
            $0.titleLabel.textColor = UIColor.orangeColor()
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
        sectionParticipants = SectionFormer(rowFormers: rows).set(headerViewFormer: createHeader("SHARED WITH:"))
        
        former.append(sectionFormer: sectionHeader, sectionParticipants)
    }
    
    private func setParticipants() {
        let participants = CalendarManager.sharedInstance.users(forCalendar: calendar!)
        for user in participants {
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
            }
            rows.append(participant)
        }
    }
    
    private func invite(user: User, done: ()->Void) -> Void {
        if !invitedUsers.contains(user) {
            self.invitedUsers.append(user)
            
            if !CalendarManager.sharedInstance.userIsIn(calendar!, user: user) {
                let participant = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                    $0.statusColorView.backgroundColor = .orangeColor()
                    $0.statusColorView.round()
                    }.configure {
                        $0.text = user.name
                        $0.subText = "invited"
                        $0.rowHeight = 60
                }
                former.insertUpdate(rowFormer: participant, above: addPerson, rowAnimation: .Automatic)
                former.reload(sectionFormer: sectionParticipants)
            }
        }
        //        let parameters = ["id": calendar!.id!, "user_id": user.id!]
        //
        //        CalendarManager.sharedInstance.invite(parameters) { (status) in
        //            switch status {
        //            case .Success:
        //                SpinnerManager.showWhistle("kCalendarSuccess")
        //                if let uCalendar = UserCalendar.findOrCreate(["userId": user.id!, "calendarId": self.calendar!.id!]) as? UserCalendar {
        //                    uCalendar.status = UserStatus.Invited.rawValue
        //                    uCalendar.calendar = self.calendar!
        //                    uCalendar.user = user
        //                    uCalendar.isSelected = true
        //                }
        //                done()
        //            case .Error(let error):
        //                SpinnerManager.showWhistle("kCalendarError", success: false)
        //                print(error)
        //            }
        //        }
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
    
    private func create() {
        
    }
    
    private func update() {
        var parameters = calendar!.dictionaryWithValuesForKeys(["id", "name"])
        var invited = [Int]()
        var removed = [Int]()
        var owners = [Int]()
        
        self.invitedUsers.forEach { (user) in
            invited.append(user.id!.integerValue)
        }
        parameters["invited"] = invited
        
        CalendarManager.sharedInstance.update(parameters) { (status) in
            switch status {
            case .Success:
                SpinnerManager.showWhistle("kCalendarSuccess")
                self.calendar?.save()
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
            dismissViewControllerAnimated(true, completion: nil)
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
