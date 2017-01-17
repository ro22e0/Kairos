//
//  LabelColorCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 24/11/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class LabelColorCell: UITableViewCell, LabelFormableRow {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorImageView: UIImageView!

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
