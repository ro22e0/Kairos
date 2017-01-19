//
//  Task+CoreDataProperties.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task");
    }

    @NSManaged public var id: NSNumber?
    @NSManaged public var title: String?
    @NSManaged public var dateStart: NSDate?
    @NSManaged public var dateEnd: NSDate?
    @NSManaged public var notes: String?
    @NSManaged public var parent: Task?
    @NSManaged public var childTasks: NSSet?
    @NSManaged public var users: NSSet?
    @NSManaged public var project: Project?

}

// MARK: Generated accessors for childTasks
extension Task {

    @objc(addChildTasksObject:)
    @NSManaged public func addToChildTasks(_ value: Task)

    @objc(removeChildTasksObject:)
    @NSManaged public func removeFromChildTasks(_ value: Task)

    @objc(addChildTasks:)
    @NSManaged public func addToChildTasks(_ values: NSSet)

    @objc(removeChildTasks:)
    @NSManaged public func removeFromChildTasks(_ values: NSSet)

}

// MARK: Generated accessors for users
extension Task {

    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: User)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: User)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)

}
