//
//  CalendarRequestsTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 22/11/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class CalendarRequestsTableViewController: UITableViewController {
    
    private let cellID = "cellHeaderCalendar"
    
    var requestedCalendars = [UserCalendar]()
    var refusedCalendar = [UserCalendar]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.reloadData(_:)), name: Notifications.CalendarDidChange.rawValue, object: nil)
        self.requestedCalendars = CalendarManager.sharedInstance.calendars(withStatus: .Invited)
        self.refusedCalendar = CalendarManager.sharedInstance.calendars(withStatus: .Refused)

        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///  Reload data notification handler
    ///
    ///  - parameter notification: The notification
    @objc func reloadData(notification: NSNotification) {
        self.requestedCalendars = CalendarManager.sharedInstance.calendars(withStatus: .Invited)
        self.refusedCalendar = CalendarManager.sharedInstance.calendars(withStatus: .Refused)
        
        dispatch_async(dispatch_get_main_queue()) { 
            self.tableView.reloadData()
        }
    }
    
    func configureView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 86
        tableView.registerNib(UINib(nibName: "CalendarHeaderCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellID)
        tableView.allowsSelection = false
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return requestedCalendars.count
        }
        return refusedCalendar.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! CalendarHeaderCell
        
        // Configure the cell...
        var calendar: UserCalendar
        
        if indexPath.section == 0 {
            calendar = requestedCalendars[indexPath.row]
            cell.acceptButton.enabled = true
            cell.declineButton.enabled = true
        } else {
            calendar = refusedCalendar[indexPath.row]
            cell.declineButton.enabled = false
            cell.acceptButton.enabled = true
        }
        let participants = CalendarManager.sharedInstance.users(forCalendar: calendar.calendar!)
        cell.eventLabel.text = "No events"
        cell.titleLabel.text = calendar.calendar?.name
        cell.participantLabel.text = String(participants.count) + " participants"
        cell.tag = calendar.calendar!.id!.integerValue
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "REQUESTED"
        }
        return "REFUSED"
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
    
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
