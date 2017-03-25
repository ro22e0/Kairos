//
//  BlockUserTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 21/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class BlockUserTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    override func selected() {
//        let friend = User.find("id == %@", args: self.tag) as! User
//        
//        let parameters = ["blocked_friends": [["user_id": friend.userID!]]]
//        RouterWrapper.shared.request(.CancelFriend(parameters)) { (response) in
//            switch response.result {
//            case .success:
//                friend.status = FriendStatus.Blocked.hashValue
//                Spinner.showWhistle("kFriendBlocked", success: false)
//            case .failure(let error):
//                Spinner.showWhistle("kFail", success: false)
//                print(error.localizedDescription)
//            }
//            self.viewController()?.dismissViewControllerAnimated(true, completion: nil)
//        }
//    }
}
