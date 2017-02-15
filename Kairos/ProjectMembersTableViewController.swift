//
//  ProjectMembersTableViewController.swift
//  Kairos
//
//  Created by rba3555 on 18/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class ProjectMembersTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    fileprivate lazy var former: Former = Former(tableView: self.tableView)
    fileprivate var sectionMembers: SectionFormer!
    fileprivate var addPerson: RowFormer!
    fileprivate var rows = [RowFormer]()
    var project: Project?
    
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
        self.title = "Project Members"
        self.tableView.tableFooterView = UIView()
        
        addPerson = LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .orangeTint()
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            }.configure {
                $0.text = "Add member..."
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
    
    func set(members: [User], status: UserStatus) {
        for user in members {
            let member = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                switch status {
                case .Invited:
                    $0.statusColorView.backgroundColor = .orange
                case .Participating:
                    $0.statusColorView.backgroundColor = UIColor.green
                case .Refused:
                    $0.statusColorView.backgroundColor = .red
                case .Owner:
                    $0.statusColorView.backgroundColor = .cyan
                default: break
                }
                $0.statusColorView.round()
                }.configure {
                    $0.text = user.name
                    $0.subText = status.rawValue
                    $0.rowHeight = 40
            }
            rows.append(member)
        }
    }
    
    func reloadMembers() {
        former.remove(rowFormers: sectionMembers.rowFormers)
        rows.removeAll()
        let pm = ProjectManager.shared
        set(members: pm.users(withStatus: .Owner, forProject: project!), status: .Owner)
        set(members: pm.users(withStatus: .Participating, forProject: project!), status: .Participating)
        set(members: pm.users(withStatus: .Invited, forProject: project!), status: .Invited)
        set(members: pm.users(withStatus: .Refused, forProject: project!), status: .Refused)
        rows.append(addPerson)
        sectionMembers.add(rowFormers: rows)
        former.reload(sectionFormer: sectionMembers)
    }
    
    fileprivate func invite(_ user: User, done: @escaping (String)->Void) -> Void {
        let parameters = ["id": project!.id!, "user_id": user.id!]
        let addedUsers = ProjectManager.shared.allUsers(forProject: project!)
        
        if addedUsers.contains(user) {
            done("Already Added")
            Spinner.showWhistle("kProjectAlreadyAdded")
            return
        }
        
        ProjectManager.shared.invite(parameters) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kProjectSuccess")
                done("Invited")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.ProjectDidChange.rawValue), object: nil)
                self.reloadMembers()
            case .error(let error):
                Spinner.showWhistle("kProjectError", success: false)
                print(error)
            }
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
