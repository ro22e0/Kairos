//
//  TaskTableViewCell.swift
//  Kairos
//
//  Created by rba3555 on 19/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var assigneesLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
