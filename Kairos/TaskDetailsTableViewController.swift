//
//  TaskDetailsTableViewController.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class TaskDetailsTableViewController: UITableViewController {

    var project: Project?
    var task: Task?

    fileprivate lazy var former: Former = Former(tableView: self.tableView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //_model.users = TaskManager.shared.users(for: self.task!)

        title = project?.title

        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        guard let task = task else {
            dismiss(animated: true, completion: nil)
            return
        }
        
//        titleLabel.text = task.title
//        descriptionLabel.text = task.notes
//        dateStartLabel.text = String.shortDateNoTime(task.dateStart as! Date)
//        dateEndLabel.text = String.shortDateNoTime(task.dateEnd as! Date)
        
        self.tableView.tableFooterView = UIView()
        
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        //        self.tableView.estimatedRowHeight = 44
        
        var rows = [RowFormer]()
        
        let taskHeader = LabelRowFormer<TaskHeaderCell>(instantiateType: .Nib(nibName: "TaskHeaderCell")) {
                    $0.titleLabel.text = task.title
                    $0.descriptionLabel.text = task.notes
                    $0.dateStartLabel.text = String.shortDateNoTime(task.dateStart as! Date)
                    $0.dateEndLabel.text = String.shortDateNoTime(task.dateEnd as! Date)
            $0.selectionStyle = .none
            }.configure {
                $0.rowHeight = 80
        }
        let datesRow = LabelRowFormer<TaskDateDetailsCell>(instantiateType: .Nib(nibName: "TaskDateDetailsCell")) {
            $0.selectionStyle = .none
            $0.startDateLabel.text = String.shortDateNoTime(task.dateStart as! Date)
            $0.endDateLabel.text = String.shortDateNoTime(task.dateEnd as! Date)

            }.configure {
                $0.rowHeight = 65
        }
        
        let noteRow = TextViewRowFormer<FormTextViewCell>() {
            $0.selectionStyle = .none
            }.configure {
                $0.text = task.notes
                $0.rowHeight = UITableViewAutomaticDimension
            }.onUpdate { cell in
                cell.cell.isUserInteractionEnabled = false
        }
        noteRow.update()
        
        let assigneesListRow = CustomRowFormer<UserListCell>(instantiateType: .Nib(nibName: "UserListCell")) {
            $0.users = TaskManager.shared.users(for: task)
            }.configure {
                $0.rowHeight = 60
        }
        
        let createHeader: ((String) -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>() {
                $0.contentView.backgroundColor = .white
                $0.titleLabel?.textColor = .formerColor()
                $0.titleLabel?.font = .boldSystemFont(ofSize: 15)
                }.configure {
                    $0.viewHeight = 35
                    $0.text = text
            }
        }
        
        let sectionHeader = SectionFormer(rowFormer: taskHeader).set(headerViewFormer: nil)
        let sectionDates = SectionFormer(rowFormer: datesRow).set(headerViewFormer: nil)
        let sectionDescription = SectionFormer(rowFormer: noteRow).set(headerViewFormer: createHeader("Description"))
        
        let sectionAssignees = SectionFormer(rowFormer: assigneesListRow).set(headerViewFormer: createHeader("Assigned to"))
        
        self.former.append(sectionFormer: sectionHeader, sectionDates, sectionDescription, sectionAssignees)
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "showEditTask":
                let destVC = segue.destination as! EditTaskTableViewController
                destVC.project = task?.project
                destVC.task = task
            default:
                break
            }
        }
        
    }
    
}
