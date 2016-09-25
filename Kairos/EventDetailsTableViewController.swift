//
//  EventDetailsTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 16/04/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class EventDetailsTableViewController: UITableViewController {
    
    // MARK: - Class Properties
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.estimatedRowHeight = 135
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("kEventInfosCell", forIndexPath: indexPath) as! EventInfosTableViewCell
            cell.titleLabel.text = event?.title
            cell.locationTextView.autoresizingMask = [.FlexibleTopMargin, .FlexibleBottomMargin]
            cell.locationTextView.text = event?.location
            fillDates(cell)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("kEventCalendarCell", forIndexPath: indexPath) as! EventCalendarTableViewCell
            cell.calendarLabel.text = event?.calendar?.name ?? ""
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("kEventDescriptionCell", forIndexPath: indexPath) as! EventDescriptionTableViewCell
            cell.descriptionLabel.text = event?.notes
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    private func fillDates(cell: EventInfosTableViewCell) {
        if event!.dateStart!.isEqualToDate(event!.dateEnd!) == true {
            print("fidsvsdfgkdflkgdfm")
        } else {
            print("nooooooooooooo")
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        dateFormatter.timeStyle = .ShortStyle

        
        cell.startDateLabel.text = dateFormatter.stringFromDate(event!.dateStart!)
        cell.endDateLabel.text = dateFormatter.stringFromDate(event!.dateEnd!)
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
    
    @IBAction func deleteEvent(sender: UIButton) {
        
        let parameters: [String: AnyObject] = ["id": self.event!.id!]
        
        RouterWrapper.sharedInstance.request(.DeleteEvent(parameters)) { (response) in
            print(response.response)
            print(response.request)
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    SpinnerManager.showWhistle("kEventDeleted", success: true)
                    OwnerManager.sharedInstance.setCredentials(response.response!)
                    self.event?.delete()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    break;
                default:
                    SpinnerManager.showWhistle("kFail", success: false)
                    break;
                }
            case .Failure(let error):
                SpinnerManager.showWhistle("kFail", success: false)
                print(error.localizedDescription)
            }
        }
        event?.delete()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowEditEventSegue" {
            let destVC = segue.destinationViewController as! EventTableViewController
            destVC.event = event
        }
    }
    
    @IBAction func unwindToEventDetails(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? EventTableViewController, event = sourceViewController.event {
            self.event = event
        }
    }
}
