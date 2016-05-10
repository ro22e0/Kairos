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
    
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var nickname: String?
    @NSManaged var imageUrl: NSData?
    @NSManaged var email: String?
    @NSManaged var image: String?
}
