//
//  CalendarViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 29/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import FSCalendar
import SwiftRecord
import DynamicColor
import DZNEmptyDataSet

private let SWIPE_ANIMATION_DURATION = 0.3

class CalendarViewController: UIViewController {
    
    // MARK: - UI Properties
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - Class Properties
    var allEvents = [Event]()
    var events = [Event]()
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch update
        DataSync.fetchUsers { (status) in
            FriendManager.shared.fetch()
            CalendarManager.shared.fetch()
            DataSync.fetchCalendarColors()
            EventManager.shared.fetch()
        }
        
        // Do any additional setup after loading the view.
        eventTableView.tableFooterView = UIView()
        
        calendarView.scrollDirection = .horizontal
        calendarView.placeholderType = .fillHeadTail
        calendarView.clipsToBounds = true
        calendarView.appearance.caseOptions = [.weekdayUsesSingleUpperCase]
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        //        calendarView.locale = NSLocale.currentLocale()
        //        calendarView.calendar.timeZone = NSTimeZone.systemTimeZone()
        allEvents = EventManager.shared.events(withStatus: .Participating)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: Notifications.EventDidChange.rawValue), object: nil)
        //        let _ = ["title":"Apple Special Event", "location":"apple.com/apple-events/april-2016/", "notes":"New products !", "startDate":Date(), "endDate": Date()] as [String : Any]
    }

    ///  Reload data notification handler
    ///
    ///  - parameter notification: The notification
    @objc func reloadData(_ notification: Notification) {
        events.removeAll()
        allEvents = EventManager.shared.events(withStatus: .Participating)
        calendarView.reloadData()
        eventTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func events(forDate date: Date) -> [Event] {
        var filteredEvents = [Event]()
        let current = NSCalendar.current
        
        for e in allEvents {
            let dateStart = current.date(bySettingHour: 0, minute: 0, second: 0, of: e.dateStart as! Date)
            let dateEnd = current.date(bySettingHour: 23, minute: 59, second: 59, of: e.dateEnd as! Date)
            let isBetween = (dateStart!...dateEnd!).contains(date)
            if isBetween {
                filteredEvents.append(e)
            }
        }
        return filteredEvents
    }
    
    // MARK: - Actions
    
    @IBAction func setTodaySelected(_ sender: Any) {
        calendarView.select(calendarView.today!)
    }
    
    func modeWeek() {
        calendarView.setScope(.week, animated: true)
    }
    
    func modeMonth() {
        calendarView.setScope(.month, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowEventDetails" {
            if let destVC = segue.destination as? EventDetailsTableViewController {
                if let indexPath = sender as? IndexPath {
                    destVC.event = events[indexPath.row]
                }
            }
        }
    }
    
    @IBAction func unwindToCalendar(_ sender: UIStoryboardSegue) {
        self.eventTableView.reloadData()
    }
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventTableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventTableViewCell
        
        let event = events[indexPath.row]

        cell.startTimeLabel.text = String.noDateShortTime(event.dateStart! as Date)
        cell.endTimeLabel.text = String.noDateShortTime(event.dateEnd! as Date)
        let hexColor = CalendarManager.shared.colors[event.calendar!.color!]
        let color = DynamicColor(hexString: hexColor!)
        cell.lineColorView.backgroundColor = color
        cell.roundColorView.backgroundColor = color
        cell.roundColorView.round()
        cell.titleLabel.text = event.title
        cell.locationLabel.text = event.location
        cell.participantLabel.text = EventManager.shared.allUsers(forEvent: event).count.description
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowEventDetails", sender: indexPath)
    }
}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    // MARK: FSCalendarDataSource
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date.distantPast
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date.distantFuture
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return events(forDate: date).count
        //UserManager.shared.getEvents(forDate: date).count
    }
    
    // MARK: FSCalendarDelegate
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        //        if !calendar.isDate(calendar.selectedDate, equalToDate: calendar.beginingOfMonthOfDate(calendar.currentPage), toCalendarUnit: .Month) {
        //                    calendarView.select(calendar.minimumDate)
        //        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        print("selected date: ", date)
        events = events(forDate: calendarView.selectedDate)
        self.eventTableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    // MARK: FSCalendarDelegateAppearance
    
}

extension CalendarViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Events")
    }
}
