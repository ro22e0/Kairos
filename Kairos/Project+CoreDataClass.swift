//
//  Project+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import CoreStore
import Arrow

@objc(Project)
public class Project: NSManagedObject, ImportableUniqueObject {

    static func temporary() -> Project {
        let entity = NSEntityDescription.entity(forEntityName: "Project", in: DataSync.newContext)
        return Project(entity: entity!, insertInto: nil)
    }

    public typealias ImportSource = ArrowJSON
    public class var uniqueIDKeyPath: String {
        return "projectID"
    }
    public var uniqueIDValue: NSNumber {
        get { return self.projectID! }
        set { self.projectID = newValue }
    }
    
    public func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)

        self.dateEnd = Date.from(string: source["date_end"]!.data! as! String) as NSDate?
        self.dateStart = Date.from(string: source["date_start"]!.data! as! String) as NSDate?
        self.projectID <-- source["id"]
        self.notes <-- source["description"]
        self.title <-- source["title"]
        self.userStatus <-- source["user_status"]

        if let tasksSource = source["tasks"]?.collection {
            let importedTasks = try transaction.importUniqueObjects(Into<Task>(), sourceArray: tasksSource)
            self.tasks = NSSet(array: importedTasks)
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
