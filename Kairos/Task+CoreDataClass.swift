//
//  Task+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {
    
    static func temporary() -> Task {
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: DataSync.newContext)
        return Task(entity: entity!, insertInto: nil)
    }
}
