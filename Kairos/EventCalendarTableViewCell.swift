//
//  EventCalendarTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 16/04/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class EventCalendarTableViewCell: BaseEventTableViewCell {

    @IBOutlet weak var calendarLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func configure(_ event: Event) {
        super.configure(event)

        calendarLabel.text = event.calendar?.name
    }
}
