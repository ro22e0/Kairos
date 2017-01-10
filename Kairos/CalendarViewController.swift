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
import DZNEmptyDataSet

private let SWIPE_ANIMATION_DURATION = 0.3

class CalendarViewController: UIViewController {
    
    // MARK: - UI Properties
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - Class Properties
    var events = [Event]()
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch update
        DataSync.fetchUsers { (status) in
            FriendManager.shared.fetch()
//            CalendarManager.shared.fetch()
//            DataSync.fetchCalendarColors()
//            DataSync.fetchEvents()
        }
    
        // Do any additional setup after loading the view.
        calendarView.scrollDirection = .horizontal
        calendarView.placeholderType = .fillHeadTail
        calendarView.clipsToBounds = true
        calendarView.appearance.caseOptions = [.headerUsesUpperCase, .weekdayUsesSingleUpperCase]
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        //        calendarView.locale = NSLocale.currentLocale()
        //        calendarView.calendar.timeZone = NSTimeZone.systemTimeZone()
        
        calendarView.select(calendarView.today!)
        
        let _ = ["title":"Apple Special Event", "location":"apple.com/apple-events/april-2016/", "notes":"New products !", "startDate":Date(), "endDate": Date()] as [String : Any]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        cell.startTimeLabel.text = formatter.string(from: events[indexPath.row].dateStart! as Date)
        cell.endTimeLabel.text = formatter.string(from: events[indexPath.row].dateEnd! as Date)
        cell.colorView.backgroundColor = .blue
        cell.titleLabel.text = events[indexPath.row].title
        cell.locationLabel.text = events[indexPath.row].location
        
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
        return 0
        //UserManager.shared.getEvents(forDate: date).count
    }
    
    // MARK: FSCalendarDelegate
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//        if !calendar.isDate(calendar.selectedDate, equalToDate: calendar.beginingOfMonthOfDate(calendar.currentPage), toCalendarUnit: .Month) {
//            calendarView.selectDate(calendar.beginingOfMonthOfDate(calendar.currentPage))
//        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        print("selected date: ", date)
        self.events = UserManager.shared.getEvents(forDate: calendarView.selectedDate)
        self.eventTableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    // MARK: FSCalendarDelegateAppearance
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorsFor date: Date) -> [Any]? {
        return []
    }
}

extension CalendarViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Events")
    }
}
