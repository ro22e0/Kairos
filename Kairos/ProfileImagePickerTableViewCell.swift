//
//  ProfileImagePickerTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 29/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class ProfileImagePickerTableViewCell: UITableViewCell, LabelFormableRow {

    @IBOutlet weak var imageProfileView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate var imageViewColor: UIColor?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .formerColor()
        imageProfileView.backgroundColor = .formerColor()
        imageProfileView.round()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if imageViewColor == nil {
            imageViewColor = imageProfileView.backgroundColor
        }
        super.setHighlighted(highlighted, animated: animated)
        if let color = imageViewColor {
            imageProfileView.backgroundColor = color
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if imageViewColor == nil {
            imageViewColor = imageProfileView.backgroundColor
        }
        super.setSelected(selected, animated: animated)
        if let color = imageViewColor {
            imageProfileView.backgroundColor = color
        }
    }
    
    func formTextLabel() -> UILabel? {
        return titleLabel
    }
    
    func formSubTextLabel() -> UILabel? {
        return nil
    }
    
    func updateWithRowFormer(_ rowFormer: RowFormer) {}
}
