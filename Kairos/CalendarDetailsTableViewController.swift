//
//  CalendarDetailsTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 07/10/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class CalendarDetailsTableViewController: UITableViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    private lazy var former: Former = Former(tableView: self.tableView)
    var calendar: UserCalendar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        configure()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure() {
        if calendar!.isOwner == true && calendar!.user! == UserManager.sharedInstance.current {
            editButton.enabled = true
            editButton.tintColor = nil
        } else {
            editButton.enabled = false
            editButton.tintColor = .clearColor()
        }
        
        self.title = "Calendar Details"
        self.tableView.tableFooterView = UIView()
        
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        //        self.tableView.estimatedRowHeight = 44
        
        var rows = [RowFormer]()
        
        let participants = CalendarManager.sharedInstance.users(forCalendar: calendar!.calendar!)
        let calendarHeader = LabelRowFormer<CalendarHeaderCell>(instantiateType: .Nib(nibName: "CalendarHeaderCell")) {
            $0.eventLabel.text = "No events"
            $0.participantLabel.text = String(participants.count) + " participants"
            }.configure {
                $0.text = calendar?.calendar?.name
                $0.rowHeight = 86
        }
        
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
        
        let addPerson = LabelRowFormer<FormLabelCell>() {
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
    
    private func invite(user: User, done: ()->Void) -> Void {
        let parameters = ["id": calendar!.calendar!.id!, "user_id": user.id!]

        CalendarManager.sharedInstance.invite(parameters) { (status) in
            switch status {
            case .Success:
                SpinnerManager.showWhistle("kCalendarSuccess")
                done()
            case .Error(let error):
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showEditCalendar" {
            let destVC = segue.destinationViewController as! CalendarTableViewController
            destVC.calendar = calendar?.calendar
        }
    }
}
