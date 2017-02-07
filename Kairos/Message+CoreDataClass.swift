//
//  Message+CoreDataClass.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 19/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


public class Message: NSManagedObject {

    static func temporary() -> Message {
        let entity = NSEntityDescription.entity(forEntityName: "Message", in: DataSync.dataStack().mainContext)
        return Message(entity: entity!, insertInto: nil)
    }
}
