//
//  CalendarEditTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 23/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import DynamicColor
import DZNEmptyDataSet

class CalendarEditTableViewController: UITableViewController {
    
    var calendars = [Calendar]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendars = CalendarManager.shared.calendars(withStatus: .Participating)
        print(calendars.count)
        self.title = "Calendars"
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 52
        self.tableView.register(UINib(nibName: "CalendarTableViewCell", bundle: nil), forCellReuseIdentifier: "calendarCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.calendars = CalendarManager.shared.calendars(withStatus: .Participating)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    ///  Reload data notification handler
    ///
    ///  - parameter notification: The notification
    @objc func reloadData(_ notification: Notification) {
        self.calendars = CalendarManager.shared.calendars(withStatus: .Participating)
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.calendars.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) as! CalendarTableViewCell
        
        // Configure the cell...
        let calendar = calendars[indexPath.row]
        cell.nameLabel.text = calendar.name
        let participants = CalendarManager.shared.allUsers(forCalendar: calendar)
        cell.participantsLabel.text = String(participants.count)
        
        if let calendarColor = calendar.color {
            let hexColor = CalendarManager.shared.colors[calendarColor]
            let color = DynamicColor(hexString: hexColor!)
            cell.colorView.backgroundColor = color
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        
        self.performSegue(withIdentifier: "showCalendarDetails", sender: cell)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "showCalendarDetails" {
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
            let destVC = segue.destination as! CalendarDetailsTableViewController
            destVC.calendar = calendars[indexPath.row]
        }
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension CalendarEditTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No calendars to show")
    }
}
