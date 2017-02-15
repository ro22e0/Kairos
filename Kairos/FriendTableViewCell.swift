//
//  FriendTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 24/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell, UIPopoverPresentationControllerDelegate {
    
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
    
    func configure(user: User) {
        self.nameLabel.text = user.name
        
        let mutualFriends = user.mutualFriends?.allObjects as? [User]
        if let number = mutualFriends?.count, number > 0 {
            self.mutualFriendsLabel.isHidden = false
            self.mutualFriendsLabel.text = String(number)  + " mutual friends"
        } else {
            self.mutualFriendsLabel.isHidden = true
        }
        self.tag = Int(user.id!)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
