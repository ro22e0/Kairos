//  UserManager.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 06/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import FSCalendar
import Alamofire
import SwiftyJSON
//import MagicalRecord
import CoreStore

class UserManager {
    
    // MARK: Singleton
    static let shared = UserManager()
    fileprivate init() {}
    
    var current: Owner = Owner.temporary()
    
    fileprivate func syncOwner(_ data: JSON, completionHandler: @escaping (StatusRequest) -> Void) {
        if let owner = Owner.all().first as? Owner {
            if owner.ownerID != data["id"].number {
                DataSync.deleteAll()
            }
        }
        print(data)
        //        MagicalRecord.saveInBackground({ (localContext) in
        //            Owner.mr_import(from: [data.dictionaryObject! as [String: Any]])
        //        }, completion: {
        //            print("finish")
        //            let defautls = UserDefaults.standard
        //            defautls.setValue(true, forKey: userLoginKey)
        //            completionHandler(.success(nil))
        //        })
    }
    
    func signIn(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.authenticate(parameters)) { (response) in
            switch response.result {
            case .success:
                self.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    switch response.response!.statusCode {
                    case 200:
                        var data: [String: Any] = ["user": json["data"].object]
                        data["id"] = json["data"]["id"].number
                        print(data)
                        
                        CoreStore.beginAsynchronous({ (transaction) in
                            do {
                                try _ = transaction.importUniqueObject(
                                    Into<Owner>(),
                                    source: data
                                )
                            }
                            catch {
                                return // Woops, don't save
                            }
                            transaction.commit({ (result) in
                                switch result {
                                case .success(let hasChanges):
                                    print("success!", hasChanges)
                                case .failure(let error):
                                    print(error)
                                }
                            })
                        })
                        //                        MagicalRecord.saveInBackground({ (localContext) in
                        //                            Owner.mr_import(from: data, in: localContext)
                        ////                            Owner.mr_import(from: [data], in: localContext)
                        //                        }, completion: {
                        //                            print("finish")
                        //                            let defautls = UserDefaults.standard
                        //                            defautls.setValue(true, forKey: userLoginKey)
                        ////                            self.current = Owner.mr_findAll()?.first as! Owner
                        //                            completionHandler(.success(nil))
                    //                        })
                    default:
                        completionHandler(.error("Fail to connect"))
                    }
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func signUp(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.createUser(parameters)) { (response) in
            switch response.result {
            case .success:
                self.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    switch response.response!.statusCode {
                    case 200:
                        //                        if let owner = Owner.all().first as? Owner {
                        //                            if owner.id != json["data"]["id"].number {
                        //                                DataSync.deleteAll()
                        //                            }
                        //                        }
                        var data: [String: Any] = ["user": json["data"].object]
                        data["id"] = json["data"]["id"].number
                        print(data)
                        //                        MagicalRecord.saveInBackground({ (localContext) in
                        //                            Owner.mr_import(from: [data], in: localContext)
                        //                        }, completion: {
                        //                            print("finish")
                        //                            let defautls = UserDefaults.standard
                        //                            defautls.setValue(true, forKey: userLoginKey)
                        //                            self.current = Owner.all().first as! Owner
                        //                            completionHandler(.success(nil))
                    //                        })
                    default:
                        completionHandler(.error("The operation can't be completed"))
                    }
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func signOut(_ completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.signOut) { (response) in
            let defautls = UserDefaults.standard
            defautls.setValue(false, forKey: userLoginKey)
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    DataSync.deleteAll()
                    completionHandler(.success(nil))
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func update(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.updateUser(parameters)) { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let _ = JSON(value)
                    switch response.response!.statusCode {
                    case 200:
                        self.setCredentials(response.response!)
                        completionHandler(.success(nil))
                    default:
                        completionHandler(.error("Fail to connect"))
                    }
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func setCredentials(_ response: HTTPURLResponse) {
        let defautls = UserDefaults.standard
        defautls.setValue(response.allHeaderFields["access-token"] as? String, forKey: userTokenKey)
        defautls.setValue(response.allHeaderFields["client"] as? String, forKey: userClientKey)
        defautls.setValue(response.allHeaderFields["uid"] as? String, forKey: userUIDKey)
    }
    
    func getCredentials() -> [String: String] {
        let defautls = UserDefaults.standard
        let token = defautls.value(forKey: userTokenKey) as? String
        let client = defautls.value(forKey: userClientKey) as? String
        let uid = defautls.value(forKey: userUIDKey) as? String
        
        return ["access-token": token!, "client": client!, "uid": uid!]
    }
    
    func all(excludeFriends: Bool = false) -> [User] {
        var users = [User]()
        
        if excludeFriends {
            let format = "friends.@count == 0 AND owner == %@"
                + "AND pendingFriends.@count == 0 AND requestedFriends.@count == 0"
            let predicate = NSPredicate(format: format, 0)
            users = User.query(predicate) as! [User]
        } else {
            users = User.all() as! [User]
        }
        return users
    }
    
    func all(filtered text: String) -> [User] {
        let namePred = NSPredicate(format: "name contains[c] %@ AND self != %@", text, self.current)
        let nicknamePred = NSPredicate(format: "nickname contains[c] %@ AND self != %@", text, self.current)
        let emailPred = NSPredicate(format: "email contains[c] %@ AND self != %@", text, self.current)
        
        let compoundPred = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [namePred, nicknamePred, emailPred])
        
        if let users = User.query(compoundPred) as? [User] {
            return users
        }
        return [User]()
    }
    
    func filtered(users: [User], with text:String) -> [User] {
        let namePred = NSPredicate(format: "name contains[c] %@", text)
        let nicknamePred = NSPredicate(format: "nickname contains[c] %@", text)
        let emailPred = NSPredicate(format: "email contains[c] %@", text)
        let compoundPred = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [namePred, nicknamePred, emailPred])
        let filteredUsers = users.filter({ compoundPred.evaluate(with: $0) })
        return filteredUsers
    }
    
    
    func fetch(_ handler: (() -> Void)? = nil) {
        DataSync.fetchUsers { (status) in
            switch status {
            case .success:
                if handler != nil {
                    RequestManager.default.serializationQueue.addOperation(handler!)
                }
            case .error(let error):
                print(error)
            }
        }
    }
    
    func fetchAll(_ handler: @escaping (() -> Void)) {
        self.fetch() {
            handler()
        }
        //        FriendManager.shared.fetch()
        //        DataSync.fetchCalendarColors()
        //        CalendarManager.shared.fetch()
        //        EventManager.shared.fetch()
        //        ProjectManager.shared.fetch()
        //        TaskManager.shared.fetch()
        //        ChatRoomManager.shared.fetch() {
        //            let chatRooms = ChatRoomManager.shared.chatRooms()
        //            for chatRoom in chatRooms {
        //                ChatRoomManager.shared.listen(for: chatRoom)
        //            }
        //        }
        //        RequestManager.default.serializationQueue.addOperation(handler)
    }
    
    func getCalendars() -> [Calendar] {
        let calendars = Calendar.all() as! [Calendar]
        
        return calendars
    }
    
    func getEvents() -> [Event] {
        let events = Event.all() as! [Event]
        
        print(events)
        
        return events
    }
}
