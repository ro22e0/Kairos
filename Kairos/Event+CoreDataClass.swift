//
//  Event+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 13/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import CoreStore
import Arrow

public class Event: NSManagedObject, ImportableUniqueObject {
    
    static func temporary() -> Event {
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: DataSync.newContext)
        return Event(entity: entity!, insertInto: nil)
    }
    
    public typealias ImportSource = ArrowJSON
    public class var uniqueIDKeyPath: String {
        return "eventID"
    }
    public var uniqueIDValue: NSNumber {
        get { return self.eventID! }
        set { self.eventID = newValue }
    }
    
    public func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        
        self.dateEnd = dateFormatter.date(from: source["date_end"]!.data! as! String) as NSDate?
        self.dateStart = dateFormatter.date(from: source["date_start"]!.data! as! String) as NSDate?
        self.eventID <-- source["id"]
        self.location <-- source["location"]
        self.notes <-- source["description"]
        self.title <-- source["title"]
        self.userStatus <-- source["user_status"]
        //        self.calendar: Calendar?
        
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
