//
//  OwnerManager.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 06/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData

class OwnerManager {
    // MARK: Singleton
    static let sharedInstance = OwnerManager()
    private init() {
        self.owner = Owner.findOrCreate([:]) as? Owner
    }

    private(set) var owner: Owner?

    func setCredentials(response: NSHTTPURLResponse) {
        print("lol")
        let accessToken = response.allHeaderFields["access-token"] as! String
        let client  = response.allHeaderFields["client"] as! String
        let uid = response.allHeaderFields["uid"] as! String
        owner?.uid = uid
        owner?.client = client
        owner?.accessToken = accessToken
        print("setCredentials")
        print(OwnerManager.sharedInstance.owner!.accessToken)
        print(OwnerManager.sharedInstance.owner!.client)
        print(OwnerManager.sharedInstance.owner!.uid)
        print("END---setCredentials")
    }

    func getFriends() -> [Friend] {
        let friends = Friend.query("owner == %@", args: self.owner!) as! [Friend]

        return friends
    }

    func getFriends(withStatus status: FriendStatus) -> [Friend] {
        //let predicate = NSPredicate(format: "owner == %@ AND status == %@", self.owner!, status.hashValue)
        let properties = ["owner": self.owner! as NSManagedObject, "status": status.hashValue]
        let friends = Friend.query(properties) as! [Friend]

        return friends
    }
    
    func getUsers() -> [User] {
        let user = User.all() as! [User]

        return user
    }
    
    func getUsers(withName name: String) -> [User] {
        let namePred = NSPredicate(format: "name contains[c] %@", name)
        let nicknamePred = NSPredicate(format: "nickname contains[c] %@", name)
        let emailPred = NSPredicate(format: "email contains[c] %@", name)
        let compoundPred = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [namePred, nicknamePred, emailPred])

        let user = Friend.query(compoundPred) as! [User]
        return user
    }
}