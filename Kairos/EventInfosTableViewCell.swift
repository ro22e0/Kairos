//
//  EventInfosTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 16/04/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class EventInfosTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
