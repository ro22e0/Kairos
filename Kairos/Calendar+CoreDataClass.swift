//
//  Calendar+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 13/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import CoreStore
import Arrow

public class Calendar: NSManagedObject, ImportableUniqueObject {

    static func temporary() -> Calendar {
        let entity = NSEntityDescription.entity(forEntityName: "Calendar", in: DataSync.newContext)
        return Calendar(entity: entity!, insertInto: nil)
    }
    
    public typealias ImportSource = ArrowJSON
    public class var uniqueIDKeyPath: String {
        return "calendarID"
    }
    public var uniqueIDValue: NSNumber {
        get { return self.calendarID! }
        set { self.calendarID = newValue }
    }
    
    public func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)

        self.calendarID <-- source["id"]
        self.name <-- source["name"]
        self.color <-- source["color"]
        self.userStatus <-- source["user_status"]

        if let eventsSource = source["events"]?.collection {
            let importedEvents = try transaction.importUniqueObjects(Into<Event>(), sourceArray: eventsSource)
            self.events = NSSet(array: importedEvents)
        }
        
        if let ownersSource = source["owners"]?.collection {
            let importedOwners = try transaction.importUniqueObjects(Into<User>(), sourceArray: ownersSource)
            self.owners = NSSet(array: importedOwners)
        }
        if let invitedUsersSource = source["invited_users"]?.collection {
            let importedInvitedUsers = try transaction.importUniqueObjects(Into<User>(), sourceArray: invitedUsersSource)
            self.invitedUsers = NSSet(array: importedInvitedUsers)
        }
        if let participatingUsersSource = source["participating_users"]?.collection {
            let importedParticipatingUsers = try transaction.importUniqueObjects(Into<User>(), sourceArray: participatingUsersSource)
            self.participatingUsers = NSSet(array: importedParticipatingUsers)
        }
        if let refusedUsersSource = source["refused_users"]?.collection {
            let importedRefusedUsers = try transaction.importUniqueObjects(Into<User>(), sourceArray: refusedUsersSource)
            self.refusedUsers = NSSet(array: importedRefusedUsers)
        }
        
        //        self.provider <-- source["provider"]
//        self.nickname <-- source["nickname"]
//        self.image <-- source["image"]
//        self.email <-- source["email"]
//        self.school <-- source["school"]
//        self.promotion <-- source["promotion"]
//        self.location <-- source["location"]
//        self.company <-- source["company"]
//        self.job <-- source["job"]
//
    }
    
    public static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> NSNumber? {
        return source["id"]?.data as? NSNumber
    }
    
    public func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
    }

}
