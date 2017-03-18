//
//  InvitationTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 25/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class InvitationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mutualFriendsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func accept(_ sender: UIButton) {
        let friend = User.find("id == %@", args: self.tag) as! User
        let parameters = ["user_id": friend.userID!]
        
        FriendManager.shared.accept(parameters) { (status) in
            switch status {
            case .success:
                Spinner.showWhistle("kFriendSuccess")
            case .error(let error):
                Spinner.showWhistle("kFriendError", success: false)
                print(error)
            }
        }
    }
    
    @IBAction func decline(_ sender: UIButton) {
        let friend = User.find("id == %@", args: self.tag) as! User
        let parameters = ["user_id": friend.userID!]

        FriendManager.shared.refuse(parameters) { (status) in
            switch status {
            case .success:
                friend.delete()
                Spinner.showWhistle("kFriendSuccess")
            case .error(let error):
                Spinner.showWhistle("kFriendError", success: false)
                print(error)
            }
        }    }
}
