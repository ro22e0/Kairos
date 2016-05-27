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

        let parameters = ["friends": [["user_id": user.id!]]]
        RouterWrapper.sharedInstance.request(.InviteFriend(parameters)) { (response) in
            switch response.result {
            case .Success:
                SpinnerManager.showWhistle("kFriendInviteSent", success: true)
                break;
            case .Failure(let error):
                SpinnerManager.showWhistle("kFail", success: false)
                print(error.localizedDescription)
            }
        }
    }
    
}
