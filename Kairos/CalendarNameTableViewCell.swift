//
//  CalendarNameTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 15/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class CalendarNameTableViewCell: BaseCalendarTableViewCell {

    @IBOutlet weak var nameTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func configure(calendar: Calendar) {
        super.configure(calendar)
     
        self.nameTextField.text = calendar.name
    }
    
    override func updateCalendar(notification: NSNotification) {
        let calendar = notification.userInfo!["calendar"] as! Calendar
        
        calendar.name = nameTextField.text
        
        super.updateCalendar(notification)
    }

}
