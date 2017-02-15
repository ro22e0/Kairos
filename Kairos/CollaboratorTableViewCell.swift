//
//  CollaboratorTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 15/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class CollaboratorTableViewCell: UITableViewCell, LabelFormableRow {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusColorView: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func formTextLabel() -> UILabel? {
        return nameLabel
    }
    
    func formSubTextLabel() -> UILabel? {
        return statusLabel
    }

    func updateWithRowFormer(_ rowFormer: RowFormer) {}
}
