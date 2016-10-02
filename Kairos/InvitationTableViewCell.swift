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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func accept(sender: UIButton) {
        let friend = Friend.find("id == %@", args: self.tag) as! Friend
        
        let parameters = ["accepted_friends": [["user_id": friend.id!]]]
        RouterWrapper.sharedInstance.request(.AcceptFriend(parameters)) { (response) in
            print(response.response)
            print(response.request)
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    SpinnerManager.showWhistle("kFriendInviteAccept", success: true)
                    friend.status = FriendStatus.Accepted.hashValue
                    UserManager.sharedInstance.setCredentials(response.response!)
                    break;
                default:
                    SpinnerManager.showWhistle("kFail", success: false)
                    break;
                }
                
            case .Failure(let error):
                SpinnerManager.showWhistle("kFail", success: false)
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func decline(sender: UIButton) {
        let friend = Friend.find("id == %@", args: self.tag) as! Friend
        
        let parameters = ["declined_friends": [["user_id": friend.id!]]]
        RouterWrapper.sharedInstance.request(.AcceptFriend(parameters)) { (response) in

            print(response.response)
            print(response.request)
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    SpinnerManager.showWhistle("kFriendInviteAccept", success: true)
                    friend.delete()
                    UserManager.sharedInstance.setCredentials(response.response!)
                    break;
                default:
                    SpinnerManager.showWhistle("kFail", success: false)
                    break;
                }
            case .Failure(let error):
                SpinnerManager.showWhistle("kFail", success: false)
                print(error.localizedDescription)
            }
        }
    }
}
