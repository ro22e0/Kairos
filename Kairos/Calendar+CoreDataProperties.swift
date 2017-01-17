//
//  Calendar+CoreDataProperties.swift
//  Kairos
//
//  Created by rba3555 on 13/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


extension Calendar {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Calendar> {
        return NSFetchRequest<Calendar>(entityName: "Calendar");
    }

    @NSManaged public var color: String?
    @NSManaged public var id: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var userStatus: String?
    @NSManaged public var event: NSSet?
    @NSManaged public var invitedUsers: NSSet?
    @NSManaged public var owners: NSSet?
    @NSManaged public var participatingUsers: NSSet?
    @NSManaged public var refusedUsers: NSSet?

}

// MARK: Generated accessors for event
extension Calendar {

    @objc(addEventObject:)
    @NSManaged public func addToEvent(_ value: Event)

    @objc(removeEventObject:)
    @NSManaged public func removeFromEvent(_ value: Event)

    @objc(addEvent:)
    @NSManaged public func addToEvent(_ values: NSSet)

    @objc(removeEvent:)
    @NSManaged public func removeFromEvent(_ values: NSSet)

}

// MARK: Generated accessors for invitedUsers
extension Calendar {

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
extension Calendar {

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
extension Calendar {

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
extension Calendar {

    @objc(addRefusedUsersObject:)
    @NSManaged public func addToRefusedUsers(_ value: User)

    @objc(removeRefusedUsersObject:)
    @NSManaged public func removeFromRefusedUsers(_ value: User)

    @objc(addRefusedUsers:)
    @NSManaged public func addToRefusedUsers(_ values: NSSet)

    @objc(removeRefusedUsers:)
    @NSManaged public func removeFromRefusedUsers(_ values: NSSet)

}
