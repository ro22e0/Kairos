//
//  EventTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 02/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import DatePickerCell

private enum eventCell {
    case Title
    case Location
    case StartDate
    case EndDate
    case Calendar
    case Description
}

class EventTableViewController: UITableViewController {
    
    @IBOutlet weak var eventTitleCell: EventTitleTableViewCell!
    @IBOutlet weak var eventLocationCell: EventLocationTableViewCell!
    @IBOutlet weak var eventStartDateCell: EventStartDateTableViewCell!
    @IBOutlet weak var eventEndDateCell: EventEndDateTableViewCell!
    @IBOutlet weak var eventCalendarCell: EventCalendarTableViewCell!
    @IBOutlet weak var eventNotesCell: EventNotesTableViewCell!
    
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //        eventStartDateCell = EventStartDateTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        //        eventEndDateCell = EventEndDateTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        
        print(eventStartDateCell)
        print(eventEndDateCell)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let event = event {
            eventTitleCell.configure(event)
            eventLocationCell.configure(event)
            eventCalendarCell.configure(event)
            eventStartDateCell.configure(event)
            eventEndDateCell.configure(event)
            eventNotesCell.configure(event)
        } else {
            event = Event.create() as? Event
            event?.startDate = NSDate()
            event?.endDate = NSDate()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 2
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.timeStyle = .MediumStyle
            dateFormatter.locale = NSLocale.currentLocale()
            
            if indexPath.row == 0 {
                eventStartDateCell.rightLabel.text = dateFormatter.stringFromDate(event!.startDate!)
                eventStartDateCell.leftLabel.text = "Start Date"
                return eventStartDateCell
            }
            eventEndDateCell.leftLabel.text = "End Date"
            eventEndDateCell.rightLabel.text = dateFormatter.stringFromDate(event!.endDate!)
            return eventEndDateCell
        }
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if let eventStartDateCell = cell as? EventStartDateTableViewCell {
                return eventStartDateCell.datePickerHeight()
            }
            if let eventEndDateCell = cell as? EventEndDateTableViewCell {
                return eventEndDateCell.datePickerHeight()
            }
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if let eventStartDateCell = cell as? EventStartDateTableViewCell {
                print("yoloyoloyoloyolo")
                eventStartDateCell.selectedInTableView(tableView)
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            if let eventEndDateCell = cell as? EventEndDateTableViewCell {
                eventEndDateCell.selectedInTableView(tableView)
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            if cell is EventCalendarTableViewCell {
                self.performSegueWithIdentifier("showEventCalendarVC", sender: self)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showEventCalendarVC" {
            let destVC = segue.destinationViewController as! EventCalendarTableViewController
            destVC.event = event
        }
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddEventMode = presentingViewController is UINavigationController
        
        if isPresentingInAddEventMode {
            dismissViewControllerAnimated(true, completion: nil)
            event?.delete()
        } else {
            let changedValues = event!.changedValuesForCurrentEvent()
            for (key, value) in changedValues {
                event!.setValue(value, forKey: key)
            }
            navigationController!.popViewControllerAnimated(true)
        }
    }

    @IBAction func saveEvent(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().postNotificationName(kEventWillSaveNotification, object: nil, userInfo:["event": event!])
        
        event?.save()
        print(event)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func unwindToEvent(sender: UIStoryboardSegue) {
        self.tableView.reloadData()
    }
}