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
import SwiftyJSON
import Arrow

public class Owner: NSManagedObject, ImportableUniqueObject {
    
    public typealias ImportSource = SwiftyJSON.JSON
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

    public func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
        self.ownerID = source["id"].number

        try self.user = transaction.importUniqueObject(
            Into<User>(),
            source: source["user"] 
        )
    }

    public class func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> NSNumber? {
        return source["id"].number
    }
    
    public func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
    }
}
