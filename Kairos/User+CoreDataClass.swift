//
//  User+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 13/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import CoreStore

public class User: NSManagedObject, ImportableUniqueObject {

    public typealias ImportSource = [String: Any]
    public class var uniqueIDKeyPath: String {
        return "userID"
    }
    public var uniqueIDValue: NSNumber {
        get { return self.userID! }
        set { self.userID = newValue }
    }
    
    //public func shouldInsert(from source: Dictionary<String, Any>, in transaction: BaseDataTransaction) -> Bool {
    //
    //}
    
    public func didInsert(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
        self.userID = source["id"] as? NSNumber
        self.name = source["name"] as? String
        self.email = source["email"] as? String
    }
    
    public class func uniqueID(from source: ImportSource, in transaction: BaseDataTransaction) throws -> NSNumber? {
        return source["id"] as? NSNumber
    }
    
    public func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        print(source)
    }
}
