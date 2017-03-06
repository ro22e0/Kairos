//
//  ChatRoom+CoreDataClass.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 19/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData


public class ChatRoom: NSManagedObject {

    static func temporary() -> ChatRoom {
        let entity = NSEntityDescription.entity(forEntityName: "ChatRoom", in: DataSync.newContext)
        return ChatRoom(entity: entity!, insertInto: nil)
    }
}
