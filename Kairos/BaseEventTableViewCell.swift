//
//  BaseEventTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 05/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class BaseEventTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func configure(event: Event) {
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(BaseEventTableViewCell.updateEvent(_:)),
                         name:kEventWillSaveNotification,
                         object: nil)
    }

    @objc func updateEvent(notification: NSNotification) {
        let event = notification.userInfo!["event"] as! Event

        event.save()
    }
}
