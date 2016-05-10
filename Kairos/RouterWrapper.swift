//
//  RouterWrapper.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 10/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import Alamofire

public enum HTTPMethod: String {
    case GET, HEAD, POST, PUT, PATCH, DELETE, CONNECT, OPTIONS, TRACE
}

public enum Router: URLRequestConvertible {
    static let baseURL = "http://kairos-app.bitnamiapp.com"
    static var needToken: Bool = true

    case CreateUser([String: AnyObject])
    case Authenticate([String: AnyObject])
    
    var method: HTTPMethod {
        switch self {
        case .CreateUser, .Authenticate:
            return .POST
        }
    }

    var path: String {
        switch self {
        case .CreateUser:
            return "/auth"
        case .Authenticate:
            return "/auth/sign_in"
        }
    }

    // MARK: URLRequestConvertible

    public var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Router.baseURL)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if Router.needToken {
            mutableURLRequest.setValue(OwnerManager.sharedInstance.owner!.accessToken, forHTTPHeaderField: "access-token")
            mutableURLRequest.setValue(OwnerManager.sharedInstance.owner!.client, forHTTPHeaderField: "client")
            mutableURLRequest.setValue(OwnerManager.sharedInstance.owner!.uid, forHTTPHeaderField: "uid")
        }

        switch self {
        case .CreateUser(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .Authenticate(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        }
    }
}

class RouterWrapper: NSObject, NSURLSessionTaskDelegate {
    // MARK: - Singleton
    static let sharedInstance = RouterWrapper()
    private override init() {}

    lazy var manager: Manager = {
        let config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 15.0

        return Alamofire.Manager(configuration: config)
    }()

    func request(route: Router, completionHandler: Response<AnyObject, NSError> -> Void) {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        manager!.listener = { (status) in
            print("Network Status Changed: \(status)")
            switch status {
            case .Reachable(.WWAN):
                break
            case .Reachable(.EthernetOrWiFi):
                break
            case .NotReachable:
                manager!.startListening()
            default:
                break
            }
        }
        manager!.startListening()
        
        RouterWrapper.sharedInstance.manager.request(route).responseJSON(completionHandler: completionHandler)
    }
}