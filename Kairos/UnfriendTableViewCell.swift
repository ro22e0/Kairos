//
//  UnfriendTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 21/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class UnfriendTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    override func selected() {
        let friend = Friend.find("id == %@", args: self.tag) as! Friend

        let parameters = ["removed_friends": [["user_id": friend.id!]]]
        RouterWrapper.sharedInstance.request(.RemoveFriend(parameters)) { (response) in
            switch response.result {
            case .Success:
                friend.delete()
                SpinnerManager.showWhistle("kFriendRemove", success: true)
            case .Failure(let error):
                SpinnerManager.showWhistle("kFail", success: false)
                print(error.localizedDescription)
            }
            self.viewController()?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
