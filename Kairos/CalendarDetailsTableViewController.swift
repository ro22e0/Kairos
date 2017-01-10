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
    var calendar: UserCalendar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: Notifications.CalendarDidChange.rawValue), object: nil)
        configure()
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
        if calendar?.calendar != nil {
            if let calendar = self.calendar, calendar.status != UserStatus.Refused.rawValue {
                former.removeAllUpdate()
                configure()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func configure() {
        if calendar!.isOwner == true && calendar!.user! == UserManager.shared.current {
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
        
        var rows = [RowFormer]()
        
        let participants = CalendarManager.shared.users(forCalendar: calendar!.calendar!)
        let calendarHeader = LabelRowFormer<CalendarHeaderCell>(instantiateType: .Nib(nibName: "CalendarHeaderCell")) {
            $0.acceptButton.isEnabled = false
            $0.eventLabel.text = "No events"
            $0.participantLabel.text = String(participants.count) + " participants"
            if let color = self.calendar?.calendar?.color {
                $0.colorImageView.backgroundColor = DynamicColor(hexString: CalendarManager.shared.colors[color]!)
                $0.colorImageView.round()
            }
            }.configure {
                $0.cell.tag = calendar!.calendar!.id!.intValue
                $0.text = calendar?.calendar?.name
                $0.rowHeight = 86
        }
        
        for user in participants {
            let participant = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                switch user.status! {
                case UserStatus.Invited.rawValue:
                    $0.statusColorView.backgroundColor = .orange
                case UserStatus.Participating.rawValue:
                    $0.statusColorView.backgroundColor = UIColor.green
                case UserStatus.Refused.rawValue:
                    $0.statusColorView.backgroundColor = .red
                case UserStatus.Owner.rawValue:
                    $0.statusColorView.backgroundColor = .cyan
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
        
        former.append(sectionFormer: sectionHeader, sectionParticipants)
    }
    
    fileprivate func invite(_ user: User, done: @escaping ()->Void) -> Void {
        let parameters = ["id": calendar!.calendar!.id!, "user_id": user.id!]
        
        CalendarManager.shared.invite(parameters) { (status) in
            switch status {
            case .success:
                SpinnerManager.showWhistle("kCalendarSuccess")
                done()
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.CalendarDidChange.rawValue), object: nil)
            case .error(let error):
                SpinnerManager.showWhistle("kCalendarError", success: false)
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
            destVC.calendar = calendar?.calendar
        }
    }
}
