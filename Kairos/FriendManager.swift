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
    static let shared = FriendManager()
    fileprivate init() {}
    
    func all() -> [User] {
        guard let friends = UserManager.shared.current.friends?.allObjects as? [User],
            let requestedFriends = UserManager.shared.current.requestedFriends?.allObjects as? [User],
            let pendingFriends = UserManager.shared.current.pendingFriends?.allObjects as? [User] else {
                return [User]()
        }
        return friends + requestedFriends + pendingFriends
    }
    
    func friends(withStatus status: FriendStatus = .Accepted) -> [User] {
        var friends: [User]?

        switch status {
        case .Accepted:
            friends = UserManager.shared.current.friends?.allObjects as? [User]
        case .Pending:
            friends = UserManager.shared.current.pendingFriends?.allObjects as? [User]
        case .Requested:
            friends = UserManager.shared.current.requestedFriends?.allObjects as? [User]
        }
        return friends != nil ? friends! : [User]()
    }
    
    func all(filtered text: String) -> [User] {
        let namePred = NSPredicate(format: "name contains[c] %@", text)
        let nicknamePred = NSPredicate(format: "nickname contains[c] %@", text)
        let emailPred = NSPredicate(format: "email contains[c] %@", text)
        
        let compoundPred = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [namePred, nicknamePred, emailPred])
        
        guard let friends = UserManager.shared.current.friends?.allObjects as? [User],
            let requestedFriends = UserManager.shared.current.requestedFriends?.allObjects as? [User],
            let pendingFriends = UserManager.shared.current.pendingFriends?.allObjects as? [User] else {
                return [User]()
        }
        let friendsArr = friends + requestedFriends + pendingFriends
        
        if let allFriends = (friendsArr as NSArray).filtered(using: compoundPred) as? [User] {
            return allFriends
        }
        return [User]()
    }
    
    func friendsToAdd(filtered text:String) -> [User] {
        let currentUser = UserManager.shared.current
        let friends = self.all()
        var ids = [NSNumber]()

        for f in friends {
            ids.append(f.id!)
        }

        let namePred = NSPredicate(format: "name contains[c] %@ AND self != %@ AND NOT (id IN %@)", text, currentUser, ids)
        let nicknamePred = NSPredicate(format: "nickname contains[c] %@ AND self != %@ AND NOT (id IN %@)", text, currentUser, ids)
        let emailPred = NSPredicate(format: "email contains[c] %@ AND self != %@ AND NOT (id IN %@)", text, currentUser, ids)
        let compoundPred = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [namePred, nicknamePred, emailPred])
        
        if let users = User.query(compoundPred) as? [User] {
            return users
        }
        return [User]()
    }
    
    func fetch(_ handler: (() -> Void)? = nil) {
        DataSync.fetchFriends { (status) in
            switch status {
            case .success:
                if handler != nil {
                    handler!()
                }
            case .error(let error):
                print(error)
            }
        }
    }
    
    func invite(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.inviteFriend(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.success(nil))
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func cancel(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.cancelFriend(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.success(nil))
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func accept(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.acceptFriend(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.success(nil))
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func refuse(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.declineFriend(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.success(nil))
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func remove(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.removeFriend(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.success(nil))
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
}
