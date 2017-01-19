//
//  EventParticipantTableViewController.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class EventParticipantTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    fileprivate lazy var former: Former = Former(tableView: self.tableView)
    fileprivate var sectionParticipants: SectionFormer!
    fileprivate var addPerson: RowFormer!
    fileprivate var rows = [RowFormer]()
    var addedUsers = [User: UserStatus]()
    var update: (((inout [User: UserStatus]) -> Void)->Void)?
    
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
        self.title = "Event Participants"
        self.tableView.tableFooterView = UIView()
        
        addPerson = LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .orange
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            }.configure {
                $0.text = "Add participant..."
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
        sectionParticipants = SectionFormer(rowFormers: rows).set(headerViewFormer: createHeader("Shared with:"))
        former.append(sectionFormer: sectionParticipants)
        reloadParticipants()
    }
    
    func reloadParticipants() {
        former.remove(rowFormers: sectionParticipants.rowFormers)
        rows.removeAll()
        for (user, status) in addedUsers {
            let participant = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
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
                    $0.rowHeight = 45
            }
            if !user.isEqual(UserManager.shared.current.user) {
                participant.onSelected{ [weak self] cell in
                    self!.selectedUser(user, cell: cell)
                }
            }
            rows.append(participant)
        }
        rows.append(addPerson)
        sectionParticipants.add(rowFormers: rows)
        former.reload(sectionFormer: sectionParticipants)
        update!() { data in
            addedUsers = data
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    fileprivate func invite(_ user: User, done: (String)->Void) -> Void {
        let isIn = addedUsers.contains { (u, status) -> Bool in
            return user == u && status != .Removed
        }
        
        if !isIn {
            addedUsers[user] = .Invited
            let participant = LabelRowFormer<CollaboratorTableViewCell>(instantiateType: .Nib(nibName: "CollaboratorTableViewCell")) {
                $0.statusColorView.backgroundColor = .orange
                $0.statusColorView.round()
                }.configure {
                    $0.text = user.name
                    $0.subText = "invited"
                    $0.rowHeight = 45
                }.onSelected{ [weak self] cell in
                    self!.selectedUser(user, cell: cell)
            }
            Spinner.showWhistle("kEventSuccess")
            done("Invited")
            former.insertUpdate(rowFormer: participant, above: addPerson, rowAnimation: .automatic)
            former.reload(sectionFormer: sectionParticipants)
            // }
        } else {
            Spinner.showWhistle("kEventAlreadyAdded", success: false)
            done("Already added")
        }
    }
    
    fileprivate func selectedUser(_ user: User, cell: LabelRowFormer<CollaboratorTableViewCell>) {
        let storyboard = UIStoryboard(name: CalendarStoryboardID, bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "UserEventActionTableViewController") as! UserEventActionTableViewController
        destVC.user = user
        destVC.remove = { user in
            //            if self.addedUsers[user] == UserStatus.Invited {
            //                if let user = User.find("id == %@", args: user) as? User {
            //                    CalendarManager.shared.delete(user: user, fromCalendar: self.calendar!)
            //                }
            //                self.addedUsers.removeValue(forKey: user)
            //            } else {
            self.addedUsers[user] = .Removed
            //            }
            self.former.removeUpdate(rowFormer: cell)
        }
        if addedUsers[user] == .Participating {
            destVC.owner = { user in
                self.addedUsers[user] = .Owner
                self.reloadParticipants()
                self.former.reload(sectionFormer: self.sectionParticipants)
            }
        }
        
        destVC.modalPresentationStyle = .popover
        destVC.preferredContentSize = CGSize(width: self.view.frame.width, height: 43)
        let popoverPC = destVC.popoverPresentationController
        
        popoverPC?.permittedArrowDirections = .up
        popoverPC?.delegate = self
        popoverPC?.sourceView = cell.cell
        popoverPC?.sourceRect = CGRect(x: cell.cell.frame.width / 2, y: cell.cell.frame.height, width: 1, height: 1)
        self.present(destVC, animated: true, completion: nil)
    }
}
