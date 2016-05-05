//
//  EventTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 02/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

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
        if let event = event {
            eventTitleCell.configure(event)
            eventLocationCell.configure(event)
            eventStartDateCell.configure(event)
            eventEndDateCell.configure(event)
            eventCalendarCell.configure(event)
            eventNotesCell.configure(event)
        } else {
            event = Event.create() as? Event
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        _ = tableView.cellForRowAtIndexPath(indexPath)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
}
