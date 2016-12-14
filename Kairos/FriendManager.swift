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
    
    func all() -> [User] {
        guard let friends = UserManager.sharedInstance.current.friends?.allObjects as? [User],
              let requestedFriends = UserManager.sharedInstance.current.requestedFriends?.allObjects as? [User],
              let pendingFriends = UserManager.sharedInstance.current.pendingFriends?.allObjects as? [User] else {
            return [User]()
        }
        return friends + requestedFriends + pendingFriends
    }

    func friends(withStatus status: FriendStatus = .Accepted) -> [User] {
        if var friends = UserManager.sharedInstance.current.friends?.allObjects as? [User] {
            return friends
        } else {
            return [User]()
        }
    }
    
    func all(filtered text: String, forFriends: Bool = false) -> [User] {
           let namePred = NSPredicate(format: "name contains[c] %@", text)
           let nicknamePred = NSPredicate(format: "nickname contains[c] %@", text)
            let emailPred = NSPredicate(format: "email contains[c] %@", text)

        let compoundPred = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [namePred, nicknamePred, emailPred])
        
        let friends = User.query(compoundPred) as! [User]
        //        user.first?.entity.name
        return friends
    }

    
    func fetch(handler: (() -> Void)? = nil) {
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
        RouterWrapper.sharedInstance.request(.AcceptFriend(parameters)) { (response) in
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
        RouterWrapper.sharedInstance.request(.DeclineFriend(parameters)) { (response) in
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
        RouterWrapper.sharedInstance.request(.RemoveFriend(parameters)) { (response) in
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