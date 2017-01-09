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
import Sync
import DATAStack

struct DataSync {
    
    static func dataStack() -> DATAStack {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        return delegate.dataStack
    }
    
    static func sync(entity entityName: String, predicate: NSPredicate?, data: [[String: AnyObject]], completion: ((NSError?) -> Void), all: Bool = false) {
        let ops: DATAFilter.Operation = all ? [.All] : [.Insert, .Update]
        if predicate != nil {
            Sync.changes(data, inEntityNamed: entityName, predicate: predicate, dataStack: self.dataStack(), operations: ops, completion: completion)
        } else {
            Sync.changes(data, inEntityNamed: entityName, dataStack: self.dataStack(), operations: ops, completion: completion)
        }
    }
    
    static func transformJson(json: JSON) -> [[String: AnyObject]] {
        var data = [[String: AnyObject]]()
        
        for elem in json.array! {
            if let dict = elem.dictionaryObject {
                data.append(dict)
            }
        }
        return data
    }
    
    static func deleteAll() {
        Owner.deleteAll()
        Event.deleteAll()
        Calendar.deleteAll()
        User.deleteAll()
        UserCalendar.deleteAll()
        UserEvent.deleteAll()
    }
    
    // MARK: - Friends
    
    private static func deleteFriends(friends: [JSON]) {
        let ids = NSMutableArray()
        
        for f in friends {
            ids.addObject(f["id"].object)
        }
        
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedFriends = User.query(predicate) as! [User]
        for f in deletedFriends {
            f.delete()
        }
    }
    
    //    private static func syncFriends(friends: [JSON]) {
    //        for f in friends {
    //            let friend = User.findOrCreate(["id": f["id"].object]) as! User
    //
    //            friend.name = f["name"].stringValue
    //            friend.nickname = f["nickname"].stringValue
    //            friend.status = f["status"].stringValue
    //            friend.email = f["email"].stringValue
    //            friend.image = f["image"].stringValue
    //            friend.owner = UserManager.sharedInstance.current
    //        }
    //        User.save()
    //        print(User.count())
    //    }
    
    static func fetchFriends(completionHandler: (CustomStatus) -> Void) {
        Router.needToken = true
        RouterWrapper.sharedInstance.request(.GetFriends) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .Success:
                UserManager.sharedInstance.setCredentials(response.response!)
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        print(json)
                        
                        var data: [String: AnyObject] = json.dictionaryObject!
                        data["id"] = UserManager.sharedInstance.current.id
                        print(data)
                        DataSync.sync(entity: "Owner", predicate: nil, data: [data], completion: { error in
                            try! self.dataStack().mainContext.save()
                            print(NSDate(), "done")
                            completionHandler(.Success)
                        })
                        
                        //                        var friends = [JSON]()
                        
                        //
                        //                        let requested = DataSync.transformJson()
                        //                        print(requested)
                        //
                        //                        let pending = DataSync.transformJson()
                        //                        print(requested)
                        //                        for var f in friendsArray {
                        //                            f["owner"].number = UserManager.sharedInstance.current.id
                        //                            friends.append(f)
                        //                        }
                        
                        //                        for var f in requested {
                        //                            f["status"] = FriendStatus.Requested.hashValue
                        //                            f["owner"] = UserManager.sharedInstance.current
                        //                        }
                        //                        for var f in pending {
                        //                            f["status"] = FriendStatus.Pending.hashValue
                        //                            f["owner"] = UserManager.sharedInstance.current
                        //                        }
                        
                        //                        self.deleteFriends(friends)
                        //                        self.syncFriends(friends)
                        //                        completionHandler(CustomStatus.Success)
                        
                        
                        //                        let pred = NSPredicate(format: "self.isKindOfClass %@", User)
                        //                        DataSync.sync(entity: "User", predicate: nil, data: friends, completion: { error in
                        //                            print(NSDate(), "done", true)
                        //                            completionHandler(.Success)
                        //                            })
                        //                        DataSync.sync(entity: "User", data: requested, completion: { error in
                        //                            print(NSDate(), "done")
                        //                            completionHandler(.Success)
                        //                        })
                        //                        DataSync.sync(entity: "User", data: pending, completion: { error in
                        //                            print(NSDate(), "done")
                        //                            completionHandler(.Success)
                        //                        })
                    }
                default:
                    completionHandler(CustomStatus.Error("error"))
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }
    
    // MARK: - Users
    
    private static func deleteUsers(users: [JSON]) {
        let ids = NSMutableArray()
        
        for u in users {
            ids.addObject(u["id"].object)
        }
        
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedUsers = User.query(predicate) as! [User]
        for u in deletedUsers {
            let friendExist = User.find("id == %@", args: u.id!) != nil ? true : false
            let ownerExist = Owner.find("id == %@", args: u.id!) != nil ? true : false
            
            if (!friendExist && !ownerExist) {
                u.delete()
            }
        }
    }
    
    private static func syncUsers(users: [JSON]) {
        for u in users {
            print("OWNER:  ", Owner.all())
            print("FRIENDS:  ", User.all())
            print("User id : ", u["id"])
            print("User id : ", User.find("id == %@", args: u["id"].stringValue))
            print("Owner id : ", Owner.find("id == %@", args: u["id"].stringValue))
            
            let friendExist = User.find("id == %@", args: u["id"].stringValue) != nil ? true : false
            let ownerExist = Owner.find("id == %@", args: u["id"].stringValue) != nil ? true : false
            
            if (!friendExist && !ownerExist) {
                let user = User.findOrCreate(["id": u["id"].object]) as! User
                user.name = u["name"].stringValue
                user.nickname = u["nickname"].stringValue
                user.email = u["email"].stringValue
                user.image = u["image"].rawValue as? NSData
            }
        }
        User.save()
    }
    
    static func fetchUsers(completionHandler: (CustomStatus) -> Void) {
        Router.needToken = true
        RouterWrapper.sharedInstance.request(.GetUsers) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .Success:
                UserManager.sharedInstance.setCredentials(response.response!)
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json)
                        //                        let data = self.transformJson(json)
                        //                        let users = json.array!
                        //
                        //                        self.deleteUsers(users)
                        //                        self.syncUsers(users)
                        //                        completionHandler(CustomStatus.Success)
                        let predicate = NSPredicate(format: "id <> %@", UserManager.sharedInstance.current.id!)
                        self.sync(entity: "User", predicate: nil, data: DataSync.transformJson(json), completion: { error in
                            try! self.dataStack().mainContext.save()
                            completionHandler(CustomStatus.Success)
                        })

                        //                        let pred = NSPredicate(format: "id != %@", UserManager.sharedInstance.current.id!)
                        //                        self.sync(entity: "User", predicate: nil, data: data, completion: { error in
                        //                            completionHandler(CustomStatus.Success)
                        //                        })
                    }
                default:
                    completionHandler(CustomStatus.Error("error"))
                }
            case .Failure(let error):
                completionHandler(CustomStatus.Error(error.localizedDescription))
                print(error)
            }
        }
    }
    
    // MARK: - Calendar
    
    private static func deleteCalendars(calendars: [JSON]) {
        let ids = NSMutableArray()
        let id: Int?
        
        for c in calendars {
            ids.addObject(c["id"].object)
        }
        
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedCalendars = Calendar.query(predicate) as! [Calendar]
        for c in deletedCalendars {
            c.delete()
        }
    }
    
    private static func deleteObject(data: [JSON], query: (AnyObject, AnyObject...) -> [NSManagedObject]) {
        let ids = NSMutableArray()
        
        for elem in data {
            ids.addObject(elem["id"].object)
        }
        
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedObjects = query(predicate)
        for o in deletedObjects {
            o.delete()
        }
    }
    
    private static func syncUserCalendar(calendar: Calendar, users: [JSON]) {
        for u in users {
            guard let user = User.find("id == %@", args: u["id"].number!) as? User else {
                return
            }
            if let uCalendar = UserCalendar.findOrCreate(["userId": user.id!, "calendarId": calendar.id!]) as? UserCalendar {
                uCalendar.status = u["status"].string!
                uCalendar.isOwner = u["status"].string! == UserStatus.Owner.rawValue
                uCalendar.calendar = calendar
                uCalendar.user = user
                uCalendar.isSelected = true
            }
        }
    }
    
    static func syncCalendars(calendars: [JSON]) {
        print(calendars)
        for c in calendars {
            print("YEAH : ", c["name"])
            let calendar = Calendar.findOrCreate(["id": c["id"].object]) as! Calendar
            calendar.name = c["name"].stringValue
            calendar.color = c["color"].string
            
            var users = c["owners"].array! + c["participating_users"].array!
            users += c["refused_users"].array! + c["invited_users"].array!
            syncUserCalendar(calendar, users: users)
            
            print(calendar.id)
            print(calendar.name)
        }
        Calendar.save()
    }
    
    static func fetchCalendars(completionHandler: (CustomStatus) -> Void) {
        Router.needToken = true
        
        RouterWrapper.sharedInstance.request(.GetCalendars) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .Success:
                UserManager.sharedInstance.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value).array!
                    
                    print(json)
                    //                    deleteObject(json.array!, query: Calendar.query)
                    
                    self.syncCalendars(json)
                    completionHandler(.Success)
                    
                    //                    let completion: ((NSError?) -> Void) = { error in
                    //                        print(NSDate(), "done")
                    //
                    //                        for c in json.array! {
                    //                            var data = [[String : AnyObject]]()
                    //                            data += c["refused_users"].object as! [[String : AnyObject]]
                    //                            data += c["participating_users"].object as! [[String : AnyObject]]
                    //                            data += c["invited_users"].object as! [[String : AnyObject]]
                    //                            data += c["owners"].object as! [[String : AnyObject]]
                    //
                    //                            self.sync(entity: "User", predicate: nil, data: data, completion: { error in
                    //                                print(NSDate(), "done")
                    //                            })
                    //                        }
                    //                    }
                    //                    self.sync(entity: "Calendar", predicate: nil, data: json.object as! [[String : AnyObject]], completion: completion)
                }
            case .Failure(let error):
                completionHandler(.Error("error"))
                print(error)
            }
        }
    }
    
    static func fetchCalendarColors() {
        Router.needToken = true
        
        RouterWrapper.sharedInstance.request(.GetCalendarColors) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .Success:
                UserManager.sharedInstance.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value).dictionaryObject as! [String: String]
                    print(json)
                    CalendarManager.sharedInstance.colors = json
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Events
    private static func deleteEvents(events: [JSON]) {
        let ids = NSMutableArray()
        
        for e in events {
            ids.addObject(e["id"].object)
        }
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedEvents = Event.query(predicate) as! [Event]
        for e in deletedEvents {
            e.delete()
        }
    }
    
    private static func syncEvents(events: [JSON]) {
        for e in events {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let dateStart = dateFormatter.dateFromString(e["date_start"].stringValue)
            let dateEnd = dateFormatter.dateFromString(e["date_end"].stringValue)
            let calendar = Calendar.find("id == %@", args: e["calendar_id"].stringValue) as? Calendar
            
            print(e["calendar_id"].stringValue)
            print(e["id"].stringValue)
            
            let event = Event.findOrCreate(["id": e["id"].stringValue]) as! Event
            
            event.title = e["title"].stringValue
            event.dateStart = dateStart
            event.dateEnd = dateEnd
            event.location = e["location"].stringValue
            event.notes = e["description"].stringValue
            print(Calendar.all().first)
            event.calendar = calendar!
        }
    }
    
    static func fetchEvents() {
        Router.needToken = true
        
        RouterWrapper.sharedInstance.request(.GetEvents) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .Success:
                UserManager.sharedInstance.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    self.sync(entity: "Event", predicate: nil, data: json.object as! [[String : AnyObject]], completion: { error in
                        print(NSDate(), "done")
                    })
                }
            case .Failure(let error):
                print(error)
            }
            print(NSDate(), "done")
        }
    }
    
}
