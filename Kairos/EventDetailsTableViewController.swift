//
//  EventDetailsTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 16/04/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former
import DynamicColor

class EventDetailsTableViewController: UITableViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    fileprivate lazy var former: Former = Former(tableView: self.tableView)
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: Notifications.EventDidChange.rawValue), object: nil)
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name(rawValue: Notifications.EventDidChange.rawValue), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.EventStatusChange.rawValue), object: nil)
    }
    
    //        NSNotificationCenter.defaultCenter().removeObserver(self, name: Notifications.CalendarDidChange.rawValue, object: nil)
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///  Reload data notification handler
    ///
    ///  - parameter notification: The notification
    @objc func reloadData(_ notification: Notification) {
        self.event = Event.find("id = %@", args: self.event?.id) as? Event
        if let event = self.event, event.userStatus != UserStatus.Refused.rawValue {
            self.former.removeAll()
            self.configure()
            self.former.reload()
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.EventDidChange.rawValue), object: nil)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func configure() {
        if let calendar = self.event, calendar.userStatus == UserStatus.Owner.rawValue {
            editButton.isEnabled = true
            editButton.tintColor = nil
        } else {
            editButton.isEnabled = false
            editButton.tintColor = .clear
        }
        
        self.title = "Event Details"
        self.tableView.tableFooterView = UIView()

        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        //        self.tableView.estimatedRowHeight = 44
        
        let em = EventManager.shared
        var rows = [RowFormer]()
        
        let participants = em.allUsers(forEvent: event!)
        let calendarHeader = LabelRowFormer<EventHeaderCell>(instantiateType: .Nib(nibName: "EventHeaderCell")) {
            $0.acceptButton.isEnabled = false
            $0.calendarLabel.text = self.event?.calendar?.name
            $0.participantLabel.text = String(participants.count)
            $0.selectionStyle = .none
            if let color = self.event?.calendar?.color {
                $0.colorView.backgroundColor = DynamicColor(hexString: CalendarManager.shared.colors[color]!)
            }
            }.configure {
                $0.cell.tag = event!.id!.intValue
                $0.text = event?.title
                $0.rowHeight = 80
        }
        let datesRow = LabelRowFormer<EventDateDetailsCell>(instantiateType: .Nib(nibName: "EventDateDetailsCell")) {
            $0.selectionStyle = .none
            }.configure {
                $0.text = String.mediumDateShortTime(event!.dateStart! as Date)
                $0.subText = String.mediumDateShortTime(event!.dateEnd! as Date)
                $0.rowHeight = 65
        }

        let noteRow = TextViewRowFormer<FormTextViewCell>() {
            $0.selectionStyle = .none
            }.configure {
                $0.text = event?.notes
                $0.rowHeight = 30
        }.onUpdate { cell in
            cell.cell.isUserInteractionEnabled = false
        }
        noteRow.update()
        let locationRow = TextViewRowFormer<FormTextViewCell>() {
            $0.selectionStyle = .none
            }.configure {
                $0.text = event?.location
                $0.rowHeight = 30
            }.onUpdate { cell in
                cell.cell.isUserInteractionEnabled = false
        }
        locationRow.update()
        
        set(participants: em.users(withStatus: .Owner, forEvent: event!), rows: &rows, status: .Owner)
        set(participants: em.users(withStatus: .Participating, forEvent: event!), rows: &rows, status: .Participating)
        set(participants: em.users(withStatus: .Invited, forEvent: event!), rows: &rows, status: .Invited)
        set(participants: em.users(withStatus: .Refused, forEvent: event!), rows: &rows, status: .Refused)
        
        let addPerson = LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = UIColor.orange
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
        rows.append(addPerson)
        
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
        let createEmptyHeader: (ViewFormer) = {
            return CustomViewFormer<UITableViewHeaderFooterView>() {
                $0.backgroundView = UIView()
                }.configure {
                    $0.viewHeight = 2
            }
        }()
        
        let sectionHeader = SectionFormer(rowFormer: calendarHeader).set(headerViewFormer: nil)
        let sectionDates = SectionFormer(rowFormer: datesRow).set(headerViewFormer: createEmptyHeader)
        let sectionDesc = SectionFormer(rowFormer: noteRow).set(headerViewFormer: createHeader("Description"))
        let sectionLocation = SectionFormer(rowFormer: locationRow).set(headerViewFormer: createHeader("Location"))
        
        let sectionParticipants = SectionFormer(rowFormers: rows).set(headerViewFormer: createHeader("Shared with"))
        
        self.former.append(sectionFormer: sectionHeader, sectionDates, sectionDesc, sectionLocation, sectionParticipants)
    }
    
    func set(participants: [User], rows: inout [RowFormer], status: UserStatus) {
        for user in participants {
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
                    $0.rowHeight = 40
            }
            rows.append(participant)
        }
    }
    
    fileprivate func invite(_ user: User, done: @escaping (String)->Void) -> Void {
        let parameters = ["id": event!.id!, "user_id": user.id!]
        let addedUsers = EventManager.shared.allUsers(forEvent: event!)
        
        if addedUsers.contains(user) {
            done("Already Added")
            Spinner.showWhistle("kEventAlreadyAdded")
            return
        }
        
        EventManager.shared.invite(parameters) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kEventSuccess")
                done("Invited")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.EventDidChange.rawValue), object: nil)
            case .error(let error):
                Spinner.showWhistle("kEventError", success: false)
                print(error)
            }
        }
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
    
}

//class EventDetailsTableViewController: UITableViewController {
//
//    // MARK: - Class Properties
//    var event: Event?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//
//        tableView.estimatedRowHeight = 135
//        tableView.rowHeight = UITableViewAutomaticDimension
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        switch indexPath.row {
//        case 0:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "kEventInfosCell", for: indexPath) as! EventInfosTableViewCell
//            cell.titleLabel.text = event?.title
//            cell.locationTextView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
//            cell.locationTextView.text = event?.location
//            fillDates(cell)
//            return cell
//        case 1:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "kEventCalendarCell", for: indexPath) as! EventCalendarTableViewCell
//            cell.calendarLabel.text = event?.calendar?.name ?? ""
//            return cell
//        case 2:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "kEventDescriptionCell", for: indexPath) as! EventDescriptionTableViewCell
//            cell.descriptionLabel.text = event?.notes
//            return cell
//        default:
//            let cell = UITableViewCell()
//            return cell
//        }
//    }
//
//    fileprivate func fillDates(_ cell: EventInfosTableViewCell) {
//        if (event!.dateStart! == event!.dateEnd!) == true {
//            print("fidsvsdfgkdflkgdfm")
//        } else {
//            print("nooooooooooooo")
//        }
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .full
//        dateFormatter.timeStyle = .short
//
//        cell.startDateLabel.text = dateFormatter.string(from: event!.dateStart! as Date)
//        cell.endDateLabel.text = dateFormatter.string(from: event!.dateEnd! as Date)
//    }
//
//    /*
//     // Override to support conditional editing of the table view.
//     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//     // Return false if you do not want the specified item to be editable.
//     return true
//     }
//     */
//
//    /*
//     // Override to support editing the table view.
//     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//     if editingStyle == .Delete {
//     // Delete the row from the data source
//     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//     } else if editingStyle == .Insert {
//     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//     }
//     }
//     */
//
//    /*
//     // Override to support rearranging the table view.
//     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
//
//     }
//     */
//
//    /*
//     // Override to support conditional rearranging of the table view.
//     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//     // Return false if you do not want the item to be re-orderable.
//     return true
//     }
//     */
//
//    @IBAction func deleteEvent(_ sender: UIButton) {
//
//        let parameters: [String: Any] = ["id": self.event!.id!]
//
//        RouterWrapper.shared.request(.deleteEvent(parameters)) { (response) in
//            print(response.response)
//            print(response.request)
//            switch response.result {
//            case .success:
//                switch response.response!.statusCode {
//                case 200...203:
//                    Spinner.showWhistle("kEventDeleted", success: true)
//                    UserManager.shared.setCredentials(response.response!)
//                    self.event?.delete()
//                    self.dismiss(animated: true, completion: nil)
//                    break;
//                default:
//                    Spinner.showWhistle("kFail", success: false)
//                    break;
//                }
//            case .failure(let error):
//                Spinner.showWhistle("kFail", success: false)
//                print(error.localizedDescription)
//            }
//        }
//        event?.delete()
//    }
//
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//
//        if segue.identifier == "ShowEditEventSegue" {
//            let destVC = segue.destination as! EventTableViewController
//            destVC.event = event
//        }
//    }
//
//    @IBAction func unwindToEventDetails(_ sender: UIStoryboardSegue) {
//        if let sourceViewController = sender.source as? EventTableViewController, let event = sourceViewController.event {
//            self.event = event
//        }
//    }
//}
