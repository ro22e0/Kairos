//
//  CalendarHeaderCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 08/10/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class CalendarHeaderCell: UITableViewCell, LabelFormableRow {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var participantLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    func formTextLabel() -> UILabel? {
        return titleLabel
    }
    
    func formSubTextLabel() -> UILabel? {
        return nil
    }
    
    func updateWithRowFormer(rowFormer: RowFormer) {}
}
