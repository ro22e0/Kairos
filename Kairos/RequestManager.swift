//
//  RequestManager.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 25/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class RequestManager {
    static let `default` = RequestManager()
    private init() {
        serializationQueue = OperationQueue()
        serializationQueue.maxConcurrentOperationCount = 3
        serializationQueue.name = "Serialisation Queue"
    }
    
    var serializationQueue: OperationQueue
}
