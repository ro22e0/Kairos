//
//  ProjectTableViewCell.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var colorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        whiteView.round()
        colorView.round()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
