//
//  EventTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 02/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import FSCalendar
import Former

private enum eventCell {
    case Title
    case Location
    case StartDate
    case EndDate
    case Calendar
    case Description
}

class EventTableViewController: FormViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var rows = [RowFormer]()
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //        eventStartDateCell = EventStartDateTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        //        eventEndDateCell = EventEndDateTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        
        self.configure()
        
        if let event = event {
            self.saveButton.title = "Update"
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

    private func configure() {
        title = "Add Event"
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.contentOffset.y = -10
        
        // Create RowFomers
        
        let titleRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
            }.configure {
                $0.placeholder = "Event title"
        }
        rows.append(titleRow)
        
        let locationRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
            }.configure {
                $0.placeholder = "Location"
        }
        rows.append(locationRow)
        
        let allDayRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "All-day"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.switchButton.onTintColor = .formerSubColor()
        }
        rows.append(allDayRow)
        
        let startRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Start date"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFontOfSize(15)
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .DateAndTime
            }.displayTextFromDate(String.mediumDateShortTime)
        rows.append(startRow)

        let endRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "End date"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFontOfSize(15)
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .DateAndTime
            }.displayTextFromDate(String.mediumDateShortTime)
        rows.append(endRow)
        
        let urlRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .systemFontOfSize(15)
            }.configure {
                $0.placeholder = "URL"
        }
        rows.append(urlRow)
        
        let calendarRow = LabelRowFormer<FormLabelCell>() {
            $0.formTextLabel()?.textColor = .formerColor()
            $0.formTextLabel()?.font = .boldSystemFontOfSize(15)
            $0.formSubTextLabel()?.textColor = .formerSubColor()
            $0.formSubTextLabel()?.font = .systemFontOfSize(15)
            }.configure {
                $0.text = "Calendar"
                $0.cell.accessoryType = .DisclosureIndicator
                $0.subText = "None"
            }.onSelected { _ in
                self.performSegueWithIdentifier("showEventCalendar", sender: self)
        }
        rows.append(calendarRow)
        
        let inviteesRow = LabelRowFormer<FormLabelCell>() {
            $0.formTextLabel()?.textColor = .formerColor()
            $0.formTextLabel()?.font = .boldSystemFontOfSize(15)
            $0.formSubTextLabel()?.textColor = .formerSubColor()
            $0.formSubTextLabel()?.font = .systemFontOfSize(15)
            }.configure {
                $0.text = "Invitees"
                $0.cell.accessoryType = .DisclosureIndicator
                $0.subText = "None"
            }.onSelected { _ in
                self.performSegueWithIdentifier("showEventInvitees", sender: self)
        }
        rows.append(inviteesRow)
        
        let noteRow = TextViewRowFormer<FormTextViewCell>() {
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFontOfSize(15)
            }.configure {
                $0.placeholder = "Note"
                $0.rowHeight = 150
        }
        rows.append(noteRow)
        
        endRow.onDateChanged { date in
            if startRow.date.compare(date) == .OrderedDescending {
                startRow.update {
                    $0.date = date
                }
            } else {
            }
        }
        startRow.onDateChanged { date in
            if endRow.date.compare(date) == .OrderedAscending {
                endRow.update {
                    $0.date = date
                }
            } else {
                
            }
        }
        allDayRow.onSwitchChanged { on in
            startRow.update {
                $0.displayTextFromDate(
                    on ? String.mediumDateNoTime : String.mediumDateShortTime
                )
            }
            startRow.inlineCellUpdate {
                $0.datePicker.datePickerMode = on ? .Date : .DateAndTime
            }
            endRow.update {
                $0.displayTextFromDate(
                    on ? String.mediumDateNoTime : String.mediumDateShortTime
                )
            }
            endRow.inlineCellUpdate {
                $0.datePicker.datePickerMode = on ? .Date : .DateAndTime
            }
        }
        
        // Create Headers
        
        let createHeader: (() -> ViewFormer) = {
            return CustomViewFormer<FormHeaderFooterView>()
                .configure {
                    $0.viewHeight = 20
            }
        }
        
        // Create SectionFormers
        
        let titleSection = SectionFormer(rowFormer: titleRow, locationRow)
            .set(headerViewFormer: createHeader())
        let dateSection = SectionFormer(rowFormer: allDayRow, startRow, endRow)
            .set(headerViewFormer: createHeader())
        let inviteSection = SectionFormer(rowFormer: calendarRow, inviteesRow)
            .set(headerViewFormer: createHeader())
        let noteSection = SectionFormer(rowFormer: urlRow, noteRow)
            .set(headerViewFormer: createHeader())
        
        former.append(sectionFormer: titleSection, dateSection, inviteSection, noteSection)
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
                    UserManager.sharedInstance.setCredentials(response.response!)
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
                    UserManager.sharedInstance.setCredentials(response.response!)
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