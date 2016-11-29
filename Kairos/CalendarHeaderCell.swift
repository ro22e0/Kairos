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
        self.acceptButton.setImage(UIImage(named: "Checkmark"), forState: .Normal)
        self.acceptButton.setImage(UIImage(named: "Checkmark Filled"), forState: .Disabled)
        self.declineButton.setImage(UIImage(named: "Delete"), forState: .Normal)
        self.declineButton.setImage(UIImage(named: "Delete Filled"), forState: .Disabled)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func formTextLabel() -> UILabel? {
        return titleLabel
    }
    
    func formSubTextLabel() -> UILabel? {
        return nil
    }

    func updateWithRowFormer(rowFormer: RowFormer) {}

    @IBAction func accept(sender: AnyObject) {
        let calendar = Calendar.find("id == %@", args: self.tag) as! Calendar
        let parameters = ["id": calendar.id!]
        
        CalendarManager.sharedInstance.accept(parameters) { (status) in
            switch status {
            case .Success:
                self.acceptButton.enabled = false
                self.declineButton.enabled = true
                SpinnerManager.showWhistle("kCalendarSuccess")
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CalendarDidChange.rawValue, object: nil)
            case .Error(let error):
                SpinnerManager.showWhistle("kCalendarError", success: false)
                print(error)
            }
        }
    }

    @IBAction func decline(sender: AnyObject) {
        let calendar = Calendar.find("id == %@", args: self.tag) as! Calendar
        let parameters = ["id": calendar.id!]
        
        CalendarManager.sharedInstance.refuse(parameters) { (status) in
            switch status {
            case .Success:
                self.declineButton.enabled = false
                self.acceptButton.enabled = true
                SpinnerManager.showWhistle("kCalendarSuccess")
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CalendarDidChange.rawValue, object: nil)
            case .Error(let error):
                SpinnerManager.showWhistle("kCalendarError", success: false)
                print(error)
            }
        }
    }
}
