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
    
    @NSManaged var createdAt: NSDate?
    @NSManaged var dateEnd: NSDate?
    @NSManaged var dateStart: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var location: String?
    @NSManaged var notes: String?
    @NSManaged var title: String?
    @NSManaged var updatedAt: NSDate?
    @NSManaged var calendar: Calendar?
    @NSManaged var eventUsers: UserEvent?
}
