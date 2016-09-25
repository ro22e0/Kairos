//
//  SentInvitationTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 06/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class SentInvitationTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func cancel(sender: UIButton) {
        let friend = Friend.find("id == %@", args: self.tag) as! Friend
        print(friend.name)
    }
}