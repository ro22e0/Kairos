//
//  User+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 13/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import CoreStore
import SwiftyJSON
import Arrow

public class User: NSManagedObject, ImportableUniqueObject {
    
    public typealias ImportSource = ArrowJSON
    public class var uniqueIDKeyPath: String {
        return "userID"
    }
    public var uniqueIDValue: NSNumber {
        get { return self.userID! }
        set { self.userID = newValue }
    }
    
    //public func shouldInsert(from source: Dictionary<String, Any>, in transaction: BaseDataTransaction) -> Bool {
    //
    //}
    
    public func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
        //                self.userID = source["id"].number
        //                self.provider = source["provider"].string
        //        self.name = source["name"].string
        //
        //                    self.email = source["email"].string
        
        self.userID <-- source["id"]
        self.provider <-- source["provider"]
        self.name <-- source["name"]
        self.nickname <-- source["nickname"]
        self.image <-- source["image"]
        self.email <-- source["email"]
        self.school <-- source["school"]
        self.promotion <-- source["promotion"]
        self.location <-- source["location"]
        self.company <-- source["company"]
        self.job <-- source["job"]
        
        if let mutualFriendsSource = source["mutual_friends"]?.collection {
            let importedMutualFriends = try transaction.importUniqueObjects(Into<User>(), sourceArray: mutualFriendsSource)
            //            self.mutualFriends?.addingObjects(from: mutualFriends)
            let mutualFriendsSet = NSSet().addingObjects(from: importedMutualFriends)
            print(importedMutualFriends)
            self.mutualFriends = mutualFriendsSet as NSSet?
        }
        
        //        if let arrowSource = ArrowJSON(source) {
        //            self.userID <-- arrowSource["id"]
        //            self.provider <-- arrowSource["provider"]
        //            self.name <-- arrowSource["name"]
        //            self.nickname <-- arrowSource["nickname"]
        //            self.image <-- arrowSource["image"]
        //            self.email <-- arrowSource["email"]
        //            self.school <-- arrowSource["school"]
        //            self.promotion <-- arrowSource["promotion"]
        //            self.location <-- arrowSource["location"]
        //            self.company <-- arrowSource["company"]
        //            self.job <-- arrowSource["job"]
        //
        //            let mutualFriends = try transaction.importUniqueObjects(Into<User>(), sourceArray: source["mutual_friends"].arrayValue)
        //            self.mutualFriends?.addingObjects(from: mutualFriends)
        //        }
        //        self.mutualFriends <-- source["mutual_friends"]
        
        
        //        if let mutualFriendsSource = source["mutual_friends"]?.collection {
        //            let mutualFriends = try transaction.importUniqueObjects(Into<User>(), sourceArray: mutualFriendsSource)
        //            self.mutualFriends?.addingObjects(from: mutualFriends)
        //        }
        //        self.calendars
        //        self.chatRooms
        //        self.events
        //        self.friends
        //        self.invitedCalendars
        //        self.invitedEvents
        //        self.invitedProjects
        //        self.ownedCalendars
        //        self.ownedEvents
        //        self.ownedProjects
        //        self.owner
        //        self.pendingFriends
        //        self.projects
        //        self.refusedCalendars
        //        self.refusedEvents
        //        self.refusedProjects
        //        self.requestedFriends
        //        self.sentMessages
        //        self.tasks
    }
    
    public static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> NSNumber? {
        return source["id"]?.data as? NSNumber
    }
    
    public func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
    }
}
