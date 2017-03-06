//
//  Calendar+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 13/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


public class Calendar: NSManagedObject {

    static func temporary() -> Calendar {
        let entity = NSEntityDescription.entity(forEntityName: "Calendar", in: DataSync.newContext)
        return Calendar(entity: entity!, insertInto: nil)
    }
}
