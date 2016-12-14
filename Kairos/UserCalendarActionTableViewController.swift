//
//  UserCalendarActionTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 08/10/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class UserCalendarActionTableViewController: UITableViewController {
    
    var user: User?
    var calendar: Calendar?
    private lazy var former: Former = Former(tableView: self.tableView)

    var remove: ((User) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configure() {
        //        title = "Complete your profile"
        tableView.tableFooterView = UIView()
        tableView.backgroundView?.backgroundColor = .whiteColor()
        // Create RowFomers
        
        let remove = LabelRowFormer<UserActionTableViewCell>(instantiateType: .Nib(nibName: "UserActionTableViewCell")) {
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFontOfSize(15)
            }.configure {
                $0.text = "Remove" + " " + self.user!.name!
                $0.rowHeight = 44
            }.onSelected { cell in
                self.remove(self.user!)
                cell.cell.done()
        }
        let section = SectionFormer(rowFormer: remove).set(headerViewFormer: nil)
        former.append(sectionFormer: section)
    }
    
    override var preferredContentSize: CGSize {
        get {
            let height = self.tableView.rectForSection(0).height - 1
            return CGSize(width: super.preferredContentSize.width, height: height)
        }
        set { super.preferredContentSize = newValue }
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
