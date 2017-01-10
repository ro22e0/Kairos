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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func configure(_ event: Event) {
        NotificationCenter.default
            .addObserver(self, selector: #selector(BaseEventTableViewCell.updateEvent(_:)),
                         name:NSNotification.Name(rawValue: kEventWillSaveNotification),
                         object: nil)
    }

    @objc func updateEvent(_ notification: Notification) {
        let event = notification.userInfo!["event"] as! Event

        event.save()
    }
}
