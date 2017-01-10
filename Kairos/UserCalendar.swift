//
//  UserCalendar.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 16/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


class UserCalendar: NSManagedObject {

    // MARK: - CoreDataProperties

    @NSManaged var calendarId: NSNumber?
    @NSManaged var isOwner: NSNumber?
    @NSManaged var isSelected: NSNumber?
    @NSManaged var status: String?
    @NSManaged var userId: NSNumber?
    @NSManaged var calendar: Calendar?
    @NSManaged var user: User?
}
