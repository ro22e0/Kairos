//
//  Owner+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 13/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


public class Owner: NSManagedObject {
    
    static func temporary() -> Owner {
        let entity = NSEntityDescription.entity(forEntityName: "Owner", in: DataSync.dataStack().mainContext)
        return Owner(entity: entity!, insertInto: nil)
    }
}
