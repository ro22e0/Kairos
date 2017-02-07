//
//  Message+CoreDataProperties.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 19/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message");
    }

    @NSManaged public var id: NSNumber?
    @NSManaged public var body: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var user: User?
    @NSManaged public var chatRoom: ChatRoom?

}
