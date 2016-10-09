//
//  CalendarTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 10/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class CalendarTableViewController: FormViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var calendar: Calendar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if self.calendar == nil {
            self.saveButton.title = "Save"
            //            self.calendar = Calendar.create() as? Calendar
        } else {
            self.saveButton.title = "Update"
        }
        self.configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure() {
        self.title = "Edit Calendar"
        self.tableView.tableFooterView = UIView()
        
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        //        self.tableView.estimatedRowHeight = 44
        
        var rows = [RowFormer]()
        
        let nameRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
            }.configure {
                $0.placeholder = "Name"
        }
        
        let participant = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
            $0.statusColorView.backgroundColor = .cyanColor()
            $0.statusColorView.round()
            }.configure {
                $0.text = "Ronaël Bajazet"
                $0.subText = "owner"
                $0.rowHeight = 60
        }
        //        rows.append(participant)
        
        let addPerson = LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = UIColor.orangeColor()
            }.configure {
                $0.text = "Add participant..."
                $0.cell.accessoryType = .DisclosureIndicator
                $0.cell.selectionStyle = .None
                $0.rowHeight = 44
        }
        rows.append(addPerson)
        
        // Create Headers
        
        let createHeader: (String -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 40
                    $0.text = text
            }
        }
        
        // Create SectionFormers
        
        let sectionHeader = SectionFormer(rowFormer: nameRow).set(headerViewFormer: createHeader(""))
        let sectionParticipants = SectionFormer(rowFormers: rows).set(headerViewFormer: createHeader("Shared with:"))
        
        former.append(sectionFormer: sectionHeader, sectionParticipants)
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
    
    // MARK: - Navigation
    
    @IBAction func done(sender: UIBarButtonItem) {
        let isPresentingInAddEventMode = presentingViewController is UITabBarController
        
        if isPresentingInAddEventMode {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        let isPresentingInAddEventMode = presentingViewController is UITabBarController
        
        if isPresentingInAddEventMode {
            //            event?.delete()
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            //            let changedValues = event!.changedValuesForCurrentEvent()
            //            for (key, value) in changedValues {
            //                event!.setValue(value, forKey: key)
            //            }
            navigationController!.popViewControllerAnimated(true)
        }
    }
}
