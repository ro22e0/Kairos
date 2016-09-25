//
//  EventTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 02/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import DatePickerCell
import FSCalendar

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
    @IBOutlet weak var eventInviteesCell: UITableViewCell!
    @IBOutlet weak var eventNotesCell: EventNotesTableViewCell!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
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
        
        if let event = event {
            self.saveButton.title = "Update"
            eventTitleCell.configure(event)
            eventLocationCell.configure(event)
            eventCalendarCell.configure(event)
            eventStartDateCell.configure(event)
            eventEndDateCell.configure(event)
            eventNotesCell.configure(event)
        } else {
            self.saveButton.title = "Save"
            event = Event.create() as? Event
            event?.dateStart = NSDate()
            event?.dateEnd = NSDate()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName(kEventWillSaveNotification, object: nil, userInfo:["event": event!])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.tableView.superview!.endEditing(true)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 1 {
//            return 2
//        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                eventTitleCell.configure(event!)
                return eventTitleCell
            }
            eventLocationCell.configure(event!)
            return eventLocationCell
        case 1:
            if indexPath.row == 0 {
                eventStartDateCell.configure(event!)
                return eventStartDateCell
            }
            eventEndDateCell.configure(event!)
            return eventEndDateCell
        case 2:
            if indexPath.row == 0 {
                eventCalendarCell.configure(event!)
                return eventCalendarCell
            }
            return eventInviteesCell
                   case 3:
            eventNotesCell.configure(event!)
            return eventNotesCell
        default:
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
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
        NSNotificationCenter.defaultCenter().postNotificationName(kEventWillSaveNotification, object: nil, userInfo:["event": event!])
        
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
    
    private func createEvent() {

        let parameters: [String: AnyObject] = [
            "calendar_id": self.event!.calendar!.id!,
            "title": self.event!.title!,
            "description": self.event!.notes!,
            "location": self.event!.location!,
            "date_start": FSCalendar().stringFromDate(self.event!.dateStart!, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            "date_end": FSCalendar().stringFromDate(self.event!.dateEnd!, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            "users": [[:]]]
        
        print(self.event!.dateStart!)
        print(self.event!.dateEnd!)
        RouterWrapper.sharedInstance.request(.CreateEvent(parameters)) { (response) in
            print(response.response)
            print(response.request)
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    SpinnerManager.showWhistle("kEventCreated", success: true)
                    OwnerManager.sharedInstance.setCredentials(response.response!)
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
        
    }
    
    private func updateEvent() {
        let parameters: [String: AnyObject] = [
            "id": self.event!.id!,
            "calendar_id": self.event!.calendar!.id!,
            "title": self.event!.title!,
            "description": self.event!.notes!,
            "location": self.event!.location!,
            "date_start": FSCalendar().stringFromDate(self.event!.dateStart!, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            "date_end": FSCalendar().stringFromDate(self.event!.dateEnd!, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            "users": [[:]]]

        print(self.event!.dateStart!)
        print(self.event!.dateEnd!)
        RouterWrapper.sharedInstance.request(.CreateEvent(parameters)) { (response) in
            print(response.response)
            print(response.request)
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    SpinnerManager.showWhistle("kEventCreated", success: true)
                    OwnerManager.sharedInstance.setCredentials(response.response!)
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
        
    }
    
    private func checkEventDetails() -> Bool {
        var success = event?.title != nil
        success = success && event?.location != nil
        success = success && event?.dateStart != nil
        success = success && event?.dateEnd != nil
        if event?.dateStart != nil && event?.dateEnd != nil {
            success = success && (event!.dateStart!.compare(event!.dateEnd!) == .OrderedAscending || event!.dateStart!.compare(event!.dateEnd!) == .OrderedSame)
        }
        success = success && event?.notes != nil
        
        return success
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddEventMode = self.parentViewController is UINavigationController

        if isPresentingInAddEventMode {
            event?.delete()
            dismissViewControllerAnimated(true, completion: nil)
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
        
        let isPresentingInAddEventMode = presentingViewController is UINavigationController
        
        if isPresentingInAddEventMode {
//            if checkEventDetails() {
//                createEvent()
//            }
            dismissViewControllerAnimated(true, completion: nil)
        } else {
//            if checkEventDetails() {
//                updateEvent()
//            }
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func unwindToEvent(sender: UIStoryboardSegue) {
        self.tableView.reloadData()
    }
}