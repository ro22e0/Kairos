//
//  Owner+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 13/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import CoreStore

public class Owner: NSManagedObject, ImportableUniqueObject {
    
    public typealias ImportSource = [String: Any]
    public class var uniqueIDKeyPath: String {
        return "ownerID"
    }
    public var uniqueIDValue: NSNumber {
        get { return self.ownerID! }
        set { self.ownerID = newValue }
    }
    
    static func temporary() -> Owner {
        let entity = NSEntityDescription.entity(forEntityName: "Owner", in: DataSync.newContext)
        return Owner(entity: entity!, insertInto: nil)
    }
    
    //public func shouldInsert(from source: Dictionary<String, Any>, in transaction: BaseDataTransaction) -> Bool {
    //
    //}

    public func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
        self.ownerID = source["id"] as! NSNumber?
        
        try self.user = transaction.importUniqueObject(
            Into(User.self),
            source: source["user"] as! User.ImportSource
        )
    }

    public class func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> NSNumber? {
        return source["id"] as? NSNumber
    }
    
    public func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
    }
}
