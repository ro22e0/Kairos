//
//  EventTitleTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 05/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class EventTitleTableViewCell: BaseEventTableViewCell {

    @IBOutlet weak var titleTextField: UITextField!
    
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
        
        titleTextField.text = event.title
    }
    
    override func updateEvent(notification: NSNotification) {
        super.updateEvent(notification)
        
        let event = notification.userInfo!["event"] as! Event
        
        event.title = titleTextField.text
    }
}
