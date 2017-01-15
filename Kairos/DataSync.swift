//
//  DataSync.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 11/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import SwiftRecord
import DATAStack
import Sync

struct DataSync {
    
    static func dataStack() -> DATAStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        return delegate.dataStack
    }
    
    static func sync(entity entityName: String, predicate: NSPredicate?, data: [[String: Any]], completion: @escaping ((NSError?) -> Void), all: Bool = false) {
        let ops: Sync.OperationOptions = all ? [.All] : [.Insert, .Update]
        if predicate != nil {
            Sync.changes(data, inEntityNamed: entityName, predicate: predicate, dataStack: self.dataStack(), operations: ops, completion: completion)
        } else {
            Sync.changes(data, inEntityNamed: entityName, dataStack: self.dataStack(), operations: ops, completion: completion)
        }
    }
    
    static func transformJson(_ json: JSON) -> [[String: Any]] {
        var data = [[String: Any]]()
        
        for elem in json.array! {
            if let dict = elem.dictionaryObject {
                data.append(dict as [String : Any])
            }
        }
        return data
    }
    
    static func deleteAll() {
        Owner.deleteAll()
        Event.deleteAll()
        Calendar.deleteAll()
        User.deleteAll()
        Calendar.deleteAll()
        Event.deleteAll()
    }
    
    // MARK: - Friends
    
    fileprivate static func deleteFriends(_ friends: [JSON]) {
        let ids = NSMutableArray()
        
        for f in friends {
            ids.add(f["id"].object)
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
    //            friend.owner = UserManager.shared.current
    //        }
    //        User.save()
    //        print(User.count())
    //    }
    
    static func fetchFriends(_ completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.getFriends) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        print(json)
                        
                        var data: [String: Any] = json.dictionaryObject!
                        data["id"] = UserManager.shared.current.id
                        print(data)
                        DataSync.sync(entity: "Owner", predicate: nil, data: [data], completion: { error in
                            try! self.dataStack().mainContext.save()
                            print(NSDate(), "done")
                            completionHandler(.success(nil))
                        })
                        
                        //                        var friends = [JSON]()
                        
                        //
                        //                        let requested = DataSync.transformJson()
                        //                        print(requested)
                        //
                        //                        let pending = DataSync.transformJson()
                        //                        print(requested)
                        //                        for var f in friendsArray {
                        //                            f["owner"].number = UserManager.shared.current.id
                        //                            friends.append(f)
                        //                        }
                        
                        //                        for var f in requested {
                        //                            f["status"] = FriendStatus.Requested.hashValue
                        //                            f["owner"] = UserManager.shared.current
                        //                        }
                        //                        for var f in pending {
                        //                            f["status"] = FriendStatus.Pending.hashValue
                        //                            f["owner"] = UserManager.shared.current
                        //                        }
                        
                        //                        self.deleteFriends(friends)
                        //                        self.syncFriends(friends)
                        //                        completionHandler(StatusRequest.success(nil))
                        
                        
                        //                        let pred = NSPredicate(format: "self.isKindOfClass %@", User)
                        //                        DataSync.sync(entity: "User", predicate: nil, data: friends, completion: { error in
                        //                            print(NSDate(), "done", true)
                        //                            completionHandler(.success(nil))
                        //                            })
                        //                        DataSync.sync(entity: "User", data: requested, completion: { error in
                        //                            print(NSDate(), "done")
                        //                            completionHandler(.success(nil))
                        //                        })
                        //                        DataSync.sync(entity: "User", data: pending, completion: { error in
                        //                            print(NSDate(), "done")
                        //                            completionHandler(.success(nil))
                        //                        })
                    }
                default:
                    completionHandler(.error("error"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    // MARK: - Users
    
    fileprivate static func deleteUsers(_ users: [JSON]) {
        let ids = NSMutableArray()
        
        for u in users {
            ids.add(u["id"].object)
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
    
    fileprivate static func syncUsers(_ users: [JSON]) {
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
    
    static func fetchUsers(_ completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.getUsers) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
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
                        //                        completionHandler(StatusRequest.success(nil))
                        let predicate = NSPredicate(format: "id <> %@", UserManager.shared.current.id!)
                        self.sync(entity: "User", predicate: nil, data: DataSync.transformJson(json), completion: { error in
                            try! self.dataStack().mainContext.save()
                            completionHandler(StatusRequest.success(nil))
                        })
                        
                        //                        let pred = NSPredicate(format: "id != %@", UserManager.shared.current.id!)
                        //                        self.sync(entity: "User", predicate: nil, data: data, completion: { error in
                        //                            completionHandler(StatusRequest.success(nil))
                        //                        })
                    }
                default:
                    completionHandler(.error("error"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
                print(error)
            }
        }
    }
    
    // MARK: - Calendar
    
    fileprivate static func deleteCalendars(_ calendars: [JSON]) {
        let ids = NSMutableArray()
        let id: Int?
        
        for c in calendars {
            ids.add(c["id"].object)
        }
        
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedCalendars = Calendar.query(predicate) as! [Calendar]
        for c in deletedCalendars {
            c.delete()
        }
    }
    
    fileprivate static func deleteObject(_ data: [JSON], query: (Any, Any...) -> [NSManagedObject]) {
        let ids = NSMutableArray()
        
        for elem in data {
            ids.add(elem["id"].object)
        }
        
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedObjects = query(predicate)
        for o in deletedObjects {
            o.delete()
        }
    }
    
    fileprivate static func syncUserCalendar(_ calendar: Calendar, users: [JSON]) {
        //        for u in users {
        //            guard let user = User.find("id == %@", args: u["id"].number!) as? User else {
        //                return
        //            }
        //            if let uCalendar = Calendar.findOrCreate(["userId": user.id!, "calendarId": calendar.id!]) as? Calendar {
        //                uCalendar.status = u["status"].string!
        ////                uCalendar.isOwner = (u["status"].stringValue == UserStatus.Owner.rawValue)
        //                uCalendar.calendar = calendar
        //                uCalendar.user = user
        //                uCalendar.isSelected = true
        //            }
        //        }
    }
    
    static func syncCalendars(_ json: JSON, completionHandler: @escaping ()->()) {
        //        print(calendars)
        //        for c in calendars {
        //            print("YEAH : ", c["name"])
        //            let calendar = Calendar.findOrCreate(["id": c["id"].object]) as! Calendar
        //            calendar.name = c["name"].stringValue
        //            calendar.color = c["color"].string
        //
        //            var users = c["owners"].array! + c["participating_users"].array!
        //            users += c["refused_users"].array! + c["invited_users"].array!
        //            syncUserCalendar(calendar, users: users)
        //
        //            print(calendar.id)
        //            print(calendar.name)
        //        }
        //        Calendar.save()
        let data = json.dictionaryObject
        DataSync.sync(entity: "Calendar", predicate: nil, data: [data!], completion: { error in
  //          try! self.dataStack().mainContext.save()
            let c = Calendar.all().first as! Calendar
            print(c)
            print(NSDate(), "done")
            completionHandler()
        })
    }
    
    static func fetchCalendars(_ completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.getCalendars) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    print(json)
                    
                    let data = DataSync.transformJson(json)
                    DataSync.sync(entity: "Calendar", predicate: nil, data: data, completion: { error in
                        try! self.dataStack().mainContext.save()
                        let c = Calendar.all().first as! Calendar
                        print(c)
                        print(NSDate(), "done")
                        completionHandler(.success(nil))
                    })
                    
                    //                    deleteObject(json.array!, query: Calendar.query)
                    
                    //                    self.syncCalendars(json)
                    //                    completionHandler(.success(nil))
                    
                    //                    let completion: ((NSError?) -> Void) = { error in
                    //                        print(NSDate(), "done")
                    //
                    //                        for c in json.array! {
                    //                            var data = [[String : Any]]()
                    //                            data += c["refused_users"].object as! [[String : Any]]
                    //                            data += c["participating_users"].object as! [[String : Any]]
                    //                            data += c["invited_users"].object as! [[String : Any]]
                    //                            data += c["owners"].object as! [[String : Any]]
                    //
                    //                            self.sync(entity: "User", predicate: nil, data: data, completion: { error in
                    //                                print(NSDate(), "done")
                    //                            })
                    //                        }
                    //                    }
                    //                    self.sync(entity: "Calendar", predicate: nil, data: json.object as! [[String : Any]], completion: completion)
                }
            case .failure(let error):
                completionHandler(.error("error"))
                print(error)
            }
        }
    }
    
    static func fetchCalendarColors() {
        RouterWrapper.shared.request(.getCalendarColors) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value).dictionaryObject as! [String: String]
                    print(json)
                    CalendarManager.shared.colors = json
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Events
    fileprivate static func deleteEvents(_ events: [JSON]) {
        let ids = NSMutableArray()
        
        for e in events {
            ids.add(e["id"].object)
        }
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedEvents = Event.query(predicate) as! [Event]
        for e in deletedEvents {
            e.delete()
        }
    }
    
    fileprivate static func syncEvents(_ events: [JSON]) {
        for e in events {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let dateStart = dateFormatter.date(from: e["date_start"].stringValue)
            let dateEnd = dateFormatter.date(from: e["date_end"].stringValue)
            let calendar = Calendar.find("id == %@", args: e["calendar_id"].stringValue) as? Calendar
            
            print(e["calendar_id"].stringValue)
            print(e["id"].stringValue)
            
            let event = Event.findOrCreate(["id": e["id"].stringValue]) as! Event
            
            event.title = e["title"].stringValue
            event.dateStart = dateStart as NSDate?
            event.dateEnd = dateEnd as NSDate?
            event.location = e["location"].stringValue
            event.notes = e["description"].stringValue
            print(Calendar.all().first)
            event.calendar = calendar!
        }
    }
    
    static func fetchEvents() {
        RouterWrapper.shared.request(.getEvents) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    self.sync(entity: "Event", predicate: nil, data: json.object as! [[String : Any]], completion: { error in
                        print(NSDate(), "done")
                    })
                }
            case .failure(let error):
                print(error)
            }
            print(NSDate(), "done")
        }
    }
    
}
