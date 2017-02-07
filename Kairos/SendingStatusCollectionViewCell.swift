//
//  SendingStatusCollectionViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 19/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit

class SendingStatusCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var label: UILabel!

    var text: NSAttributedString? {
        didSet {
            self.label.attributedText = self.text
        }
    }
}
