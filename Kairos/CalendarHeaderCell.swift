//
//  CalendarHeaderCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 08/10/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class CalendarHeaderCell: UITableViewCell, LabelFormableRow {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var participantLabel: UILabel!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var colorImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        let calendar = Calendar.find("id == %@", args: self.tag) as! Calendar
        let parameters = ["id": calendar.id!]
        
        CalendarManager.shared.accept(parameters) { (status) in
            switch status {
            case .success:
                self.acceptButton.isEnabled = false
                self.declineButton.isEnabled = true
                SpinnerManager.showWhistle("kCalendarSuccess")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.CalendarDidChange.rawValue), object: nil)
            case .error(let error):
                SpinnerManager.showWhistle("kCalendarError", success: false)
                print(error)
            }
        }
    }

    @IBAction func decline(_ sender: Any) {
        let calendar = Calendar.find("id == %@", args: self.tag) as! Calendar
        let parameters = ["id": calendar.id!]
        
        CalendarManager.shared.refuse(parameters) { (status) in
            switch status {
            case .success:
                self.declineButton.isEnabled = false
                self.acceptButton.isEnabled = true
                SpinnerManager.showWhistle("kCalendarSuccess")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.CalendarDidChange.rawValue), object: nil)
            case .error(let error):
                SpinnerManager.showWhistle("kCalendarError", success: false)
                print(error)
            }
        }
    }
}
