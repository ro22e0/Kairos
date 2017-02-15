//
//  FriendRequestsActions.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 14/02/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import SwiftMessages

class FriendRequestsActions: MessageView {

    var cancelAction: (() -> Void)?
    var friendRequests: (() -> Void)?
    var outgoingRequest: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func friendRequests(_ sender: Any) {
        cancelAction?()
        friendRequests?()
    }
    
    @IBAction func outgoingRequests(_ sender: Any) {
        cancelAction?()
        outgoingRequest?()
    }
}
