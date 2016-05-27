//
//  DataSync.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 11/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftRecord

struct DataSync {

    private static func deleteFriends(friends: [JSON]) {
        let ids = NSMutableArray()
        
        for f in friends {
            ids.addObject(f["id"].object)
        }
        
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedFriends = Friend.query(predicate) as! [Friend]
        for f in deletedFriends {
            f.delete()
        }
    }

    private static func syncFriends(friends: [JSON], status: FriendStatus) {
        for f in friends {
            let friend = Friend.findOrCreate(["id": f["id"].object]) as! Friend
            
            friend.status = status.hashValue
            friend.name = f["name"].stringValue
            friend.nickname = f["nickname"].stringValue
            friend.email = f["email"].stringValue
            friend.imageUrl = f["image"].stringValue
            friend.owner = OwnerManager.sharedInstance.owner
        }
        print(Friend.count())
    }

    static func fetchFriends() {
        Router.needToken = true
        RouterWrapper.sharedInstance.request(.GetFriends) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .Success:
                OwnerManager.sharedInstance.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    let accepted = json["friends"].arrayValue
                    let blocked = json["blocked_friends"].arrayValue
                    let requested = json["requested_friends"].arrayValue
                    let pending = json["pending_friends"].arrayValue
                    
                    let friends = accepted + blocked + requested + pending
                    self.deleteFriends(friends)
                    self.syncFriends(accepted, status: .Accepted)
                    self.syncFriends(blocked, status: .Blocked)
                    self.syncFriends(requested, status: .Requested)
                    self.syncFriends(pending, status: .Pending)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }

    private static func deleteUsers(users: [JSON]) {
        let ids = NSMutableArray()
        
        for u in users {
            ids.addObject(u["id"].object)
        }
        
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedUsers = User.query(predicate) as! [User]
        for u in deletedUsers {
            if !u.isKindOfClass(Owner) {
                print(u.email)
                u.delete()
            }
        }
    }

    private static func syncUsers(users: [JSON]) {
        for f in users {
            let user = User.findOrCreate(["id": f["id"].object]) as! User
            
            if !user.isKindOfClass(Owner) {
                user.name = f["name"].stringValue
                user.nickname = f["nickname"].stringValue
                user.email = f["email"].stringValue
                user.imageUrl = f["image"].stringValue
            }
        }
        print(User.count())
    }

    static func fetchUsers() {
        Router.needToken = true
        
        print("fetchUsers")
        print(OwnerManager.sharedInstance.owner!.accessToken)
        print(OwnerManager.sharedInstance.owner!.client)
        print(OwnerManager.sharedInstance.owner!.uid)
        print("END---fetchUsers")
        
        RouterWrapper.sharedInstance.request(.GetUsers) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .Success:
                OwnerManager.sharedInstance.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    
                    let users = json["users"].arrayValue
                    
                    self.deleteUsers(users)
                    self.syncUsers(users)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
}