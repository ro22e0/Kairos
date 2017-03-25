//
//  ChatTableViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 19/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class ChatTableViewController: UITableViewController {
    
    var chatRooms = [ChatRoom]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.chatRooms = ChatRoomManager.shared.chatRooms()
        print(chatRooms.count)
        self.title = "Chats"
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        self.tableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "chatCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.chatRooms = ChatRoomManager.shared.chatRooms()
        self.tableView.reloadData()
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
        return chatRooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        
        // Configure the cell...
        let crm = ChatRoomManager.shared
        let chat = chatRooms[indexPath.row]
        let receivers = crm.receivers(for: chat)
        if receivers.count == 1 {
            let receiver = receivers.first!
            cell.profileImageView.setImageWith(receiver.name!, color: .orangeTint(), circular: true)
        }
        cell.nameLabel.text = chat.title
        if let message = crm.lastMessage(for: chat) {
            cell.messageLabel.text = message.body
            cell.dateLabel.text = String.mediumDateNoTime(message.createdAt as! Date)
        } else {
            cell.messageLabel.isHidden = true
            cell.dateLabel.isHidden = true
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        
        self.performSegue(withIdentifier: "showChatRoom", sender: cell)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            delete(chatRoom: chatRooms[indexPath.row])
        }
    }

    fileprivate func delete(chatRoom: ChatRoom) {
        let parameters = ["id": chatRoom.chatRoomID!]

        ProjectManager.shared.delete(parameters) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kProjectSuccess")
//                print(DataSync.dataStack().viewContext)
                print(DataSync.newContext)
                chatRoom.delete()
                let _ = chatRoom.save()
                self.chatRooms = ChatRoomManager.shared.chatRooms()
                self.tableView.reloadData()
            case .error(let error):
                Spinner.showWhistle("kProjectError", success: false)
                print(error)
            }
        }
    }

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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destVC = segue.destination as? RoomViewController {
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
            let chatRoom = chatRooms[indexPath.row]
            destVC.chatRoom = chatRoom
            destVC.displayName = chatRoom.title
        }
    }
}

extension ChatTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Chats")
    }
}
