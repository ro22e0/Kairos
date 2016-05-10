//
//  Event.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 21/04/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


class Event: NSManagedObject {

    // MARK: - CoreDataProperties
    
    @NSManaged var endDate: NSDate?
    @NSManaged var location: String?
    @NSManaged var notes: String?
    @NSManaged var startDate: NSDate?
    @NSManaged var title: String?
    @NSManaged var id: NSNumber?
    @NSManaged var calendar: Calendar?
}
