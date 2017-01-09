//
//  User.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 14/12/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    @NSManaged var company: String?
    @NSManaged var email: String?
    @NSManaged var id: NSNumber?
    @NSManaged var image: NSData?
    @NSManaged var imageUrl: String?
    @NSManaged var job: String?
    @NSManaged var location: String?
    @NSManaged var name: String?
    @NSManaged var nickname: String?
    @NSManaged var promotion: String?
    @NSManaged var provider: String?
    @NSManaged var school: String?
    @NSManaged var mutualFriends: NSSet?
}
