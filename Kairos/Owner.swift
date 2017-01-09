//
//  Owner.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 14/12/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


class Owner: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    @NSManaged var id: NSNumber?
    @NSManaged var friends: NSSet?
    @NSManaged var pendingFriends: NSSet?
    @NSManaged var requestedFriends: NSSet?
    @NSManaged var user: User?
}
