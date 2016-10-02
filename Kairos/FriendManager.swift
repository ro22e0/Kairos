//
//  FriendManager.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 01/10/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData

class FriendManager {
    
    // MARK: Singleton
    static let sharedInstance = FriendManager()
    private init() {}
 
    func getFriends() -> [Friend] {
        let friends = Friend.query("owner == %@", args: UserManager.sharedInstance.current) as! [Friend]
        
        return friends
    }

    func getFriends(withStatus status: FriendStatus) -> [Friend] {
        //let predicate = NSPredicate(format: "owner == %@ AND status == %@", self.current, status.hashValue)
        let properties = ["owner": UserManager.sharedInstance.current as NSManagedObject, "status": status.hashValue]
        let friends = Friend.query(properties) as! [Friend]
        
        return friends
    }
}