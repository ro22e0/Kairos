//
//  ActionButtonCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 10/04/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class ActionButtonCell: UITableViewCell, LabelFormableRow {

    @IBOutlet weak var actionButton: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func formTextLabel() -> UILabel? {
        return actionButton
    }
    
    func formSubTextLabel() -> UILabel? {
        return nil
    }
    
    func updateWithRowFormer(_ rowFormer: RowFormer) {
    }
}
