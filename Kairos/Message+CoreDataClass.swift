//
//  Message+CoreDataClass.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 19/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import CoreStore
import Arrow

public class Message: NSManagedObject, ImportableUniqueObject {
    
    static func temporary() -> Message {
        let entity = NSEntityDescription.entity(forEntityName: "Message", in: DataSync.newContext)
        return Message(entity: entity!, insertInto: nil)
    }

    public typealias ImportSource = ArrowJSON
    public class var uniqueIDKeyPath: String {
        return "messageID"
    }
    public var uniqueIDValue: NSNumber {
        get { return self.messageID! }
        set { self.messageID = newValue }
    }

    public func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)

        self.createdAt = Date.from(string: source["created_at"]!.data! as! String) as NSDate?
        self.body <-- source["body"]
        self.messageID <-- source["id"]
        try self.user = transaction.importUniqueObject(Into<User>(), source: source["user"]!)
        if let chatRoomID = source["chat_room_id"], let chatRoomSource = ArrowJSON(["id": chatRoomID]) {
            try self.chatRoom = transaction.importUniqueObject(Into<ChatRoom>(), source: chatRoomSource)
        }
    }

    public static func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> NSNumber? {
        return source["id"]?.data as? NSNumber
    }
    
    public func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
    }
}
