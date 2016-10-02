//
//  CustomTextFieldTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 01/10/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class CustomTextFieldTableViewCell: UITableViewCell, TextFieldFormableRow {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func formTextField() -> UITextField {
        return textField
    }
    
    func formTitleLabel() -> UILabel? {
        return titleLabel
    }
    
    func updateWithRowFormer(rowFormer: RowFormer) {}
}
