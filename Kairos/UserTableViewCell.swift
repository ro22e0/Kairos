//
//  UserTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 26/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mutualFriendsLabel: UILabel!
    
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
        let parameters = ["user_id": user.id!]

        FriendManager.sharedInstance.invite(parameters) { (status) in
            switch status {
            case .Success:
                SpinnerManager.showWhistle("kFriendSuccess")
            case .Error(let error):
                SpinnerManager.showWhistle("kFriendError", success: false)
                print(error)
            }
        }
    }
    
}
