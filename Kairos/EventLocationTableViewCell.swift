//
//  EventLocationTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 05/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class EventLocationTableViewCell: BaseEventTableViewCell {

    @IBOutlet weak var locationTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func configure(event: Event) {
        super.configure(event)
        
        locationTextField.text = event.location
    }
    
    override func updateEvent(notification: NSNotification) {        
        let event = notification.userInfo!["event"] as! Event
        
        event.location = locationTextField.text
        
        super.updateEvent(notification)
    }
}
