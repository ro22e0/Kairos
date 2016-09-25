//
//  User.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 06/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {

    // MARK: - CoreDataProperties
    
    @NSManaged var company: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var email: String?
    @NSManaged var id: NSNumber?
    @NSManaged var image: String?
    @NSManaged var job: String?
    @NSManaged var location: String?
    @NSManaged var name: String?
    @NSManaged var nickname: String?
    @NSManaged var promotion: String?
    @NSManaged var school: String?
    @NSManaged var updatedAt: NSDate?
    @NSManaged var userCalendars: UserCalendar?
    @NSManaged var userEvents: NSManagedObject?
}
