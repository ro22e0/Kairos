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
    
    func all() -> [Friend] {
        let friends = Friend.query("owner == %@", args: UserManager.sharedInstance.current) as! [Friend]
        
        return friends
    }
    
    func friends(withStatus status: FriendStatus = .Accepted) -> [Friend] {
        //let predicate = NSPredicate(format: "owner == %@ AND status == %@", self.current, status.hashValue)
        let properties = ["owner": UserManager.sharedInstance.current as NSManagedObject, "status": status.hashValue]
        let friends = Friend.query(properties) as! [Friend]
        
        return friends
    }
    
    func fetch(handler: (() -> Void)?) {
        DataSync.fetchFriends { (status) in
            switch status {
            case .Success:
                if handler != nil {
                    handler!()
                }
            case .Error(let error):
                print(error)
            }
        }
    }

    func invite(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        RouterWrapper.sharedInstance.request(.InviteFriend(parameters)) { (response) in
        switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.Success)
                default:
                    completionHandler(.Error("kFail"))
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }
    
    func cancel(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        RouterWrapper.sharedInstance.request(.CancelFriend(parameters)) { (response) in
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.Success)
                default:
                    completionHandler(.Error("kFail"))
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }
    
    func accept(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        RouterWrapper.sharedInstance.request(.InviteFriend(parameters)) { (response) in
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.Success)
                default:
                    completionHandler(.Error("kFail"))
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }
    
    func refuse(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        RouterWrapper.sharedInstance.request(.InviteFriend(parameters)) { (response) in
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.Success)
                default:
                    completionHandler(.Error("kFail"))
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }
    
    func remove(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        RouterWrapper.sharedInstance.request(.InviteFriend(parameters)) { (response) in
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.Success)
                default:
                    completionHandler(.Error("kFail"))
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }
}