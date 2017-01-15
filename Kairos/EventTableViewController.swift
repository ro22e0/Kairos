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
    case title
    case location
    case startDate
    case endDate
    case calendar
    case description
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
        
        
        if let event = event {
            self.saveButton.title = "Update"
        } else {
            self.saveButton.title = "Save"
            event = Event.create() as? Event
            event?.dateStart = NSDate()
            event?.dateEnd = NSDate()
        }
        self.configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kEventWillSaveNotification), object: nil, userInfo:["event": event!])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tableView.superview!.endEditing(true)
    }

    fileprivate func configure() {
        title = "Add Event"
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.contentOffset.y = -10
        
        // Create RowFomers
        
        let titleRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Event title"
        }
        rows.append(titleRow)
        
        let locationRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Location"
        }
        rows.append(locationRow)
        
        let allDayRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "All-day"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.switchButton.onTintColor = .formerSubColor()
        }
        rows.append(allDayRow)
        
        let startRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Start date"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFont(ofSize: 15)
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .dateAndTime
            }.displayTextFromDate(String.mediumDateShortTime)
        rows.append(startRow)

        let endRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "End date"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFont(ofSize: 15)
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .dateAndTime
            }.displayTextFromDate(String.mediumDateShortTime)
        rows.append(endRow)
        
        let urlRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "URL"
        }
        rows.append(urlRow)
        
        let calendarRow = LabelRowFormer<FormLabelCell>() {
            $0.formTextLabel()?.textColor = .formerColor()
            $0.formTextLabel()?.font = .boldSystemFont(ofSize: 15)
            $0.formSubTextLabel()?.textColor = .formerSubColor()
            $0.formSubTextLabel()?.font = .systemFont(ofSize: 15)
            }.configure {
                $0.text = "Calendar"
                $0.cell.accessoryType = .disclosureIndicator
                $0.subText = "None"
            }.onSelected { _ in
                self.performSegue(withIdentifier: "showEventCalendar", sender: self)
        }
        rows.append(calendarRow)
        
        let inviteesRow = LabelRowFormer<FormLabelCell>() {
            $0.formTextLabel()?.textColor = .formerColor()
            $0.formTextLabel()?.font = .boldSystemFont(ofSize: 15)
            $0.formSubTextLabel()?.textColor = .formerSubColor()
            $0.formSubTextLabel()?.font = .systemFont(ofSize: 15)
            }.configure {
                $0.text = "Invitees"
                $0.cell.accessoryType = .disclosureIndicator
                $0.subText = "None"
            }.onSelected { _ in
                self.performSegue(withIdentifier: "showEventInvitees", sender: self)
        }
        rows.append(inviteesRow)
        
        let noteRow = TextViewRowFormer<FormTextViewCell>() {
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Note"
                $0.rowHeight = 150
        }
        rows.append(noteRow)
        
        endRow.onDateChanged { date in
            if startRow.date.compare(date) == .orderedDescending {
                startRow.update {
                    $0.date = date
                }
            } else {
            }
        }
        startRow.onDateChanged { date in
            if endRow.date.compare(date) == .orderedAscending {
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
                $0.datePicker.datePickerMode = on ? .date : .dateAndTime
            }
            endRow.update {
                $0.displayTextFromDate(
                    on ? String.mediumDateNoTime : String.mediumDateShortTime
                )
            }
            endRow.inlineCellUpdate {
                $0.datePicker.datePickerMode = on ? .date : .dateAndTime
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showEventCalendarVC" {
            let destVC = segue.destination as! EventCalendarTableViewController
            destVC.event = event
        }
    }
    
    fileprivate func createEvent() {
        
        let parameters: [String: Any] = [
            "calendar_id": self.event!.calendar!.id!,
            "title": self.event!.title! as Any,
            "description": self.event!.notes! as Any,
            "location": self.event!.location! as Any,
            "date_start": FSCalendar().string(from: self.event!.dateStart! as Date, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            "date_end": FSCalendar().string(from: self.event!.dateEnd! as Date, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            "users": [[:]]]
        
        print(self.event!.dateStart!)
        print(self.event!.dateEnd!)
        RouterWrapper.shared.request(.createEvent(parameters)) { (response) in
            print(response.response)
            print(response.request)
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    SpinnerManager.showWhistle("kEventCreated", success: true)
                    UserManager.shared.setCredentials(response.response!)
                    break;
                default:
                    SpinnerManager.showWhistle("kFail", success: false)
                    break;
                }
            case .failure(let error):
                SpinnerManager.showWhistle("kFail", success: false)
                print(error.localizedDescription)
            }
        }
        
    }
    
    fileprivate func updateEvent() {
        let parameters: [String: Any] = [
            "id": self.event!.id!,
            "calendar_id": self.event!.calendar!.id!,
            "title": self.event!.title! as Any,
            "description": self.event!.notes! as Any,
            "location": self.event!.location! as Any,
            "date_start": FSCalendar().string(from: self.event!.dateStart! as Date, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            "date_end": FSCalendar().string(from: self.event!.dateEnd! as Date, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
            "users": [[:]]]
        
        print(self.event!.dateStart!)
        print(self.event!.dateEnd!)
        RouterWrapper.shared.request(.createEvent(parameters)) { (response) in
            print(response.response)
            print(response.request)
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    SpinnerManager.showWhistle("kEventCreated", success: true)
                    UserManager.shared.setCredentials(response.response!)
                    break;
                default:
                    SpinnerManager.showWhistle("kFail", success: false)
                    break;
                }
            case .failure(let error):
                SpinnerManager.showWhistle("kFail", success: false)
                print(error.localizedDescription)
            }
        }
        
    }
    
    fileprivate func checkEventDetails() -> Bool {
        var success = event?.title != nil
        success = success && event?.location != nil
        success = success && event?.dateStart != nil
        success = success && event?.dateEnd != nil
        if event?.dateStart != nil && event?.dateEnd != nil {
            success = success && (event!.dateStart!.compare(event!.dateEnd! as Date) == .orderedAscending || event!.dateStart!.compare(event!.dateEnd! as Date) == .orderedSame)
        }
        success = success && event?.notes != nil
        return success
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddEventMode = self.parent is UINavigationController
        
        if isPresentingInAddEventMode {
            event?.delete()
            dismiss(animated: true, completion: nil)
        } else {
            let changedValues = event!.changedValuesForCurrentEvent()
            for (key, value) in changedValues {
                event!.setValue(value, forKey: key)
            }
            navigationController!.popViewController(animated: true)
        }
    }
    
    @IBAction func saveEvent(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kEventWillSaveNotification), object: nil, userInfo:["event": event!])
        
        let isPresentingInAddEventMode = presentingViewController is UINavigationController
        
        if isPresentingInAddEventMode {
            //            if checkEventDetails() {
            //                createEvent()
            //            }
            dismiss(animated: true, completion: nil)
        } else {
            //            if checkEventDetails() {
            //                updateEvent()
            //            }
            navigationController!.popViewController(animated: true)
        }
    }
    
    @IBAction func unwindToEvent(_ sender: UIStoryboardSegue) {
        self.tableView.reloadData()
    }
}
