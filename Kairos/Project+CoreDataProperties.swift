//
//  Project+CoreDataProperties.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 15/03/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project");
    }

    @NSManaged public var dateEnd: NSDate?
    @NSManaged public var dateStart: NSDate?
    @NSManaged public var notes: String?
    @NSManaged public var projectID: NSNumber?
    @NSManaged public var title: String?
    @NSManaged public var userStatus: String?
    @NSManaged public var invitedUsers: NSSet?
    @NSManaged public var owners: NSSet?
    @NSManaged public var participatingUsers: NSSet?
    @NSManaged public var refusedUsers: NSSet?
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for invitedUsers
extension Project {

    @objc(addInvitedUsersObject:)
    @NSManaged public func addToInvitedUsers(_ value: User)

    @objc(removeInvitedUsersObject:)
    @NSManaged public func removeFromInvitedUsers(_ value: User)

    @objc(addInvitedUsers:)
    @NSManaged public func addToInvitedUsers(_ values: NSSet)

    @objc(removeInvitedUsers:)
    @NSManaged public func removeFromInvitedUsers(_ values: NSSet)

}

// MARK: Generated accessors for owners
extension Project {

    @objc(addOwnersObject:)
    @NSManaged public func addToOwners(_ value: User)

    @objc(removeOwnersObject:)
    @NSManaged public func removeFromOwners(_ value: User)

    @objc(addOwners:)
    @NSManaged public func addToOwners(_ values: NSSet)

    @objc(removeOwners:)
    @NSManaged public func removeFromOwners(_ values: NSSet)

}

// MARK: Generated accessors for participatingUsers
extension Project {

    @objc(addParticipatingUsersObject:)
    @NSManaged public func addToParticipatingUsers(_ value: User)

    @objc(removeParticipatingUsersObject:)
    @NSManaged public func removeFromParticipatingUsers(_ value: User)

    @objc(addParticipatingUsers:)
    @NSManaged public func addToParticipatingUsers(_ values: NSSet)

    @objc(removeParticipatingUsers:)
    @NSManaged public func removeFromParticipatingUsers(_ values: NSSet)

}

// MARK: Generated accessors for refusedUsers
extension Project {

    @objc(addRefusedUsersObject:)
    @NSManaged public func addToRefusedUsers(_ value: User)

    @objc(removeRefusedUsersObject:)
    @NSManaged public func removeFromRefusedUsers(_ value: User)

    @objc(addRefusedUsers:)
    @NSManaged public func addToRefusedUsers(_ values: NSSet)

    @objc(removeRefusedUsers:)
    @NSManaged public func removeFromRefusedUsers(_ values: NSSet)

}

// MARK: Generated accessors for tasks
extension Project {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}
