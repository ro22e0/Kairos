//
//  UserEvent.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 16/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


class UserEvent: NSManagedObject {

    // MARK: - CoreDataProperties

    @NSManaged var status: NSNumber?
    @NSManaged var user: User?
    @NSManaged var event: Event?
}
