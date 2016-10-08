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
 
    @NSManaged var friends: NSSet?
}
