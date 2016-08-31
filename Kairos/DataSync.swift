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

struct DataSync {
    
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
            friend.imageUrl = f["image"].stringValue
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
                    
                    let accepted = json["friends"].arrayValue
                    let blocked = json["blocked_friends"].arrayValue
                    let requested = json["requested_friends"].arrayValue
                    let pending = json["pending_friends"].arrayValue
                    
                    let friends = accepted + blocked + requested + pending
                    self.deleteFriends(friends)
                    self.syncFriends(accepted, status: .Accepted)
                    self.syncFriends(blocked, status: .Blocked)
                    self.syncFriends(requested, status: .Requested)
                    self.syncFriends(pending, status: .Pending)
                }
            case .Failure(let error):
                print(error)
            }
            print(NSDate(), "done")
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
                user.imageUrl = u["image"].stringValue
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
                    
                    self.deleteUsers(json.arrayValue)
                    self.syncUsers(json.arrayValue)
                }
            case .Failure(let error):
                print(error)
            }
            print(NSDate(), "done")
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
                    print("fetch calendar")
                    let json = JSON(value)
                    
                    print(json.arrayValue)
                    
                    self.deleteCalendars(json.arrayValue)
                    self.syncCalendars(json.arrayValue)
                }
            case .Failure(let error):
                print(error)
            }
            print(NSDate(), "done")
            self.fetchEvents()
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
            
            let event = Event.findOrCreate(["id": e["id"].object]) as! Event
            
            event.title = e["title"].stringValue
            event.startDate = dateStart
            event.endDate = dateEnd
            event.location = e["location"].stringValue
            event.notes = e["description"].stringValue
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
                    print("fetch events")
                    let json = JSON(value)
                    
                    print(json)
                    
                    self.deleteEvents(json.arrayValue)
                    self.syncEvents(json.arrayValue)
                }
            case .Failure(let error):
                print(error)
            }
            print(NSDate(), "done")
        }
    }
    
}