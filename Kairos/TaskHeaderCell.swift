//
//  TaskHeaderCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 31/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class TaskHeaderCell: UITableViewCell, LabelFormableRow {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateStartLabel: UILabel!
    @IBOutlet weak var dateEndLabel: UILabel!
    @IBOutlet weak var subtaskLabel: UILabel!
    @IBOutlet weak var assigneesLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func formTextLabel() -> UILabel? {
        return titleLabel
    }
    
    func formSubTextLabel() -> UILabel? {
        return nil
    }
    
    func updateWithRowFormer(_ rowFormer: RowFormer) {}
}
