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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func cancel(_ sender: UIButton) {
        let friend = User.find("id == %@", args: self.tag) as! User
        let parameters = ["user_id": friend.id!]
        
        FriendManager.shared.cancel(parameters) { (status) in
            switch status {
            case .success:
                friend.delete()
                Spinner.showWhistle("kFriendSuccess")
            case .error(let error):
                Spinner.showWhistle("kFriendError", success: false)
                print(error)
            }
        }

    }
}
