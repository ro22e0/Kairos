//
//  Friend.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 06/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


class Friend: User {

    // MARK: - CoreDataProperties

    @NSManaged var status: NSNumber?
    @NSManaged var owner: Owner?
}
