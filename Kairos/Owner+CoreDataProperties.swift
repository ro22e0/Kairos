//
//  Owner+CoreDataProperties.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


extension Owner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Owner> {
        return NSFetchRequest<Owner>(entityName: "Owner");
    }

    @NSManaged public var ownerID: NSNumber?
    @NSManaged public var friends: NSSet?
    @NSManaged public var pendingFriends: NSSet?
    @NSManaged public var requestedFriends: NSSet?
    @NSManaged public var user: User?

}

// MARK: Generated accessors for friends
extension Owner {

    @objc(addFriendsObject:)
    @NSManaged public func addToFriends(_ value: User)

    @objc(removeFriendsObject:)
    @NSManaged public func removeFromFriends(_ value: User)

    @objc(addFriends:)
    @NSManaged public func addToFriends(_ values: NSSet)

    @objc(removeFriends:)
    @NSManaged public func removeFromFriends(_ values: NSSet)

}

// MARK: Generated accessors for pendingFriends
extension Owner {

    @objc(addPendingFriendsObject:)
    @NSManaged public func addToPendingFriends(_ value: User)

    @objc(removePendingFriendsObject:)
    @NSManaged public func removeFromPendingFriends(_ value: User)

    @objc(addPendingFriends:)
    @NSManaged public func addToPendingFriends(_ values: NSSet)

    @objc(removePendingFriends:)
    @NSManaged public func removeFromPendingFriends(_ values: NSSet)

}

// MARK: Generated accessors for requestedFriends
extension Owner {

    @objc(addRequestedFriendsObject:)
    @NSManaged public func addToRequestedFriends(_ value: User)

    @objc(removeRequestedFriendsObject:)
    @NSManaged public func removeFromRequestedFriends(_ value: User)

    @objc(addRequestedFriends:)
    @NSManaged public func addToRequestedFriends(_ values: NSSet)

    @objc(removeRequestedFriends:)
    @NSManaged public func removeFromRequestedFriends(_ values: NSSet)

}
