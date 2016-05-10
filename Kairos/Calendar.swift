//
//  Calendar.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 21/04/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


class Calendar: NSManagedObject {

    // MARK: - CoreDataProperties
    
    @NSManaged var name: String?
    @NSManaged var id: NSNumber?
    @NSManaged var events: NSSet?
    @NSManaged var owner: Owner?
}
