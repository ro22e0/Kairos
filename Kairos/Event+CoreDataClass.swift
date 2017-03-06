//
//  Event+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 13/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


public class Event: NSManagedObject {

    static func temporary() -> Event {
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: DataSync.newContext)
        return Event(entity: entity!, insertInto: nil)
    }
}
