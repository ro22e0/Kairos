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
    var selectedCalendar: Calendar?
    fileprivate var deleteRow: RowFormer?
    fileprivate var calendarRow: RowFormer?
    fileprivate var peoplesRow: RowFormer?
    
    fileprivate var addedUsers = [User: UserStatus]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //        eventStartDateCell = EventStartDateTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        //        eventEndDateCell = EventEndDateTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        if self.event == nil {
            self.saveButton.title = "Save"
            self.navigationItem.title = "New Event"
            self.event = Event.temporary()
        } else {
            self.navigationItem.title = "Update Event"
            self.saveButton.title = "Save"
            deleteRow = LabelRowFormer<FormLabelCell>() {
                $0.titleLabel.textAlignment = .center
                $0.titleLabel.textColor = .red
                }
                .configure { row in
                    row.text = "Delete event"
                }.onSelected { row in
                    self.delete()
            }
        }
        configure()
        let queue = DispatchQueue.init(label: "fill_users")
        queue.async {
            let em = EventManager.shared
            self.fillAddedUsers(participants: em.users(withStatus: .Owner, forEvent: self.event!), for: .Owner)
            self.fillAddedUsers(participants: em.users(withStatus: .Participating, forEvent: self.event!), for: .Participating)
            self.fillAddedUsers(participants: em.users(withStatus: .Invited, forEvent: self.event!), for: .Invited)
            self.fillAddedUsers(participants: em.users(withStatus: .Refused, forEvent: self.event!), for: .Refused)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        tableView.backgroundColor = .background()
        tableView.bounces = false
        //        tableView.contentInset.bottom = 30
        //        tableView.contentOffset.y = -10
        
        // Create RowFomers
        
        let titleRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Event title"
                $0.text = event?.title
            }.onTextChanged { text in
                self.event?.title = text
        }
        rows.append(titleRow)
        
        let locationRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .systemFont(ofSize: 15)
            $0.selectionStyle = .none
            }.configure {
                $0.placeholder = "Location"
                $0.text = event?.location
            }.onTextChanged { (text) in
                self.event?.location = text
        }
        rows.append(locationRow)
        
        let allDayRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "All-day"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.switchButton.onTintColor = .formerSubColor()
            $0.selectionStyle = .none
        }
        rows.append(allDayRow)
        
        let startRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Start date"
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .formerSubColor()
            $0.displayLabel.font = .systemFont(ofSize: 15)
            $0.selectionStyle = .none
            }.configure {
                if let date = event?.dateStart {
                    $0.date = date as Date
                }
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
            $0.selectionStyle = .none
            }.configure {
                if let date = event?.dateEnd {
                    $0.date = date as Date
                }
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .dateAndTime
            }.displayTextFromDate(String.mediumDateShortTime)
        rows.append(endRow)
        
        endRow.onDateChanged { date in
            if startRow.date.compare(date) == .orderedDescending {
                startRow.update {
                    $0.date = date
                }
            } else {
            }
            self.event?.dateEnd = date as NSDate?
        }
        startRow.onDateChanged { date in
            if endRow.date.compare(date) == .orderedAscending {
                endRow.update {
                    $0.date = date
                }
            } else {
            }
            self.event?.dateStart = date as NSDate?
        }
        
        calendarRow = LabelRowFormer<FormLabelCell>() {
            $0.formTextLabel()?.textColor = .formerColor()
            $0.formTextLabel()?.font = .boldSystemFont(ofSize: 15)
            $0.formSubTextLabel()?.textColor = .formerSubColor()
            $0.formSubTextLabel()?.font = .systemFont(ofSize: 15)
            $0.selectionStyle = .none
            }.configure {
                $0.text = "Calendar"
                $0.cell.accessoryType = .disclosureIndicator
                $0.subText = event?.calendar?.name ?? "None"
                self.selectedCalendar = event?.calendar
            }.onSelected { _ in
                self.performSegue(withIdentifier: "showEventCalendar", sender: self)
            }.onUpdate {
                $0.subText = self.selectedCalendar?.name
        }
        rows.append(calendarRow!)
    
        peoplesRow = LabelRowFormer<FormLabelCell>() {
            $0.formTextLabel()?.textColor = .formerColor()
            $0.formTextLabel()?.font = .boldSystemFont(ofSize: 15)
            $0.formSubTextLabel()?.textColor = .formerSubColor()
            $0.formSubTextLabel()?.font = .systemFont(ofSize: 15)
            $0.selectionStyle = .none
            }.configure {
                $0.text = "People"
                $0.cell.accessoryType = .disclosureIndicator
                $0.subText = String(EventManager.shared.allUsers(forEvent: self.event!).count)
            }.onSelected { _ in
                self.performSegue(withIdentifier: "showEventParticipants", sender: self)
            }.onUpdate {
                $0.subText = String(EventManager.shared.allUsers(forEvent: self.event!).count)
        }
        rows.append(peoplesRow!)
        
        let noteRow = TextViewRowFormer<FormTextViewCell>() {
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            $0.selectionStyle = .none
            }.configure {
                $0.placeholder = "Note"
                $0.text = event?.notes
                $0.rowHeight = 150
            }.onTextChanged { (text) in
                self.event?.notes = text
        }
        rows.append(noteRow)
        
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
            return CustomViewFormer<FormHeaderFooterView>() {
                $0.contentView.backgroundColor = .background()
                }
                .configure {
                    $0.viewHeight = 20
            }
        }
        
        // Create SectionFormers
        
        let titleSection = SectionFormer(rowFormer: titleRow, locationRow)
            .set(headerViewFormer: createHeader())
        let dateSection = SectionFormer(rowFormer: allDayRow, startRow, endRow)
            .set(headerViewFormer: createHeader())
        let inviteSection = SectionFormer(rowFormer: calendarRow!, peoplesRow!)
            .set(headerViewFormer: createHeader())
        let noteSection = SectionFormer(rowFormer: noteRow)
            .set(headerViewFormer: createHeader())
        former.append(sectionFormer: titleSection, dateSection, inviteSection, noteSection)
        
        if let delRow = deleteRow {
            let sectionDelete = SectionFormer(rowFormer: delRow).set(headerViewFormer: createHeader())
            former.append(sectionFormer: sectionDelete)
        }
    }
    
    func fillAddedUsers(participants: [User], for status: UserStatus) {
        for u in participants {
            addedUsers[u] = status
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier! {
        case "showEventParticipants":
            let destVC = segue.destination as! EventParticipantTableViewController
            destVC.addedUsers = addedUsers
            destVC.update = { set in
                set(&self.addedUsers)
                self.peoplesRow?.update()
            }
        case "showEventCalendar":
            let destVC = segue.destination as! EventCalendarTableViewController
            destVC.event = event
            destVC.onSelected = { set in
                set(&self.selectedCalendar)
                self.self.calendarRow?.update()
            }
        default:
            break
        }
    }
    
    fileprivate func create() {
        var parameters = event!.dictionaryWithValues(forKeys: ["title", "location"])
        parameters["description"] = self.event?.notes
        parameters["calendar_id"] = self.selectedCalendar?.id
        parameters["date_start"] = String.formatDateApi(self.event!.dateStart! as Date)
        parameters["date_end"] = String.formatDateApi(self.event!.dateEnd! as Date)
        
        EventManager.shared.create(parameters) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kEventCreated", success: true)
                //                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.CalendarDidChange.rawValue), object: nil)
                self.dismiss(animated: true, completion: nil)
            case .error(let error):
                Spinner.showWhistle("kFail", success: false)
                print(error)
            }
        }
    }
    
    fileprivate func update() {
        var parameters = event!.dictionaryWithValues(forKeys: ["id", "title", "location"])
        parameters["description"] = self.event?.notes
        parameters["calendar_id"] = self.selectedCalendar?.id
        parameters["date_start"] = String.formatDateApi(self.event!.dateStart! as Date)
        parameters["date_end"] = String.formatDateApi(self.event!.dateEnd! as Date)
        
        EventManager.shared.update(parameters) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kCalendarSuccess")
                //                for userId in removed {
                //                    if let user = User.find("id == %@", args: userId) as? User {
                //                        EventManager.shared.delete(user: user, fromEvent: event!)
                //                    }
                //                }
                self.event?.save()
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.EventDidChange.rawValue), object: nil)
                self.navigationController!.popViewController(animated: true)
            case .error(let error):
                Spinner.showWhistle("kCalendarError", success: false)
                print(error)
            }
        }
        
        
    }
    
    fileprivate func delete() {
        let parameters = ["id": event!.id!]
        
        EventManager.shared.delete(parameters) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kEventSuccess")
                print(DataSync.dataStack().viewContext)
                print(DataSync.dataStack().mainContext)
                self.event?.delete()
                self.event?.save()
                print(self.event?.title)
                print(self.event?.owners?.count)
                //                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.CalendarDidChange.rawValue), object: nil)
                if self.presentingViewController is UITabBarController {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController!.popViewController(animated: true)
                }
                //                do {
                //                    try DataSync.dataStack().mainContext.save()
                //                } catch (let error) {
                //                    print(error)
            //                }
            case .error(let error):
                Spinner.showWhistle("kEventError", success: false)
                print(error)
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
        let isPresentingInAddEventMode = presentingViewController is UITabBarController
        
        if isPresentingInAddEventMode {
            dismiss(animated: true, completion: nil)
        } else {
            let changedValues = event!.changedValues()
            for (key, _) in changedValues {
                let oldValues = event?.committedValues(forKeys: [key])
                event!.setValue(oldValues?[key], forKey: key)
            }
            navigationController!.popViewController(animated: true)
        }
    }
    
    @IBAction func saveEvent(_ sender: UIBarButtonItem) {
        let isPresentingInAddEventMode = presentingViewController is UITabBarController
        
        if isPresentingInAddEventMode {
            create()
        } else {
            update()
        }
    }
    
    @IBAction func unwindToEvent(_ sender: UIStoryboardSegue) {
        self.tableView.reloadData()
    }
}
