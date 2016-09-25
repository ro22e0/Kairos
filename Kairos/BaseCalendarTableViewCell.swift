//
//  BaseCalendarTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 15/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class BaseCalendarTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(calendar: Calendar) {
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector:
                #selector(BaseCalendarTableViewCell.updateCalendar(_:)),
                         name:kCalendarWillSaveNotification,
                         object: nil)
    }

    @objc func updateCalendar(notification: NSNotification) {
        let calendar = notification.userInfo!["calendar"] as! Calendar

            calendar.save()
    }
}
