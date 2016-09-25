//
//  Owner.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 06/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


class Owner: User {

    // MARK: - CoreDataProperties
 
    @NSManaged var accessToken: String?
    @NSManaged var client: String?
    @NSManaged var provider: String?
    @NSManaged var uid: String?
    @NSManaged var friends: NSSet?
}
