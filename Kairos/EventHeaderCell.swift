//
//  EventHeaderCell.swift
//  Kairos
//
//  Created by rba3555 on 16/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class EventHeaderCell: UITableViewCell, LabelFormableRow {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var participantLabel: UILabel!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var whiteView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        whiteView.round()
        colorView.round()

        self.acceptButton.setImage(UIImage(named: "Checkmark"), for: UIControlState())
        self.acceptButton.setImage(UIImage(named: "Checkmark Filled"), for: .disabled)
        self.declineButton.setImage(UIImage(named: "Delete"), for: UIControlState())
        self.declineButton.setImage(UIImage(named: "Delete Filled"), for: .disabled)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func formTextLabel() -> UILabel? {
        return titleLabel
    }
    
    func formSubTextLabel() -> UILabel? {
        return nil
    }
    
    func updateWithRowFormer(_ rowFormer: RowFormer) {}
    
    @IBAction func accept(_ sender: Any) {
        let event = Event.find("id == %@", args: self.tag) as! Event
        let parameters = ["id": event.id!]
        
        EventManager.shared.accept(parameters) { (status) in
            switch status {
            case .success:
                self.acceptButton.isEnabled = false
                self.declineButton.isEnabled = true
                Spinner.showWhistle("kEventSuccess")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.EventStatusChange.rawValue), object: nil)
            case .error(let error):
                Spinner.showWhistle("kEventError", success: false)
                print(error)
            }
        }
    }
    
    @IBAction func decline(_ sender: Any) {
        let event = Event.find("id == %@", args: self.tag) as! Event
        let parameters = ["id": event.id!]
        
        EventManager.shared.refuse(parameters) { (status) in
            switch status {
            case .success:
                self.declineButton.isEnabled = false
                self.acceptButton.isEnabled = true
                Spinner.showWhistle("kEventSuccess")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.EventStatusChange.rawValue), object: nil)
            case .error(let error):
                Spinner.showWhistle("kEventError", success: false)
                print(error)
            }
        }
    }
}
