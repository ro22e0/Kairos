//
//  Task+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import CoreStore
import Arrow

@objc(Task)
public class Task: NSManagedObject, ImportableUniqueObject {
    
    static func temporary() -> Task {
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: DataSync.newContext)
        return Task(entity: entity!, insertInto: nil)
    }
    
    public typealias ImportSource = ArrowJSON
    public class var uniqueIDKeyPath: String {
        return "taskID"
    }
    public var uniqueIDValue: NSNumber {
        get { return self.taskID! }
        set { self.taskID = newValue }
    }
    
    public func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)

        self.dateEnd = Date.from(string: source["date_end"]!.data! as! String) as NSDate?
        self.dateStart = Date.from(string: source["date_start"]!.data! as! String) as NSDate?
        self.taskID <-- source["id"]
        self.notes <-- source["description"]
        self.title <-- source["title"]
        
        if let usersSource = source["users"]?.collection {
            let importedUsers = try transaction.importUniqueObjects(Into<User>(), sourceArray: usersSource)
            users = NSSet(array: importedUsers)
        }
        if let projectID = source["project_id"], let projectSource = ArrowJSON(["id": projectID]) {
            try self.project = transaction.importUniqueObject(Into<Project>(), source: projectSource)
        }
        if let parentID = source["parent_id"], let parentSource = ArrowJSON(["id": parentID]) {
            try self.parent = transaction.importUniqueObject(Into<Task>(), source: parentSource)
        }
        if let childsSource = source["child_tasks"]?.collection {
            let importedChilds = try transaction.importUniqueObjects(Into<Task>(), sourceArray: childsSource)
            self.childTasks = NSSet(array: importedChilds)
        }
    }
    
    public static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> NSNumber? {
        return source["id"]?.data as? NSNumber
    }
    
    public func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
    }
}
