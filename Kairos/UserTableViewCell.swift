//
//  UserTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 26/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import UIImageView_Letters

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mutualFriendsLabel: UILabel!
    
    var onSelected: ((User, @escaping (String)->Void) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func invite(_ sender: UIButton) {
        let user = User.find("id == %@", args: self.tag) as! User
        self.onSelected!(user) { text in
            self.inviteButton.setTitle(text, for: UIControlState())
            self.inviteButton.isEnabled = false
        }
    }
    
}
