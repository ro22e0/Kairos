//
//  User+CoreDataProperties.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 15/03/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var company: String?
    @NSManaged public var email: String?
    @NSManaged public var image: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var job: String?
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var nickname: String?
    @NSManaged public var promotion: String?
    @NSManaged public var provider: String?
    @NSManaged public var school: String?
    @NSManaged public var userID: NSNumber?
    @NSManaged public var calendars: NSSet?
    @NSManaged public var chatRooms: NSSet?
    @NSManaged public var events: NSSet?
    @NSManaged public var friends: NSSet?
    @NSManaged public var invitedCalendars: NSSet?
    @NSManaged public var invitedEvents: NSSet?
    @NSManaged public var invitedProjects: NSSet?
    @NSManaged public var mutualFriends: NSSet?
    @NSManaged public var ownedCalendars: NSSet?
    @NSManaged public var ownedEvents: NSSet?
    @NSManaged public var ownedProjects: NSSet?
    @NSManaged public var owner: Owner?
    @NSManaged public var pendingFriends: NSSet?
    @NSManaged public var projects: NSSet?
    @NSManaged public var refusedCalendars: NSSet?
    @NSManaged public var refusedEvents: NSSet?
    @NSManaged public var refusedProjects: NSSet?
    @NSManaged public var requestedFriends: NSSet?
    @NSManaged public var sentMessages: NSSet?
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for calendars
extension User {

    @objc(addCalendarsObject:)
    @NSManaged public func addToCalendars(_ value: Calendar)

    @objc(removeCalendarsObject:)
    @NSManaged public func removeFromCalendars(_ value: Calendar)

    @objc(addCalendars:)
    @NSManaged public func addToCalendars(_ values: NSSet)

    @objc(removeCalendars:)
    @NSManaged public func removeFromCalendars(_ values: NSSet)

}

// MARK: Generated accessors for chatRooms
extension User {

    @objc(addChatRoomsObject:)
    @NSManaged public func addToChatRooms(_ value: ChatRoom)

    @objc(removeChatRoomsObject:)
    @NSManaged public func removeFromChatRooms(_ value: ChatRoom)

    @objc(addChatRooms:)
    @NSManaged public func addToChatRooms(_ values: NSSet)

    @objc(removeChatRooms:)
    @NSManaged public func removeFromChatRooms(_ values: NSSet)

}

// MARK: Generated accessors for events
extension User {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: Event)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: Event)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}

// MARK: Generated accessors for friends
extension User {

    @objc(addFriendsObject:)
    @NSManaged public func addToFriends(_ value: Owner)

    @objc(removeFriendsObject:)
    @NSManaged public func removeFromFriends(_ value: Owner)

    @objc(addFriends:)
    @NSManaged public func addToFriends(_ values: NSSet)

    @objc(removeFriends:)
    @NSManaged public func removeFromFriends(_ values: NSSet)

}

// MARK: Generated accessors for invitedCalendars
extension User {

    @objc(addInvitedCalendarsObject:)
    @NSManaged public func addToInvitedCalendars(_ value: Calendar)

    @objc(removeInvitedCalendarsObject:)
    @NSManaged public func removeFromInvitedCalendars(_ value: Calendar)

    @objc(addInvitedCalendars:)
    @NSManaged public func addToInvitedCalendars(_ values: NSSet)

    @objc(removeInvitedCalendars:)
    @NSManaged public func removeFromInvitedCalendars(_ values: NSSet)

}

// MARK: Generated accessors for invitedEvents
extension User {

    @objc(addInvitedEventsObject:)
    @NSManaged public func addToInvitedEvents(_ value: Event)

    @objc(removeInvitedEventsObject:)
    @NSManaged public func removeFromInvitedEvents(_ value: Event)

    @objc(addInvitedEvents:)
    @NSManaged public func addToInvitedEvents(_ values: NSSet)

    @objc(removeInvitedEvents:)
    @NSManaged public func removeFromInvitedEvents(_ values: NSSet)

}

// MARK: Generated accessors for invitedProjects
extension User {

    @objc(addInvitedProjectsObject:)
    @NSManaged public func addToInvitedProjects(_ value: Project)

    @objc(removeInvitedProjectsObject:)
    @NSManaged public func removeFromInvitedProjects(_ value: Project)

    @objc(addInvitedProjects:)
    @NSManaged public func addToInvitedProjects(_ values: NSSet)

    @objc(removeInvitedProjects:)
    @NSManaged public func removeFromInvitedProjects(_ values: NSSet)

}

// MARK: Generated accessors for mutualFriends
extension User {

    @objc(addMutualFriendsObject:)
    @NSManaged public func addToMutualFriends(_ value: User)

    @objc(removeMutualFriendsObject:)
    @NSManaged public func removeFromMutualFriends(_ value: User)

    @objc(addMutualFriends:)
    @NSManaged public func addToMutualFriends(_ values: NSSet)

    @objc(removeMutualFriends:)
    @NSManaged public func removeFromMutualFriends(_ values: NSSet)

}

// MARK: Generated accessors for ownedCalendars
extension User {

    @objc(addOwnedCalendarsObject:)
    @NSManaged public func addToOwnedCalendars(_ value: Calendar)

    @objc(removeOwnedCalendarsObject:)
    @NSManaged public func removeFromOwnedCalendars(_ value: Calendar)

    @objc(addOwnedCalendars:)
    @NSManaged public func addToOwnedCalendars(_ values: NSSet)

    @objc(removeOwnedCalendars:)
    @NSManaged public func removeFromOwnedCalendars(_ values: NSSet)

}

// MARK: Generated accessors for ownedEvents
extension User {

    @objc(addOwnedEventsObject:)
    @NSManaged public func addToOwnedEvents(_ value: Event)

    @objc(removeOwnedEventsObject:)
    @NSManaged public func removeFromOwnedEvents(_ value: Event)

    @objc(addOwnedEvents:)
    @NSManaged public func addToOwnedEvents(_ values: NSSet)

    @objc(removeOwnedEvents:)
    @NSManaged public func removeFromOwnedEvents(_ values: NSSet)

}

// MARK: Generated accessors for ownedProjects
extension User {

    @objc(addOwnedProjectsObject:)
    @NSManaged public func addToOwnedProjects(_ value: Project)

    @objc(removeOwnedProjectsObject:)
    @NSManaged public func removeFromOwnedProjects(_ value: Project)

    @objc(addOwnedProjects:)
    @NSManaged public func addToOwnedProjects(_ values: NSSet)

    @objc(removeOwnedProjects:)
    @NSManaged public func removeFromOwnedProjects(_ values: NSSet)

}

// MARK: Generated accessors for pendingFriends
extension User {

    @objc(addPendingFriendsObject:)
    @NSManaged public func addToPendingFriends(_ value: Owner)

    @objc(removePendingFriendsObject:)
    @NSManaged public func removeFromPendingFriends(_ value: Owner)

    @objc(addPendingFriends:)
    @NSManaged public func addToPendingFriends(_ values: NSSet)

    @objc(removePendingFriends:)
    @NSManaged public func removeFromPendingFriends(_ values: NSSet)

}

// MARK: Generated accessors for projects
extension User {

    @objc(addProjectsObject:)
    @NSManaged public func addToProjects(_ value: Project)

    @objc(removeProjectsObject:)
    @NSManaged public func removeFromProjects(_ value: Project)

    @objc(addProjects:)
    @NSManaged public func addToProjects(_ values: NSSet)

    @objc(removeProjects:)
    @NSManaged public func removeFromProjects(_ values: NSSet)

}

// MARK: Generated accessors for refusedCalendars
extension User {

    @objc(addRefusedCalendarsObject:)
    @NSManaged public func addToRefusedCalendars(_ value: Calendar)

    @objc(removeRefusedCalendarsObject:)
    @NSManaged public func removeFromRefusedCalendars(_ value: Calendar)

    @objc(addRefusedCalendars:)
    @NSManaged public func addToRefusedCalendars(_ values: NSSet)

    @objc(removeRefusedCalendars:)
    @NSManaged public func removeFromRefusedCalendars(_ values: NSSet)

}

// MARK: Generated accessors for refusedEvents
extension User {

    @objc(addRefusedEventsObject:)
    @NSManaged public func addToRefusedEvents(_ value: Event)

    @objc(removeRefusedEventsObject:)
    @NSManaged public func removeFromRefusedEvents(_ value: Event)

    @objc(addRefusedEvents:)
    @NSManaged public func addToRefusedEvents(_ values: NSSet)

    @objc(removeRefusedEvents:)
    @NSManaged public func removeFromRefusedEvents(_ values: NSSet)

}

// MARK: Generated accessors for refusedProjects
extension User {

    @objc(addRefusedProjectsObject:)
    @NSManaged public func addToRefusedProjects(_ value: Project)

    @objc(removeRefusedProjectsObject:)
    @NSManaged public func removeFromRefusedProjects(_ value: Project)

    @objc(addRefusedProjects:)
    @NSManaged public func addToRefusedProjects(_ values: NSSet)

    @objc(removeRefusedProjects:)
    @NSManaged public func removeFromRefusedProjects(_ values: NSSet)

}

// MARK: Generated accessors for requestedFriends
extension User {

    @objc(addRequestedFriendsObject:)
    @NSManaged public func addToRequestedFriends(_ value: Owner)

    @objc(removeRequestedFriendsObject:)
    @NSManaged public func removeFromRequestedFriends(_ value: Owner)

    @objc(addRequestedFriends:)
    @NSManaged public func addToRequestedFriends(_ values: NSSet)

    @objc(removeRequestedFriends:)
    @NSManaged public func removeFromRequestedFriends(_ values: NSSet)

}

// MARK: Generated accessors for sentMessages
extension User {

    @objc(addSentMessagesObject:)
    @NSManaged public func addToSentMessages(_ value: Message)

    @objc(removeSentMessagesObject:)
    @NSManaged public func removeFromSentMessages(_ value: Message)

    @objc(addSentMessages:)
    @NSManaged public func addToSentMessages(_ values: NSSet)

    @objc(removeSentMessages:)
    @NSManaged public func removeFromSentMessages(_ values: NSSet)

}

// MARK: Generated accessors for tasks
extension User {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}
