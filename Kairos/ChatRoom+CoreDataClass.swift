//
//  ChatRoom+CoreDataClass.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 19/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import CoreStore
import Arrow

public class ChatRoom: NSManagedObject, ImportableUniqueObject {

    static func temporary() -> ChatRoom {
        let entity = NSEntityDescription.entity(forEntityName: "ChatRoom", in: DataSync.newContext)
        return ChatRoom(entity: entity!, insertInto: nil)
    }
    
    public typealias ImportSource = ArrowJSON
    public class var uniqueIDKeyPath: String {
        return "chatRoomID"
    }
    public var uniqueIDValue: NSNumber {
        get { return self.chatRoomID! }
        set { self.chatRoomID = newValue }
    }

    public func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
        
        self.createdAt = Date.from(string: source["created_at"]!.data! as! String) as NSDate?
//        self.updatedAt = Date.from(string: source["updated_at"]!.data! as! String) as NSDate?
        self.chatRoomID <-- source["id"]
        self.chatType <-- source["chat_type"]
        self.title <-- source["title"]
        self.unread <-- source["unread"]
        
        if let usersSource = source["users"]?.collection {
            let importedUsers = try transaction.importUniqueObjects(Into<User>(), sourceArray: usersSource)
            users = NSSet(array: importedUsers)
        }        
        if let messagesSource = source["messages"]?.collection {
            let importedMessages = try transaction.importUniqueObjects(Into<Message>(), sourceArray: messagesSource)
            messages = NSSet(array: importedMessages)
        }
    }
    
    public static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> NSNumber? {
        return source["id"]?.data as? NSNumber
    }
    
    public func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
    }
}
