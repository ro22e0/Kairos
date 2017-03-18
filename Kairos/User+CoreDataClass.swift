//
//  User+CoreDataClass.swift
//  Kairos
//
//  Created by rba3555 on 13/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import CoreData

public class User: NSManagedObject {

    override public func shouldImport(_ data: Any) -> Bool {
        print(data)
        return true
    }
    
    override public func willImport(_ data: Any) {
        print(data)
    }
    
    override public func didImport(_ data: Any) {
        print(data)
    }
}
