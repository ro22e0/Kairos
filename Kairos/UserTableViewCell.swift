//
//  UserTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 26/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mutualFriendsLabel: UILabel!
    
    var onSelected: ((User, ()->Void) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func invite(sender: UIButton) {
        let user = User.find("id == %@", args: self.tag) as! User
        self.onSelected!(user) {
            self.inviteButton.titleLabel?.text = "Sent"
            self.inviteButton.userInteractionEnabled = false
        }
    }
    
}
