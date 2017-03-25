//
//  TaskAssigneesTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 09/02/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class TaskAssigneesTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    fileprivate lazy var former: Former = Former(tableView: self.tableView)
    fileprivate var sectionMembers: SectionFormer!
    fileprivate var addPerson: RowFormer!
    fileprivate var rows = [RowFormer]()
    var task: Task?
    
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
    
    func configure() {
        self.title = "Task Assignees"
        self.tableView.tableFooterView = UIView()
        
        addPerson = LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .orangeTint()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            }.configure {
                $0.text = "Add assignee..."
                $0.cell.accessoryType = .disclosureIndicator
                $0.cell.selectionStyle = .none
                $0.rowHeight = 44
            }.onSelected { [weak self] _ in
                let storyboard = UIStoryboard(name: FriendsStoryboardID, bundle: nil)
                let destVC = storyboard.instantiateViewController(withIdentifier: "FriendsInviteTableViewController") as! FriendsInviteTableViewController
                destVC.friends = FriendManager.shared.friends()
                destVC.onSelected = { user, done in
                    self?.invite(user, done: done)
                }
                let nvc = UINavigationController(rootViewController: destVC)
                self?.present(nvc, animated: true, completion: nil)
        }
        // Create Headers
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
        // Create SectionFormers
        sectionMembers = SectionFormer(rowFormers: rows).set(headerViewFormer: createHeader("With:"))
        former.append(sectionFormer: sectionMembers)
        reloadMembers()
    }

    func set(users: [User]) {
        for user in users {
            let member = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                $0.statusColorView.isHidden = true
                $0.statusLabel.isHidden = true
                }.configure {
                    $0.text = user.name
                    $0.rowHeight = 45
            }
            if !user.isEqual(UserManager.shared.current.user) {
                member.onSelected{ [weak self] cell in
//                    self!.selectedUser(user, cell: cell)
                }
            }
            rows.append(member)
        }
    }
    
    func reloadMembers() {
        former.remove(rowFormers: sectionMembers.rowFormers)
        rows.removeAll()
        let pm = TaskManager.shared
        
        set(users: pm.users(for: task!))
        rows.append(addPerson)
        sectionMembers.add(rowFormers: rows)
        former.reload(sectionFormer: sectionMembers)
    }

    fileprivate func invite(_ user: User, done: @escaping (String)->Void) -> Void {
        let parameters = ["id": task!.taskID!, "user_id": user.userID!]
        let addedUsers = TaskManager.shared.users(for: task!)
        
        if addedUsers.contains(user) {
            done("Already Added")
            Spinner.showWhistle("kTaskAlreadyAdded")
            return
        }
        
        TaskManager.shared.invite(parameters) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kTaskSuccess")
                done("Invited")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.TaskDidChange.rawValue), object: nil)
                self.reloadMembers()
            case .error(let error):
                Spinner.showWhistle("kTaskError", success: false)
                print(error)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
