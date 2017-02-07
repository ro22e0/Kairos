//
//  TaskManager.swift
//  Kairos
//
//  Created by rba3555 on 18/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation

import SwiftyJSON

// MARK: Singleton
class TaskManager {
    
    static let shared = TaskManager()
    fileprivate init() {}

    func fetch(_ handler: (() -> Void)? = nil) {
        DataSync.fetchTasks() { (status) in
            switch status {
            case .success:
                if handler != nil {
                    handler!()
                }
            case .error(let error):
                print(error)
            }
        }
    }
    
    func all() -> [Task] {
        if let tasks = Task.all() as? [Task] {
            return tasks
        } else {
            return [Task]()
        }
    }
    
    func users(for task: Task) -> [User] {
        var users = [User]()
        if let allUsers = task.users {
            users = allUsers.allObjects as! [User]
        }
        return users
    }
    
    func tasks() -> [Task] {
        var tasks = [Task]()
        guard let user = UserManager.shared.current.user else {
            return tasks
        }
        if let myTasks = user.tasks?.allObjects as? [Task] {
            tasks = myTasks
        }
        return tasks
    }
    
    func tasks(for project: Project, assignedTo user: User? = nil) -> [Task] {
        var tasks = [Task]()
        
        if let allTasks = project.tasks?.allObjects as? [Task] {
            tasks = allTasks
        }
        
        if let user = user {
            tasks = tasks.filter({ (task) -> Bool in
                if let users = task.users {
                    return users.contains(user)
                }
                return false
            })
        }
        
        return tasks
    }

    func delete(user: User, from task: Task) {
        task.removeFromUsers(user)
    }
    
    //    func tasks(for project: Project) {
    //        var tasks = self.tasks()
    //
    //
    //        tasks.filter { (task) -> Bool in
    //            return task.u
    //        }
    //    }
    
    func create(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.createTask(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncTasks(json) {
                            completionHandler(.success(nil))
                        }
                    }
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func update(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.updateTask(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json)
                        DataSync.syncTasks(json) {
                            completionHandler(.success(nil))
                        }
                    }
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func invite(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.inviteTask(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncTasks(json) {
                            completionHandler(.success(nil))
                        }
                    }
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }

    func remove(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.removeTask(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncTasks(json) {
                            completionHandler(.success(nil))
                        }
                    }
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func delete(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.deleteTask(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...299:
                    completionHandler(.success(nil))
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
}
