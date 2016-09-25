//
//  RequestManager.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 25/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import SwiftyJSON

class RequestManager {
    
    class func fetchFriends() {
        Router.needToken = true
        RouterWrapper.sharedInstance.request(.GetFriends) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .Success:
                OwnerManager.sharedInstance.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    print(json)
                    
                    let friends = DataSync.transformJson(json["friends"])
                    print(friends)
                    
                    let requested = DataSync.transformJson(json["friend_requests"])
                    print(requested)
                    
                    let pending = DataSync.transformJson(json["pending_requests"])
                    print(requested)
                    
                    for var f in friends {
                        f["status"] = FriendStatus.Accepted.hashValue
                    }
                    for var f in requested {
                        f["status"] = FriendStatus.Requested.hashValue
                    }
                    for var f in pending {
                        f["status"] = FriendStatus.Pending.hashValue
                    }

                    DataSync.sync(entity: "Friend", data: friends, completion: { error in
                        print(NSDate(), "done")
                    })
                    DataSync.sync(entity: "Friend", data: requested, completion: { error in
                        print(NSDate(), "done")
                    })
                    DataSync.sync(entity: "Friend", data: pending, completion: { error in
                        print(NSDate(), "done")
                    })
                    
                }
            case .Failure(let error):
                print(error)
            }
            print(NSDate(), "done")
            print(Friend.all().count)
        }
    }
    
    class func fetchUsers() {
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

                    let data = DataSync.transformJson(json)

                    DataSync.sync(entity: "User", data: data, completion: { error in
                        print(NSDate(), "done")
                    })
                }
            case .Failure(let error):
                print(error)
            }
        }
    }

}