//
//  UserTaskActionTableViewController.swift
//  Kairos
//
//  Created by rba3555 on 19/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class UserTaskActionTableViewController: UITableViewController {

    var user: User?
    var task: Task?
    fileprivate lazy var former: Former = Former(tableView: self.tableView)
    
    var remove: ((User) -> Void)?
    var owner: ((User) -> Void)?
    
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
    
    fileprivate func configure() {
        //        title = "Complete your profile"
        tableView.tableFooterView = UIView()
        tableView.backgroundView?.backgroundColor = .white
        // Create RowFomers
        
        var rows = [RowFormer]()
        
        if let remove = remove {
            let removeCell = LabelRowFormer<UserActionTableViewCell>(instantiateType: .Nib(nibName: "UserActionTableViewCell")) {
                $0.titleLabel.textColor = .formerColor()
                $0.titleLabel.font = .boldSystemFont(ofSize: 15)
                }.configure {
                    $0.text = "Unassign" + " " + self.user!.name!
                    $0.rowHeight = 44
                }.onSelected { cell in
                    remove(self.user!)
                    cell.cell.done?()
            }
            rows.append(removeCell)
        }
        let section = SectionFormer(rowFormers: rows).set(headerViewFormer: nil)
        former.append(sectionFormer: section)
    }
    
    override var preferredContentSize: CGSize {
        get {
            let height = self.tableView.rect(forSection: 0).height - 1
            return CGSize(width: super.preferredContentSize.width, height: height)
        }
        set { super.preferredContentSize = newValue }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
