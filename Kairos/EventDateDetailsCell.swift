//
//  EventDateDetailsCell.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class EventDateDetailsCell: UITableViewCell, LabelFormableRow {

    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func formTextLabel() -> UILabel? {
        return startLabel
    }
    
    func formSubTextLabel() -> UILabel? {
        return endLabel
    }
    
    func updateWithRowFormer(_ rowFormer: RowFormer) {}
}
