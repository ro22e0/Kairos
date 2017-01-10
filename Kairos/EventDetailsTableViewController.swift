//
//  EventDetailsTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 16/04/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class EventDetailsTableViewController: UITableViewController {
    
    // MARK: - Class Properties
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.estimatedRowHeight = 135
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "kEventInfosCell", for: indexPath) as! EventInfosTableViewCell
            cell.titleLabel.text = event?.title
            cell.locationTextView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
            cell.locationTextView.text = event?.location
            fillDates(cell)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "kEventCalendarCell", for: indexPath) as! EventCalendarTableViewCell
            cell.calendarLabel.text = event?.calendar?.name ?? ""
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "kEventDescriptionCell", for: indexPath) as! EventDescriptionTableViewCell
            cell.descriptionLabel.text = event?.notes
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    fileprivate func fillDates(_ cell: EventInfosTableViewCell) {
        if (event!.dateStart! == event!.dateEnd!) == true {
            print("fidsvsdfgkdflkgdfm")
        } else {
            print("nooooooooooooo")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short

        
        cell.startDateLabel.text = dateFormatter.string(from: event!.dateStart! as Date)
        cell.endDateLabel.text = dateFormatter.string(from: event!.dateEnd! as Date)
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    @IBAction func deleteEvent(_ sender: UIButton) {
        
        let parameters: [String: Any] = ["id": self.event!.id!]
        
        RouterWrapper.shared.request(.deleteEvent(parameters)) { (response) in
            print(response.response)
            print(response.request)
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    SpinnerManager.showWhistle("kEventDeleted", success: true)
                    UserManager.shared.setCredentials(response.response!)
                    self.event?.delete()
                    self.dismiss(animated: true, completion: nil)
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
        event?.delete()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowEditEventSegue" {
            let destVC = segue.destination as! EventTableViewController
            destVC.event = event
        }
    }
    
    @IBAction func unwindToEventDetails(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EventTableViewController, let event = sourceViewController.event {
            self.event = event
        }
    }
}
