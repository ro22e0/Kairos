//
//  CalendarDetailsTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 07/10/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former
import DynamicColor

class CalendarDetailsTableViewController: UITableViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    fileprivate lazy var former: Former = Former(tableView: self.tableView)
    var calendar: Calendar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: Notifications.CalendarDidChange.rawValue), object: nil)
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: Notifications.CalendarStatusChange.rawValue), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.CalendarStatusChange.rawValue), object: nil)
    }
    
    //        NSNotificationCenter.defaultCenter().removeObserver(self, name: Notifications.CalendarDidChange.rawValue, object: nil)
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///  Reload data notification handler
    ///
    ///  - parameter notification: The notification
    @objc func reloadData(_ notification: Notification) {
        self.calendar = Calendar.find("id = %@", args: self.calendar?.id) as? Calendar
        if let calendar = self.calendar, calendar.userStatus != UserStatus.Refused.rawValue {
            self.former.removeAll()
            self.configure()
            self.former.reload()
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.CalendarDidChange.rawValue), object: nil)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func configure() {
        if let calendar = self.calendar, calendar.userStatus == UserStatus.Owner.rawValue {
            editButton.isEnabled = true
            editButton.tintColor = nil
        } else {
            editButton.isEnabled = false
            editButton.tintColor = .clear
        }

        self.title = "Calendar Details"
        self.tableView.tableFooterView = UIView()
        
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        //        self.tableView.estimatedRowHeight = 44

        let cm = CalendarManager.shared
        var rows = [RowFormer]()
        
        let participants = cm.allUsers(forCalendar: calendar!)
        let calendarHeader = LabelRowFormer<CalendarHeaderCell>(instantiateType: .Nib(nibName: "CalendarHeaderCell")) {
            $0.acceptButton.isEnabled = false
            $0.eventLabel.text = "No events"
            $0.participantLabel.text = String(participants.count) + " participants"
            if let color = self.calendar?.color {
                $0.colorImageView.backgroundColor = DynamicColor(hexString: CalendarManager.shared.colors[color]!)
                $0.colorImageView.round()
            }
            }.configure {
                $0.cell.tag = calendar!.id!.intValue
                $0.text = calendar?.name
                $0.rowHeight = 86
        }
        
        set(participants: cm.users(withStatus: .Owner, forCalendar: calendar!), rows: &rows, status: .Owner)
        set(participants: cm.users(withStatus: .Participating, forCalendar: calendar!), rows: &rows, status: .Participating)
        set(participants: cm.users(withStatus: .Invited, forCalendar: calendar!), rows: &rows, status: .Invited)
        set(participants: cm.users(withStatus: .Refused, forCalendar: calendar!), rows: &rows, status: .Refused)
        
        let addPerson = LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = UIColor.orange
            }.configure {
                $0.text = "Add participant..."
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
        
        let createHeader: (ViewFormer) = {
            return CustomViewFormer<UITableViewHeaderFooterView>() {
                $0.backgroundView = UIView()
                }.configure {
                    $0.viewHeight = 10
            }
        }()
        
        let sectionHeader = SectionFormer(rowFormer: calendarHeader).set(headerViewFormer: nil)
        let sectionParticipants = SectionFormer(rowFormers: rows).set(headerViewFormer: createHeader)
        
        self.former.append(sectionFormer: sectionHeader, sectionParticipants)
    }
    
    func set(participants: [User], rows: inout [RowFormer], status: UserStatus) {
        for user in participants {
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
                    $0.rowHeight = 40
            }
            rows.append(participant)
        }
    }
    
    fileprivate func invite(_ user: User, done: @escaping (String)->Void) -> Void {
        let parameters = ["id": calendar!.id!, "user_id": user.id!]
        let addedUsers = CalendarManager.shared.allUsers(forCalendar: calendar!)
        
        if addedUsers.contains(user) {
            done("Already Added")
            Spinner.showWhistle("kCalendarAlreadyAdded")
            return
        }

        CalendarManager.shared.invite(parameters) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kCalendarSuccess")
                done("Invited")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.CalendarDidChange.rawValue), object: nil)
            case .error(let error):
                Spinner.showWhistle("kCalendarError", success: false)
                print(error)
            }
        }
    }
    
    /*
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showEditCalendar" {
            let destVC = segue.destination as! CalendarTableViewController
            destVC.calendar = calendar
        }
    }
}
