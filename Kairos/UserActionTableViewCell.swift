//
//  UserActionTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 21/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class UserActionTableViewCell: UITableViewCell, LabelFormableRow {

    @IBOutlet weak var titleLabel: UILabel!

    var done: (() -> Void)!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.done = doneFunc
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func doneFunc() {
        self.viewController()?.dismissViewControllerAnimated(true, completion: nil)
    }

    func formTextLabel() -> UILabel? {
        return titleLabel
    }
    
    func formSubTextLabel() -> UILabel? {
        return nil
    }
    
    func updateWithRowFormer(rowFormer: RowFormer) {}
}
