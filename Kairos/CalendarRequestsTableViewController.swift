//
//  CalendarRequestsTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 22/11/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class CalendarRequestsTableViewController: UITableViewController {
    
    fileprivate let cellID = "cellHeaderCalendar"
    
    var requestedCalendars = [Calendar]()
    var refusedCalendars = [Calendar]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: Notifications.CalendarStatusChange.rawValue), object: nil)
        self.requestedCalendars = CalendarManager.shared.calendars(withStatus: .Invited)
        self.refusedCalendars = CalendarManager.shared.calendars(withStatus: .Refused)
        
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///  Reload data notification handler
    ///
    ///  - parameter notification: The notification
    @objc func reloadData(_ notification: Notification) {
        self.requestedCalendars = CalendarManager.shared.calendars(withStatus: .Invited)
        self.refusedCalendars = CalendarManager.shared.calendars(withStatus: .Refused)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func configureView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 86
        tableView.register(UINib(nibName: "CalendarHeaderCell", bundle: Bundle.main), forCellReuseIdentifier: cellID)
        tableView.allowsSelection = false
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return requestedCalendars.count
        }
        return refusedCalendars.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! CalendarHeaderCell
        
        // Configure the cell...
        var calendar: Calendar
        
        if indexPath.section == 0 {
            calendar = requestedCalendars[indexPath.row]
            cell.acceptButton.isEnabled = true
            cell.declineButton.isEnabled = true
        } else {
            calendar = refusedCalendars[indexPath.row]
            cell.declineButton.isEnabled = false
            cell.acceptButton.isEnabled = true
        }
        let participants = CalendarManager.shared.allUsers(forCalendar: calendar)
        cell.eventLabel.text = "No events"
        cell.titleLabel.text = calendar.name
        cell.participantLabel.text = String(participants.count) + " participants"
        cell.tag = calendar.id!.intValue
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return requestedCalendars.isEmpty ? 0 : 30
        }
        return refusedCalendars.isEmpty ? 0 : 30
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        headerView.backgroundColor = .background()
        let label = UILabel(frame: CGRect(x: 5, y: 0, width: tableView.bounds.size.width, height: 30))
        label.font = .boldSystemFont(ofSize: 17)
        headerView.addSubview(label)
        if section == 0 {
            label.text = "REQUESTED"
            return requestedCalendars.isEmpty ? nil : headerView
        }
        label.text = "REFUSED"
        return refusedCalendars.isEmpty ? nil : headerView
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
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CalendarRequestsTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Notification")
    }
}
