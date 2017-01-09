//
//  Calendar.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 14/12/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


class Calendar: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    @NSManaged var color: String?
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var userStatus: String?
    @NSManaged var event: NSSet?
    @NSManaged var invitedUsers: NSSet?
    @NSManaged var owners: NSSet?
    @NSManaged var participatingUsers: NSSet?
    @NSManaged var refusedUsers: NSSet?
}
