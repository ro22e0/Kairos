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
    static let sharedInstance = UserManager()
    private init() {}
    
    var current: Owner {
        return Owner.all().first as! Owner
    }
    
    private func syncOwner(data: JSON, completionHandler: (CustomStatus) -> Void) {
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
        DataSync.sync(entity: "Owner", predicate: nil, data: [data.dictionaryObject!], completion: { error in
            let defautls = NSUserDefaults.standardUserDefaults()
            defautls.setValue(true, forKey: userLoginKey)
            completionHandler(.Success)
        })
    }
    
    func signIn(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        Router.needToken = false
        RouterWrapper.sharedInstance.request(.Authenticate(parameters)) { (response) in
            switch response.result {
            case .Success:
                self.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    switch response.response!.statusCode {
                    case 200:
                        //                        self.syncOwner(json["data"])
                        //                        let defautls = NSUserDefaults.standardUserDefaults()
                        //                        defautls.setValue(true, forKey: userLoginKey)
                        //                        self.setCredentials(response.response!)
                        //                        completionHandler(.Success)
                        if let owner = Owner.all().first as? Owner {
                            if owner.id != json["data"]["id"].number {
                                DataSync.deleteAll()
                            }
                        }
                        var data: [String: AnyObject] = ["user": json["data"].object]
                        data["id"] = json["data"]["id"].number
                        print(data)
                        DataSync.sync(entity: "Owner", predicate: nil, data: [data], completion: { error in
                            let defautls = NSUserDefaults.standardUserDefaults()
                            defautls.setValue(true, forKey: userLoginKey)
                            try! DataSync.dataStack().mainContext.save()
                            completionHandler(.Success)
                        })
                    default:
                        completionHandler(.Error("Fail to connect"))
                    }
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }
    
    func signUp(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        Router.needToken = false
        
        RouterWrapper.sharedInstance.request(.CreateUser(parameters)) { (response) in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    switch response.response!.statusCode {
                    case 200:
                        if let owner = Owner.all().first as? Owner {
                            if owner.id != json["data"]["id"].number {
                                DataSync.deleteAll()
                            }
                        }
                        var data: [String: AnyObject] = ["user": json["data"].object]
                        data["id"] = json["data"]["id"].number
                        print(data)
                        DataSync.sync(entity: "Owner", predicate: nil, data: [data], completion: { error in
                            let defautls = NSUserDefaults.standardUserDefaults()
                            defautls.setValue(true, forKey: userLoginKey)
                            try! DataSync.dataStack().mainContext.save()
                            completionHandler(.Success)
                        })
                        
                        //                        DataSync.sync(entity: "Owner", predicate: nil, data: [json["data"].dictionaryObject!], completion: { error in
                        //                            let defautls = NSUserDefaults.standardUserDefaults()
                        //                            defautls.setValue(true, forKey: userLoginKey)
                        //                            self.setCredentials(response.response!)
                        //                            completionHandler(.Success)
                    //                            }, all: true)
                    default:
                        completionHandler(.Error("The operation can't be completed"))
                    }
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }
    
    func signOut(completionHandler: (CustomStatus) -> Void) {
        Router.needToken = true
        RouterWrapper.sharedInstance.request(.SignOut) { (response) in
            let defautls = NSUserDefaults.standardUserDefaults()
            defautls.setValue(false, forKey: userLoginKey)
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
    
    func update(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        Router.needToken = true
        RouterWrapper.sharedInstance.request(.UpdateUser(parameters)) { (response) in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let _ = JSON(value)
                    switch response.response!.statusCode {
                    case 200:
                        self.setCredentials(response.response!)
                        completionHandler(.Success)
                    default:
                        completionHandler(.Error("Fail to connect"))
                    }
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }
    
    func setCredentials(response: NSHTTPURLResponse) {
        let defautls = NSUserDefaults.standardUserDefaults()
        defautls.setValue(response.allHeaderFields["access-token"] as? String, forKey: userTokenKey)
        defautls.setValue(response.allHeaderFields["client"] as? String, forKey: userClientKey)
        defautls.setValue(response.allHeaderFields["uid"] as? String, forKey: userUIDKey)
    }
    
    func getCredentials() -> [String: String] {
        let defautls = NSUserDefaults.standardUserDefaults()
        let token = defautls.valueForKey(userTokenKey) as? String
        let client = defautls.valueForKey(userClientKey) as? String
        let uid = defautls.valueForKey(userUIDKey) as? String
        
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
        
        let compoundPred = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [namePred, nicknamePred, emailPred])
        
        if let users = User.query(compoundPred) as? [User] {
            return users
        }
        return [User]()
    }
    
    func fetch(handler: (() -> Void)? = nil) {
        DataSync.fetchUsers { (status) in
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
    
    func getCalendars() -> [Calendar] {
        let calendars = Calendar.all() as! [Calendar]
        
        return calendars
    }
    
    func getEvents() -> [Event] {
        let events = Event.all() as! [Event]
        
        print(events)
        
        return events
    }
    
    func getEvents(forDate date: NSDate) -> [Event] {
        let events = self.getEvents()
        var fEvents = [Event]()
        
        for e in events {
            let dateStart = FSCalendar().dateByIgnoringTimeComponentsOfDate(e.dateStart!)
            let dateEnd = FSCalendar().dateByIgnoringTimeComponentsOfDate(e.dateEnd!)
            
            if (dateStart.compare(date) == .OrderedAscending || dateStart.compare(FSCalendar().dateByIgnoringTimeComponentsOfDate(date)) == .OrderedSame) && (dateEnd.compare(date) == .OrderedDescending || dateEnd.compare(FSCalendar().dateByIgnoringTimeComponentsOfDate(date)) == .OrderedSame) {
                fEvents.append(e)
            }
        }
        
        return fEvents
    }
}