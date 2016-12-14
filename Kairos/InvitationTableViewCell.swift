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
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func accept(sender: UIButton) {
        let friend = User.find("id == %@", args: self.tag) as! User
        let parameters = ["user_id": friend.id!]
        
        FriendManager.sharedInstance.accept(parameters) { (status) in
            switch status {
            case .Success:
                SpinnerManager.showWhistle("kFriendSuccess")
            case .Error(let error):
                SpinnerManager.showWhistle("kFriendError", success: false)
                print(error)
            }
        }
    }
    
    @IBAction func decline(sender: UIButton) {
        let friend = User.find("id == %@", args: self.tag) as! User
        let parameters = ["user_id": friend.id!]

        FriendManager.sharedInstance.refuse(parameters) { (status) in
            switch status {
            case .Success:
                friend.delete()
                SpinnerManager.showWhistle("kFriendSuccess")
            case .Error(let error):
                SpinnerManager.showWhistle("kFriendError", success: false)
                print(error)
            }
        }    }
}
