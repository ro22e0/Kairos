//
//  DataSync.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 11/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import SwiftRecord
//import Arrow
import CoreStore
//import MagicalRecord
//import DATAStack
//import Sync

struct DataSync {
    
    static func save() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        delegate.saveContext()
    }
    
    static var newContext: NSManagedObjectContext = {
        let delegate = UIApplication.shared.delegate as! AppDelegate

        return delegate.mainContext
    }()
    
    //    static func sync(inEntityNamed entityName: String, predicate: NSPredicate? = nil, data: [[String: Any]],  firstImport: Bool = false, completion: @escaping ((CustomStatus) -> Void)) {
    //
    //        let ops: Sync.OperationOptions = firstImport ? [.All] : [.Insert, .Update]
    //
    ////        let operation = Sync(changes: data, inEntityNamed: entityName, predicate: predicate, dataStack: self.dataStack(), operations: ops)
    //
    //        Sync.changes(data, inEntityNamed: entityName, predicate: predicate, dataStack: self.dataStack(), operations: ops) { (error) in
    //            let operation = BlockOperation {
    //                if error == nil {
    //                    completion(.success)
    //                } else {
    //                    completion(.error("ResponseSerializableObjectFailed"))
    //                }
    //            }
    //            RequestManager.default.serializationQueue.addOperation(operation)
    //        }
    //
    ////
    ////        Sync.changes(data, inEntityNamed: entityName, predicate: predicate, dataStack: self.dataStack(), operations: ops, completion: completion)
    ////
    ////
    ////
    ////
    ////        operation.completionBlock = {
    ////            if operation.isFinished && !operation.isCancelled {
    ////            } else {
    ////            }
    ////        }
    //    }
    
    func sync<T>(object: T.Type, data: [[String: Any]]) {
    }
    
    static func transformJson(_ json: JSON) -> [[String: Any]] {
        var data = [[String: Any]]()
        
        for elem in json.array! {
            if let dict = elem.dictionaryObject {
                data.append(dict as [String : Any])
            }
        }
        return data
    }
    
    static func deleteAll() {
        CoreStore.beginAsynchronous { (transaction) -> Void in
            transaction.deleteAll(From<Owner>())
            transaction.deleteAll(From<Event>())
            transaction.deleteAll(From<Calendar>())
            transaction.deleteAll(From<User>())
            transaction.deleteAll(From<Project>())
            transaction.deleteAll(From<Task>())
            transaction.deleteAll(From<ChatRoom>())
            transaction.deleteAll(From<Message>())
            transaction.commit()
        }
//        Owner.deleteAll()
//        Calendar.deleteAll()
//        Event.deleteAll()
//        Project.deleteAll()
//        Task.deleteAll()
//        User.deleteAll()
//        ChatRoom.deleteAll()
//        Message.deleteAll()
//        try! NSManagedObjectContext.defaultContext.save()
        //        try! self.dataStack().drop()
    }
    
    // MARK: - Friends
    
    static func syncFriends(_ json: JSON, completionHandler: @escaping ()->()) {
        var data: [String: Any] = json.dictionaryObject!
        data["id"] = UserManager.shared.current.ownerID
        print(data)
//        Owner.mr_import(from: [data])
    }
    
    static func fetchFriends(_ completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.getFriends) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                switch response.response!.statusCode {
                case 200...203:

                    if let value = response.result.value {
                        let json = JSON(value)
                        switch response.response!.statusCode {
                        case 200:
                            var data: [String: Any] = json.dictionaryObject!
                            data["id"] = UserManager.shared.current.ownerID
                            print(data)

                            let source = ArrowJSON(data)
                            CoreStore.beginAsynchronous({ (transaction) in
                                do {
                                    try _ = transaction.importUniqueObject(
                                        Into<Owner>(),
                                        source: source!
                                    )
                                }
                                catch {
                                    return // Woops, don't save
                                }
                                transaction.commit({ (result) in
                                    switch result {
                                    case .success(let hasChanges):
                                        print("success!", hasChanges)
                                        let defautls = UserDefaults.standard
                                        defautls.setValue(true, forKey: userLoginKey)
                                        completionHandler(.success(nil))
                                    case .failure(let error):
                                        print(error)
                                    }
                                })
                            })
                            //                        MagicalRecord.saveInBackground({ (localContext) in
                            //                            Owner.mr_import(from: data, in: localContext)
                            ////                            Owner.mr_import(from: [data], in: localContext)
                            //                        }, completion: {
                            //                            print("finish")
                            //                            let defautls = UserDefaults.standard
                            //                            defautls.setValue(true, forKey: userLoginKey)
                            ////                            self.current = Owner.mr_findAll()?.first as! Owner
                            //                            completionHandler(.success(nil))
                        //                        })
                        default:
                            completionHandler(.error("Fail to connect"))
                        }
                    }

                    
                    
                    
                default:
                    completionHandler(.error("error"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    // MARK: - Users
    
    fileprivate static func deleteUsers(_ users: [JSON]) {
        let ids = NSMutableArray()
        
        for u in users {
            ids.add(u["id"].object)
        }
        
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedUsers = User.query(predicate) as! [User]
        for u in deletedUsers {
            let friendExist = User.find("id == %@", args: u.userID!) != nil ? true : false
            let ownerExist = Owner.find("id == %@", args: u.userID!) != nil ? true : false
            
            if (!friendExist && !ownerExist) {
                u.delete()
            }
        }
    }
    
    fileprivate static func syncUsers(_ users: [JSON]) {
        for u in users {
            print("OWNER:  ", Owner.all())
            print("FRIENDS:  ", User.all())
            print("User id : ", u["id"])
            print("User id : ", User.find("id == %@", args: u["id"].stringValue))
            print("Owner id : ", Owner.find("id == %@", args: u["id"].stringValue))

            let friendExist = User.find("id == %@", args: u["id"].stringValue) != nil ? true : false
            let ownerExist = Owner.find("id == %@", args: u["id"].stringValue) != nil ? true : false

            if (!friendExist && !ownerExist) {
                let user = User.findOrCreate(["id": u["id"].object]) as! User
                user.name = u["name"].stringValue
                user.nickname = u["nickname"].stringValue
                user.email = u["email"].stringValue
                user.image = u["image"].string
            }
        }
        User.save()
    }

    static func fetchUsers(_ completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.getUsers) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value).array
//                        print(json)

                        let source = ArrowJSON(value)
                        CoreStore.beginAsynchronous({ (transaction) in
                            do {
                                try _ = transaction.importUniqueObjects(
                                    Into<User>(),
                                    sourceArray: source!.collection!
                                )
                            }
                            catch {
                                return // Woops, don't save
                            }
                            transaction.commit({ (result) in
                                switch result {
                                case .success(let hasChanges):
                                    print("success!", hasChanges)
                                    completionHandler(.success(nil))
                                case .failure(let error):
                                    print(error)
                                }
                            })
                        })

//                        let data = self.transformJson(json)
//                        MagicalRecord.saveInBackground({ (localContext) in
//                            User.mr_import(from: json, in: localContext)
//                        }, completion: {
//                            print("finish")
//                        })
                    }
                default:
                    completionHandler(.error("error"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
                print(error)
            }
        }
    }
    
    // MARK: - Calendar
    
    fileprivate static func deleteCalendars(_ calendars: [JSON]) {
        let ids = NSMutableArray()
        let id: Int?

        for c in calendars {
            ids.add(c["id"].object)
        }
        
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedCalendars = Calendar.query(predicate) as! [Calendar]
        for c in deletedCalendars {
            c.delete()
        }
    }
    
    fileprivate static func deleteObject(_ data: [JSON], query: @escaping (NSPredicate) -> [NSManagedObject]) {
        let ids = NSMutableArray()
        
        for elem in data {
            ids.add(elem["id"].object)
        }
        
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedObjects = query(predicate)
        for o in deletedObjects {
            o.delete()
        }
    }
    
    fileprivate static func syncUserCalendar(_ calendar: Calendar, users: [JSON]) {
    }
    
    static func syncCalendars(_ json: JSON, completionHandler: @escaping ()->()) {
        let data = json.dictionaryObject
//        MagicalRecord.saveInBackground({ (localContext) in
//            Calendar.mr_import(from: [data], in: localContext)
//        }, completion: {
//            print("finish")
//        })
    }
    
    static func fetchCalendars(_ completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.getCalendars) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value).arrayValue
                    print(json)
                    
                    let source = ArrowJSON(value)
                    CoreStore.beginAsynchronous({ (transaction) in
                        do {
                            try _ = transaction.importUniqueObjects(
                                Into<Calendar>(),
                                sourceArray: source!.collection!
                            )
                        }
                        catch {
                            return // Woops, don't save
                        }
                        transaction.commit({ (result) in
                            switch result {
                            case .success(let hasChanges):
                                print("success!", hasChanges)
                                completionHandler(.success(nil))
                            case .failure(let error):
                                print(error)
                            }
                        })
                    })
                    
//                    deleteObject(json.arrayValue, query: { (predicate) -> [NSManagedObject] in
//                        return Calendar.query(predicate)
//                    })
//                    let data = DataSync.transformJson(json)
//                    MagicalRecord.saveInBackground({ (localContext) in
//                        Calendar.mr_import(from: json, in: localContext)
//                    }, completion: {
//                        print("finish")
//                    })
                }
            case .failure(let error):
                completionHandler(.error("error"))
                print(error)
            }
        }
    }
    
    static func fetchCalendarColors() {
        RouterWrapper.shared.request(.getCalendarColors) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value).dictionaryObject as! [String: String]
                    print(json)
                    CalendarManager.shared.colors = json
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Events
    fileprivate static func deleteEvents(_ events: [JSON]) {
        let ids = NSMutableArray()
        
        for e in events {
            ids.add(e["id"].object)
        }
        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        let deletedEvents = Event.query(predicate) as! [Event]
        for e in deletedEvents {
            e.delete()
        }
    }
    
    static func syncEvents(_ json: JSON, completionHandler: @escaping ()->()) {
        let data = json.dictionaryObject
//        MagicalRecord.saveInBackground({ (localContext) in
//            Event.mr_import(from: [data], in: localContext)
//        }, completion: {
//            print("finish")
//        })
    }

    static func fetchEvents() {
        RouterWrapper.shared.request(.getEvents) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value).arrayValue
                    print(json)
//                    MagicalRecord.saveInBackground({ (localContext) in
//                        Event.mr_import(from: json, in: localContext)
//                    }, completion: {
//                        print("finish")
//                    })
                }
            case .failure(let error):
                print(error)
            }
            print(NSDate(), "done")
        }
    }
    
    static func fetchEvents(_ completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.getEvents) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value).arrayValue
                    print(json)

                    let source = ArrowJSON(value)
                    CoreStore.beginAsynchronous({ (transaction) in
                        do {
                            try _ = transaction.importUniqueObjects(
                                Into<Event>(),
                                sourceArray: source!.collection!
                            )
                        }
                        catch {
                            return // Woops, don't save
                        }
                        transaction.commit({ (result) in
                            switch result {
                            case .success(let hasChanges):
                                print("success!", hasChanges)
                                completionHandler(.success(nil))
                            case .failure(let error):
                                print(error)
                            }
                        })
                    })
//                    deleteObject(json.arrayValue, query: { (predicate) -> [NSManagedObject] in
//                        return Event.query(predicate)
//                    })
//                    let data = DataSync.transformJson(json)
//                    MagicalRecord.saveInBackground({ (localContext) in
//                        Event.mr_import(from: json, in: localContext)
//                    }, completion: {
//                        print("finish")
//                    })
                }
            case .failure(let error):
                completionHandler(.error("error"))
                print(error)
            }
        }
    }
    
    // MARK: - Projects
    static func syncProjects(_ json: JSON, completionHandler: @escaping ()->()) {
        let data = json.dictionaryObject
//        MagicalRecord.saveInBackground({ (localContext) in
//            Project.mr_import(from: [data], in: localContext)
//        }, completion: {
//            print("finish")
//        })
    }
    
    static func fetchProjects(_ completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.getProjects) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    print(json)
                    
                    
                    let source = ArrowJSON(value)
                    CoreStore.beginAsynchronous({ (transaction) in
                        do {
                            try _ = transaction.importUniqueObjects(
                                Into<Project>(),
                                sourceArray: source!.collection!
                            )
                        }
                        catch {
                            return // Woops, don't save
                        }
                        transaction.commit({ (result) in
                            switch result {
                            case .success(let hasChanges):
                                print("success!", hasChanges)
                                completionHandler(.success(nil))
                            case .failure(let error):
                                print(error)
                            }
                        })
                    })
                    
//                    let data = DataSync.transformJson(json)
//                    MagicalRecord.saveInBackground({ (localContext) in
//                        Project.mr_import(from: data, in: localContext)
//                    }, completion: {
//                        print("finish")
//                    })
                    
                    //                    deleteObject(json.array!, query: Calendar.query)
                    
                    //                    self.syncCalendars(json)
                    //                    completionHandler(.success(nil))
                    
                    //                    let completion: ((NSError?) -> Void) = { error in
                    //                        print(NSDate(), "done")
                    //
                    //                        for c in json.array! {
                    //                            var data = [[String : Any]]()
                    //                            data += c["refused_users"].object as! [[String : Any]]
                    //                            data += c["participating_users"].object as! [[String : Any]]
                    //                            data += c["invited_users"].object as! [[String : Any]]
                    //                            data += c["owners"].object as! [[String : Any]]
                    //
                    //                            self.sync(entity: "User", predicate: nil, data: data, completion: { error in
                    //                                print(NSDate(), "done")
                    //                            })
                    //                        }
                    //                    }
                    //                    self.sync(entity: "Calendar", predicate: nil, data: json.object as! [[String : Any]], completion: completion)
                }
            case .failure(let error):
                completionHandler(.error("error"))
                print(error)
            }
        }
    }
    
    // MARK: - Tasks
    static func syncTasks(_ json: JSON, completionHandler: @escaping ()->()) {
        let data = json.dictionaryObject
//        MagicalRecord.saveInBackground({ (localContext) in
//            Task.mr_import(from: [data], in: localContext)
//        }, completion: {
//            print("finish")
//        })
    }
    
    static func fetchTasks(_ completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.getTasks) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    print(json)
                    
                    
                    let source = ArrowJSON(value)
                    CoreStore.beginAsynchronous({ (transaction) in
                        do {
                            try _ = transaction.importUniqueObjects(
                                Into<Task>(),
                                sourceArray: source!.collection!
                            )
                        }
                        catch {
                            return // Woops, don't save
                        }
                        transaction.commit({ (result) in
                            switch result {
                            case .success(let hasChanges):
                                print("success!", hasChanges)
                                completionHandler(.success(nil))
                            case .failure(let error):
                                print(error)
                            }
                        })
                    })
                    
                    
                    //                    deleteObject(json.arrayValue, query: { (predicate) -> [NSManagedObject] in
                    //                        return Task.query(predicate)
                    //                    })
//                    let data = DataSync.transformJson(json)
//                    MagicalRecord.saveInBackground({ (localContext) in
//                        Task.mr_import(from: data, in: localContext)
//                    }, completion: {
//                        print("finish")
//                    })
                    
                    //                    deleteObject(json.array!, query: Calendar.query)
                    
                    //                    self.syncCalendars(json)
                    //                    completionHandler(.success(nil))
                    
                    //                    let completion: ((NSError?) -> Void) = { error in
                    //                        print(NSDate(), "done")
                    //
                    //                        for c in json.array! {
                    //                            var data = [[String : Any]]()
                    //                            data += c["refused_users"].object as! [[String : Any]]
                    //                            data += c["participating_users"].object as! [[String : Any]]
                    //                            data += c["invited_users"].object as! [[String : Any]]
                    //                            data += c["owners"].object as! [[String : Any]]
                    //
                    //                            self.sync(entity: "User", predicate: nil, data: data, completion: { error in
                    //                                print(NSDate(), "done")
                    //                            })
                    //                        }
                    //                    }
                    //                    self.sync(entity: "Calendar", predicate: nil, data: json.object as! [[String : Any]], completion: completion)
                }
            case .failure(let error):
                completionHandler(.error("error"))
                print(error)
            }
        }
    }
    
    // MARK: - ChatRooms
    static func syncChatRooms(_ json: JSON, completionHandler: @escaping ()->()) {
        let data = json.dictionaryObject
//        MagicalRecord.saveInBackground({ (localContext) in
//            ChatRoom.mr_import(from: [data], in: localContext)
//        }, completion: {
//            print("finish")
//        })
    }
    
    static func fetchChatRooms(_ completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.getChatRooms) { (response) in
            print(response.response) // URL response
            switch response.result {
            case .success:
                UserManager.shared.setCredentials(response.response!)
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    print(json)
                    
                    let data = DataSync.transformJson(json)
//                    MagicalRecord.saveInBackground({ (localContext) in
//                        ChatRoom.mr_import(from: data, in: localContext)
//                    }, completion: {
//                        print("finish")
//                    })
                    
                    //                    deleteObject(json.array!, query: Calendar.query)
                    
                    //                    self.syncCalendars(json)
                    //                    completionHandler(.success(nil))
                    
                    //                    let completion: ((NSError?) -> Void) = { error in
                    //                        print(NSDate(), "done")
                    //
                    //                        for c in json.array! {
                    //                            var data = [[String : Any]]()
                    //                            data += c["refused_users"].object as! [[String : Any]]
                    //                            data += c["participating_users"].object as! [[String : Any]]
                    //                            data += c["invited_users"].object as! [[String : Any]]
                    //                            data += c["owners"].object as! [[String : Any]]
                    //
                    //                            self.sync(entity: "User", predicate: nil, data: data, completion: { error in
                    //                                print(NSDate(), "done")
                    //                            })
                    //                        }
                    //                    }
                    //                    self.sync(entity: "Calendar", predicate: nil, data: json.object as! [[String : Any]], completion: completion)
                }
            case .failure(let error):
                completionHandler(.error("error"))
                print(error)
            }
        }
    }
    
    static func syncMessages(_ json: JSON, completionHandler: @escaping ()->()) {
        let data = json.dictionaryObject
//        MagicalRecord.saveInBackground({ (localContext) in
//            Message.mr_import(from: [data], in: localContext)
//        }, completion: {
//            print("finish")
//        })
    }
}
