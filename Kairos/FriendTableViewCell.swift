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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func actions(sender: UIButton) {
        let friend = Friend.find("id == %@", args: self.tag) as! Friend

        let destVC = FriendActionPopoverTableViewController(nibName: "FriendActionPopoverTableViewController", bundle: NSBundle.mainBundle())
        destVC.friend = friend
        destVC.modalPresentationStyle = .Popover
        destVC.preferredContentSize = CGSizeMake(self.window!.frame.width, 87)

        let popoverPC = destVC.popoverPresentationController
        popoverPC?.sourceView = sender
        popoverPC?.permittedArrowDirections = .Up
        popoverPC?.delegate = self
        popoverPC?.sourceRect = CGRect(x: sender.frame.width / 2, y: sender.frame.height, width: 1, height: 1)

        self.viewController()?.presentViewController(destVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}
