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
    @IBOutlet weak var dateNavigationBar: UINavigationBar!
    @IBOutlet weak var dateNavigationItem: UINavigationItem!
    @IBOutlet weak var datePickerButton: UIButton!
    @IBOutlet var navigationBarBottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet var navigationBarTopHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!

    // MARK: - Class Properties
    let weekButtonItem = UIBarButtonItem(title: "Week", style: .Plain, target: nil, action: #selector(CalendarViewController.modeWeek(_:)))
    let monthButtonItem = UIBarButtonItem(title: "Month", style: .Plain, target: nil, action: #selector(CalendarViewController.modeMonth(_:)))
    
    var event: Event!

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(CalendarViewController.swiped(_:)))
        swipeDown.direction = .Down
        self.dateNavigationBar.addGestureRecognizer(swipeDown)
        self.view.addGestureRecognizer(swipeDown)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(CalendarViewController.swiped(_:)))
        swipeUp.direction = .Up
        self.dateNavigationBar.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeUp)
        
        // Do any additional setup after loading the view.
        calendarView.scrollDirection = .Horizontal
        calendarView.showsPlaceholders = false
        calendarView.clipsToBounds = true
        calendarView.appearance.caseOptions = [.HeaderUsesUpperCase, .WeekdayUsesSingleUpperCase]
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        calendarView.locale = NSLocale.currentLocale()
        
        calendarView.selectDate(calendarView.today)
        updateCurrentDate(calendarView.today)
        
        let propeties = ["title":"Apple Special Event", "location":"apple.com/apple-events/april-2016/", "notes":"New products !", "startDate":NSDate(), "endDate": NSDate()]
        event = Event.findOrCreate(propeties) as! Event
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        navBarDown()
    }
    
    func swiped(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Down:
                navBarDown()
            case UISwipeGestureRecognizerDirection.Up:
                eventUp()
            default:
                break
            }
        }
    }
    
    func eventUp() {
        NSLayoutConstraint.deactivateConstraints([self.navigationBarTopHeightConstraint])
        NSLayoutConstraint.deactivateConstraints([self.navigationBarBottomHeightConstraint])
        
        self.navigationBarTopHeightConstraint = NSLayoutConstraint(item: self.navigationBarTopHeightConstraint.firstItem, attribute: self.navigationBarTopHeightConstraint.firstAttribute, relatedBy: .Equal, toItem: self.navigationBarTopHeightConstraint.secondItem, attribute: self.navigationBarTopHeightConstraint.secondAttribute, multiplier: 1, constant: 8)
        NSLayoutConstraint.activateConstraints([self.navigationBarTopHeightConstraint])
        
        self.navigationBarBottomHeightConstraint = NSLayoutConstraint(item: self.navigationBarBottomHeightConstraint.firstItem, attribute: self.navigationBarBottomHeightConstraint.firstAttribute, relatedBy: .GreaterThanOrEqual, toItem: self.navigationBarBottomHeightConstraint.secondItem, attribute: self.navigationBarBottomHeightConstraint.secondAttribute, multiplier: 1, constant: 0)
        NSLayoutConstraint.activateConstraints([self.navigationBarBottomHeightConstraint])
        
        self.view.bringSubviewToFront(self.eventTableView)
        self.view.bringSubviewToFront(self.dateNavigationBar)
        UIView.animateWithDuration(SWIPE_ANIMATION_DURATION, animations: {
            self.datePicker.hidden = true
            self.eventTableView.hidden = false
            self.view.layoutIfNeeded()
        }) { (completion) in
            if self.calendarView.scope == .Week {
                self.dateNavigationItem.rightBarButtonItem = self.monthButtonItem
            } else {
                self.dateNavigationItem.rightBarButtonItem = self.weekButtonItem
            }
        }
    }
    
    func pickerUp() {
        NSLayoutConstraint.deactivateConstraints([self.navigationBarTopHeightConstraint])
        NSLayoutConstraint.deactivateConstraints([self.navigationBarBottomHeightConstraint])
        
        self.navigationBarBottomHeightConstraint = NSLayoutConstraint(item: self.navigationBarBottomHeightConstraint.firstItem, attribute: self.navigationBarBottomHeightConstraint.firstAttribute, relatedBy: .Equal, toItem: self.navigationBarBottomHeightConstraint.secondItem, attribute: self.navigationBarBottomHeightConstraint.secondAttribute, multiplier: 1, constant: 200)
        NSLayoutConstraint.activateConstraints([self.navigationBarBottomHeightConstraint])
        
        self.view.bringSubviewToFront(self.datePicker)
        self.view.bringSubviewToFront(self.dateNavigationBar)
        UIView.animateWithDuration(SWIPE_ANIMATION_DURATION, animations: {
            self.eventTableView.hidden = true
            self.datePicker.hidden = false
            self.view.layoutIfNeeded()
        }) { (completion) in
            let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: #selector(CalendarViewController.updateSelectedDate(_:)))
            self.dateNavigationItem.rightBarButtonItem = doneButtonItem
            self.datePicker.backgroundColor = .whiteColor()
        }
    }
    
    func navBarDown() {
        calendarView.setScope(.Month, animated: true)
        NSLayoutConstraint.deactivateConstraints([self.navigationBarTopHeightConstraint])
        NSLayoutConstraint.deactivateConstraints([self.navigationBarBottomHeightConstraint])
        
        self.navigationBarBottomHeightConstraint = NSLayoutConstraint(item: self.navigationBarBottomHeightConstraint.firstItem, attribute: self.navigationBarBottomHeightConstraint.firstAttribute, relatedBy: .Equal, toItem: self.navigationBarBottomHeightConstraint.secondItem, attribute: self.navigationBarBottomHeightConstraint.secondAttribute, multiplier: 1, constant: 0)
        NSLayoutConstraint.activateConstraints([self.navigationBarBottomHeightConstraint])
        
        self.navigationBarTopHeightConstraint = NSLayoutConstraint(item: self.navigationBarTopHeightConstraint.firstItem, attribute: self.navigationBarTopHeightConstraint.firstAttribute, relatedBy: .GreaterThanOrEqual, toItem: self.navigationBarTopHeightConstraint.secondItem, attribute: self.navigationBarTopHeightConstraint.secondAttribute, multiplier: 1, constant: 8)
        NSLayoutConstraint.activateConstraints([self.navigationBarTopHeightConstraint])
        
        UIView.animateWithDuration(SWIPE_ANIMATION_DURATION, animations: {
            self.datePicker.hidden = true
            self.eventTableView.hidden = true
            self.view.layoutIfNeeded()
        }) { (completion) in
            self.dateNavigationItem.rightBarButtonItem = nil
        }
    }
    
    func updateCurrentDate(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.locale = calendarView.locale
        datePickerButton.setTitle(dateFormatter.stringFromDate(date), forState: .Normal)
    }
    
    // MARK: - Actions
    @IBAction func pickDate(sender: AnyObject) {
        datePicker.setDate(calendarView.selectedDate, animated: false)
        pickerUp()
    }
    
    @IBAction func updateSelectedDate(sender: AnyObject) {
        updateCurrentDate(datePicker.date)
        calendarView.selectDate(datePicker.date, scrollToDate: true)
        navBarDown()
    }
    
    @IBAction func setTodaySelected(sender: AnyObject) {
        calendarView.selectDate(calendarView.today)
        updateCurrentDate(calendarView.today)
        navBarDown()
    }
    
    @IBAction func modeWeek(sender: AnyObject) {
        calendarView.setScope(.Week, animated: true)
        self.dateNavigationItem.rightBarButtonItem = monthButtonItem
    }
    
    @IBAction func modeMonth(sender: AnyObject) {
        calendarView.setScope(.Month, animated: true)
        self.dateNavigationItem.rightBarButtonItem = weekButtonItem
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "ShowEventDetails" {
            if let destVC = segue.destinationViewController as? EventDetailsTableViewController {
                destVC.event = event
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
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = eventTableView.dequeueReusableCellWithIdentifier("eventCell") as! EventTableViewCell

        cell.startTimeLabel.text = "18:00"
        cell.endTimeLabel.text = "20:00"
        cell.colorView.backgroundColor = .blueColor()
        cell.titleLabel.text = event.title
        cell.locationLabel.text = event.location
        
        return cell
    }

    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowEventDetails", sender: self)
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
    }
    
    // MARK: FSCalendarDelegate

    func calendarCurrentPageDidChange(calendar: FSCalendar) {
        if !calendar.isDate(calendar.selectedDate, equalToDate: calendar.currentPage.fs_firstDayOfMonth, toCalendarUnit: .Month) {
            calendarView.selectDate(calendar.currentPage.fs_firstDayOfMonth)
            updateCurrentDate(calendar.currentPage.fs_firstDayOfMonth)
        }
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        updateCurrentDate(date)
        eventUp()
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