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
import DATAFilter

struct DataSync {
    
    static func dataStack() -> DATAStack {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        return delegate.dataStack
    }
    
    static func sync(entity entityName: String, data: [[String: AnyObject]], completion: ((NSError?) -> Void), withDelete: Bool = false) {
        let ops: DATAFilter.Operation = withDelete ? [.Insert, .Update, .Delete] : [.Insert, .Update]
        Sync.changes(data, inEntityNamed: entityName, dataStack: self.dataStack(), operations: ops, completion: completion)
    }
    
    private static func transformJson(json: JSON) -> [[String: AnyObject]] {
        var data = [[String: AnyObject]]()
        
        for elem in json.array! {
            if let dict = elem.dictionaryObject {
                data.append(dict)
            }
        }
        return data
    }
    
    static func deleteAll() {
        Event.deleteAll()
        Calendar.deleteAll()
        Friend.deleteAll()
    }
    
    // MARK: - Friends
    
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
            friend.image = f["image"].stringValue
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
                    
                    print(json)
                    
                    //                    var accepted = json["friends"]
                    //                    print(accepted)
                    //                    var requested = json["requested_friends"]
                    //                    print(requested)
                    //                    var pending = json["pending_friends"].dictionaryObject
                    //                    print(pending)
                    //                    accepted!["status"] = FriendStatus.Accepted.hashValue
                    //                    requested!["status"] = FriendStatus.Requested.hashValue
                    //                    pending!["status"] = FriendStatus.Pending.hashValue
                    //
                    //                    self.sync(entity: "Friend", data: [accepted!], completion: { error in
                    //                        print(NSDate(), "done")
                    //                    })
                    //                    self.sync(entity: "Friend", data: [requested!], completion: { error in
                    //                        print(NSDate(), "done")
                    //                    })
                    //                    self.sync(entity: "Friend", data: pending!, completion: { error in
                    //                        print(NSDate(), "done")
                    //                    })
                }
            case .Failure(let error):
                print(error)
            }
            print(NSDate(), "done")
            print(Friend.all().count)
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
            u.delete()
        }
    }
    
    private static func syncUsers(users: [JSON]) {
        for u in users {
            print("OWNER:  ", Owner.all())
            print("FRIENDS:  ", Friend.all())
            print("User id : ", u["id"])
            print("Friend id : ", Friend.find("id == %@", args: u["id"].stringValue))
            print("Owner id : ", Owner.find("id == %@", args: u["id"].stringValue))
            
            if Owner.find("id == %@", args: u["id"].stringValue) == nil && Friend.find("id == %@", args: u["id"].stringValue) == nil {
                let user = User.findOrCreate(["id": u["id"].object]) as! User
                user.name = u["name"].stringValue
                user.nickname = u["nickname"].stringValue
                user.email = u["email"].stringValue
                user.image = u["image"].stringValue
            }
        }
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
                    
                    let data = self.transformJson(json)
                    
                    self.sync(entity: "User", data: data, completion: { error in
                        print(NSDate(), "done")
                    })
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Calendar
    
    private static func deleteCalendars(calendars: [JSON]) {
        let ids = NSMutableArray()
        
        for c in calendars {
            ids.addObject(c["id"].object)
        }
        
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedCalendars = Calendar.query(predicate) as! [Calendar]
        for c in deletedCalendars {
            c.delete()
        }
    }
    
    private static func syncCalendars(calendars: [JSON]) {
        print(calendars)
        for c in calendars {
            print("YEAH : ", c["name"])
            let calendar = Calendar.findOrCreate(["id": c["id"].object]) as! Calendar
            calendar.name = c["name"].stringValue
            print(calendar.id)
            print(calendar.name)
            calendar.save()
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
    
    static func fetchCalendars() {
        Router.needToken = true
        
        print(OwnerManager.sharedInstance.owner!.accessToken)
        print(OwnerManager.sharedInstance.owner!.client)
        print(OwnerManager.sharedInstance.owner!.uid)
        
        RouterWrapper.sharedInstance.request(.GetCalendars) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .Success:
                OwnerManager.sharedInstance.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    print(json)
                    
                    deleteObject(json.array!, query: Calendar.query)
                    
                    let completion: ((NSError?) -> Void) = { error in
                        print(NSDate(), "done")
                        
                        for c in json.array! {
                            var data = [[String : AnyObject]]()
                            data += c["refused_users"].object as! [[String : AnyObject]]
                            data += c["participating_users"].object as! [[String : AnyObject]]
                            data += c["invited_users"].object as! [[String : AnyObject]]
                            data += c["owners"].object as! [[String : AnyObject]]
                            
                            self.sync(entity: "User", data: data, completion: { error in
                                print(NSDate(), "done")
                            })
                        }
                    }
                    self.sync(entity: "Calendar", data: json.object as! [[String : AnyObject]], completion: completion, withDelete: true)
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
        
        print(OwnerManager.sharedInstance.owner!.accessToken)
        print(OwnerManager.sharedInstance.owner!.client)
        print(OwnerManager.sharedInstance.owner!.uid)
        
        RouterWrapper.sharedInstance.request(.GetEvents) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .Success:
                
                OwnerManager.sharedInstance.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    print(json)
                    
                    self.sync(entity: "Event", data: json.object as! [[String : AnyObject]], completion: { error in
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