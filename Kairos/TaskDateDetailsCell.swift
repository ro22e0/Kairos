//
//  TaskDateDetailsCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 09/02/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class TaskDateDetailsCell: UITableViewCell, LabelFormableRow {

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

    func formTextLabel() -> UILabel? {
        return startDateLabel
    }
    
    func formSubTextLabel() -> UILabel? {
        return endDateLabel
    }
    
    func updateWithRowFormer(_ rowFormer: RowFormer) {}
}
