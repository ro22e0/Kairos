//  OwnerManager.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 06/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import FSCalendar

class OwnerManager {
    // MARK: Singleton
    static let sharedInstance = OwnerManager()
    private init() {
        self.owner = Owner.all().first as? Owner
    }
    
    private(set) var owner: Owner?
    
    func setCredentials(response: NSHTTPURLResponse) {
        print("lol")
        let accessToken = response.allHeaderFields["access-token"] as! String
        let client  = response.allHeaderFields["client"] as! String
        let uid = response.allHeaderFields["uid"] as! String
        owner?.uid = uid
        owner?.client = client
        owner?.accessToken = accessToken
        print("setCredentials")
        print(OwnerManager.sharedInstance.owner!.accessToken)
        print(OwnerManager.sharedInstance.owner!.client)
        print(OwnerManager.sharedInstance.owner!.uid)
        print("END---setCredentials")
    }

    func newOwner(owner: Owner) {
//        DataSync.deleteAll()
        self.owner = owner
    }
    
    func getFriends() -> [Friend] {
        let friends = Friend.query("owner == %@", args: self.owner!) as! [Friend]
        
        return friends
    }
    
    func getFriends(withStatus status: FriendStatus) -> [Friend] {
        //let predicate = NSPredicate(format: "owner == %@ AND status == %@", self.owner!, status.hashValue)
        let properties = ["owner": self.owner! as NSManagedObject, "status": status.hashValue]
        let friends = Friend.query(properties) as! [Friend]
        
        return friends
    }
    
    func getUsers() -> [User] {
        let users = User.all() as! [User]

        return users
    }
    
    func getUsers(withName name: String) -> [User] {
        let namePred = NSPredicate(format: "name contains[c] %@", name)
        let nicknamePred = NSPredicate(format: "nickname contains[c] %@", name)
        let emailPred = NSPredicate(format: "email contains[c] %@", name)
        let compoundPred = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [namePred, nicknamePred, emailPred])
        
        let user = Friend.query(compoundPred) as! [User]
        return user
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