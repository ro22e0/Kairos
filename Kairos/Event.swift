//
//  Event.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 14/12/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


class Event: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    @NSManaged var dateEnd: Date?
    @NSManaged var dateStart: Date?
    @NSManaged var id: NSNumber?
    @NSManaged var location: String?
    @NSManaged var notes: String?
    @NSManaged var title: String?
    @NSManaged var userStatus: String?
    @NSManaged var calendar: Calendar?
    @NSManaged var invitedUsers: NSSet?
    @NSManaged var owners: NSSet?
    @NSManaged var participatingUsers: NSSet?
    @NSManaged var refusedUsers: NSSet?
}
