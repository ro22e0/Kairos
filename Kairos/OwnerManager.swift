//
//  OwnerManager.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 06/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation

class OwnerManager {
    // MARK: Singleton
    static let sharedInstance = OwnerManager()
    private init() {
        self.owner = Owner.findOrCreate([:])  as? Owner
    }

    private(set) var owner: Owner?

    func newOwner(uid: String, client: String, accessToken: String) {
        owner?.uid = uid
        owner?.client = client
        owner?.accessToken = accessToken
    }

    func getFriends() -> [Friend] {
        let friends = Friend.query("owner == %@", args: self.owner!) as! [Friend]

        return friends
    }

    func getFriends(withStatus status: FriendStatus) -> [Friend] {
        print(self.owner)
        print(status.hashValue)
        let predicate = NSPredicate(format: "owner == %@ AND status == %@", self.owner!, status.hashValue)
        let friends = Friend.query(predicate) as! [Friend]

        return friends
    }
}