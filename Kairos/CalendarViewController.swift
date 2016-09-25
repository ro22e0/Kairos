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
//        DataSync.fetchCalendars()
        
        // Do any additional setup after loading the view.
        calendarView.scrollDirection = .Horizontal
        calendarView.placeholderType = .FillHeadTail
        calendarView.clipsToBounds = true
        calendarView.appearance.caseOptions = [.HeaderUsesUpperCase, .WeekdayUsesSingleUpperCase]
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        //        calendarView.locale = NSLocale.currentLocale()
        //        calendarView.calendar.timeZone = NSTimeZone.systemTimeZone()
        
        calendarView.selectDate(calendarView.today!)
        
        let _ = ["title":"Apple Special Event", "location":"apple.com/apple-events/april-2016/", "notes":"New products !", "startDate":NSDate(), "endDate": NSDate()]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Actions

    @IBAction func setTodaySelected(sender: AnyObject) {
        calendarView.selectDate(calendarView.today!)
    }
    
    func modeWeek() {
        calendarView.setScope(.Week, animated: true)
    }
    
    func modeMonth() {
        calendarView.setScope(.Month, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowEventDetails" {
            if let destVC = segue.destinationViewController as? EventDetailsTableViewController {
                if let indexPath = sender as? NSIndexPath {
                    destVC.event = events[indexPath.row]
                }
            }
        }
    }
    
    @IBAction func unwindToCalendar(sender: UIStoryboardSegue) {
        self.eventTableView.reloadData()
    }
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = eventTableView.dequeueReusableCellWithIdentifier("eventCell") as! EventTableViewCell
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        
        cell.startTimeLabel.text = formatter.stringFromDate(events[indexPath.row].dateStart!)
        cell.endTimeLabel.text = formatter.stringFromDate(events[indexPath.row].dateEnd!)
        cell.colorView.backgroundColor = .blueColor()
        cell.titleLabel.text = events[indexPath.row].title
        cell.locationLabel.text = events[indexPath.row].location
        
        return cell
    }
    
    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowEventDetails", sender: indexPath)
    }
}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    // MARK: FSCalendarDataSource
    
    func minimumDateForCalendar(calendar: FSCalendar) -> NSDate {
        return NSDate.distantPast()
    }
    
    func maximumDateForCalendar(calendar: FSCalendar) -> NSDate {
        return NSDate.distantFuture()
    }
    
    func calendar(calendar: FSCalendar, numberOfEventsForDate date: NSDate) -> Int {
        return 0
        //OwnerManager.sharedInstance.getEvents(forDate: date).count
    }
    
    // MARK: FSCalendarDelegate

    func calendarCurrentPageDidChange(calendar: FSCalendar) {
        if !calendar.isDate(calendar.selectedDate, equalToDate: calendar.beginingOfMonthOfDate(calendar.currentPage), toCalendarUnit: .Month) {
            calendarView.selectDate(calendar.beginingOfMonthOfDate(calendar.currentPage))
        }
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        print("selected date: ", date)
        self.events = OwnerManager.sharedInstance.getEvents(forDate: calendarView.selectedDate)
        self.eventTableView.reloadData()
    }
    
    func calendar(calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }

    // MARK: FSCalendarDelegateAppearance
    func calendar(calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorsForDate date: NSDate) -> [AnyObject]? {
        return []
    }
}