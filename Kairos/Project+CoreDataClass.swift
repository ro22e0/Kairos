//
//  Project+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData

@objc(Project)
public class Project: NSManagedObject {

    static func temporary() -> Project {
        let entity = NSEntityDescription.entity(forEntityName: "Project", in: DataSync.dataStack().mainContext)
        return Project(entity: entity!, insertInto: nil)
    }

}
