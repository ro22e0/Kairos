//
//  Event+CoreDataProperties.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 15/03/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event");
    }

    @NSManaged public var dateEnd: NSDate?
    @NSManaged public var dateStart: NSDate?
    @NSManaged public var eventID: NSNumber?
    @NSManaged public var location: String?
    @NSManaged public var notes: String?
    @NSManaged public var title: String?
    @NSManaged public var userStatus: String?
    @NSManaged public var calendar: Calendar?
    @NSManaged public var invitedUsers: NSSet?
    @NSManaged public var owners: NSSet?
    @NSManaged public var participatingUsers: NSSet?
    @NSManaged public var refusedUsers: NSSet?

}

// MARK: Generated accessors for invitedUsers
extension Event {

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
extension Event {

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
extension Event {

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
extension Event {

    @objc(addRefusedUsersObject:)
    @NSManaged public func addToRefusedUsers(_ value: User)

    @objc(removeRefusedUsersObject:)
    @NSManaged public func removeFromRefusedUsers(_ value: User)

    @objc(addRefusedUsers:)
    @NSManaged public func addToRefusedUsers(_ values: NSSet)

    @objc(removeRefusedUsers:)
    @NSManaged public func removeFromRefusedUsers(_ values: NSSet)

}
