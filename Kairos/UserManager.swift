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

class UserManager {
    
    // MARK: Singleton
    static let shared = UserManager()
    fileprivate init() {}
    
    var current: Owner {
        return Owner.all().first as! Owner
    }
    
    fileprivate func syncOwner(_ data: JSON, completionHandler: @escaping (StatusRequest) -> Void) {
        //        if let owner = Owner.all().first as? Owner {
        //            if owner.id != data["id"].number {
        //                DataSync.deleteAll()
        //            }
        //        }
        //        let owner = Owner.findOrCreate(["id": data["id"].number!]) as! Owner
        //
        //        owner.name = data["name"].stringValue
        //        owner.nickname = data["nickname"].stringValue
        //        owner.email = data["email"].stringValue
        //        owner.image = data["image"].rawValue as? NSData
        //        Owner.save()
        if let owner = Owner.all().first as? Owner {
            if owner.id != data["id"].number {
                DataSync.deleteAll()
            }
        }
        print(data)
        DataSync.sync(entity: "Owner", predicate: nil, data: [data.dictionaryObject! as Dictionary<String, Any>], completion: { error in
            let defautls = UserDefaults.standard
            defautls.setValue(true, forKey: userLoginKey)
            completionHandler(.success(nil))
        })
    }
    
    func signIn(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        Router.needToken = false
        RouterWrapper.shared.request(.authenticate(parameters)) { (response) in
            switch response.result {
            case .success:
                self.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    switch response.response!.statusCode {
                    case 200:
                        //                        self.syncOwner(json["data"])
                        //                        let defautls = NSUserDefaults.standardUserDefaults()
                        //                        defautls.setValue(true, forKey: userLoginKey)
                        //                        self.setCredentials(response.response!)
                        //                        completionHandler(.success(nil))
                        if let owner = Owner.all().first as? Owner {
                            if owner.id != json["data"]["id"].number {
                                DataSync.deleteAll()
                            }
                        }
                        var data: [String: Any] = ["user": json["data"].object]
                        data["id"] = json["data"]["id"].number
                        print(data)
                        DataSync.sync(entity: "Owner", predicate: nil, data: [data], completion: { error in
                            let defautls = UserDefaults.standard
                            defautls.setValue(true, forKey: userLoginKey)
                            try! DataSync.dataStack().mainContext.save()
                            completionHandler(.success(nil))
                        })
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
        Router.needToken = false
        
        RouterWrapper.shared.request(.createUser(parameters)) { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    switch response.response!.statusCode {
                    case 200:
                        if let owner = Owner.all().first as? Owner {
                            if owner.id != json["data"]["id"].number {
                                DataSync.deleteAll()
                            }
                        }
                        var data: [String: Any] = ["user": json["data"].object]
                        data["id"] = json["data"]["id"].number
                        print(data)
                        DataSync.sync(entity: "Owner", predicate: nil, data: [data], completion: { error in
                            let defautls = UserDefaults.standard
                            defautls.setValue(true, forKey: userLoginKey)
                            try! DataSync.dataStack().mainContext.save()
                            completionHandler(.success(nil))
                        })
                        
                        //                        DataSync.sync(entity: "Owner", predicate: nil, data: [json["data"].dictionaryObject!], completion: { error in
                        //                            let defautls = NSUserDefaults.standardUserDefaults()
                        //                            defautls.setValue(true, forKey: userLoginKey)
                        //                            self.setCredentials(response.response!)
                        //                            completionHandler(.success(nil))
                    //                            }, all: true)
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
        Router.needToken = true
        RouterWrapper.shared.request(.signOut) { (response) in
            let defautls = UserDefaults.standard
            defautls.setValue(false, forKey: userLoginKey)
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
    
    func update(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        Router.needToken = true
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
    
    func all() -> [User] {
        let users = User.all() as! [User]
        
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
    
    func fetch(_ handler: (() -> Void)? = nil) {
        DataSync.fetchUsers { (status) in
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
    
    func getCalendars() -> [Calendar] {
        let calendars = Calendar.all() as! [Calendar]
        
        return calendars
    }
    
    func getEvents() -> [Event] {
        let events = Event.all() as! [Event]
        
        print(events)
        
        return events
    }
    
    func getEvents(forDate date: Date) -> [Event] {
        let events = self.getEvents()
        var fEvents = [Event]()
        
        for e in events {
            let dateStart = FSCalendar().date(byIgnoringTimeComponentsOf: e.dateStart! as Date)
            let dateEnd = FSCalendar().date(byIgnoringTimeComponentsOf: e.dateEnd! as Date)
            
            if (dateStart.compare(date) == .orderedAscending || dateStart.compare(FSCalendar().date(byIgnoringTimeComponentsOf: date)) == .orderedSame) && (dateEnd.compare(date) == .orderedDescending || dateEnd.compare(FSCalendar().date(byIgnoringTimeComponentsOf: date)) == .orderedSame) {
                fEvents.append(e)
            }
        }
        
        return fEvents
    }
}
