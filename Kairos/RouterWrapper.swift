//
//  RouterWrapper.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 10/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import Alamofire

/**
 HTTP method definitions.
 
 See [https://tools.ietf.org/html/rfc7231#section-4.3](https://tools.ietf.org/html/rfc7231#section-4.3)
 */
public enum HTTPMethod: String {
    case GET, HEAD, POST, PUT, PATCH, DELETE, CONNECT, OPTIONS, TRACE
}

/**
 Request use by `RouterWrapper`.
 */
public enum Router: URLRequestConvertible {
    
    /**
     Initialize the host URL of the server.
     
     - returns: A `String` baseURL.
     */
    static let baseURL = "http://kairos-app.bitnamiapp.com"
    
    /**
     Determine if the request need credentials in headers.
     
     - returns: A boolean `true` or `false`.
     */
    static var needToken: Bool = true

    /// Create a new user.
    case CreateUser([String: AnyObject])

    /// Authenticate a user.
    case Authenticate([String: AnyObject])
    
    /**
     The method use for the request.
     
     - returns: A `HTTPMethod`.
     */
    var method: HTTPMethod {
        switch self {
        case .CreateUser, .Authenticate:
            return .POST
        }
    }
    
    /**
     The endpoint of the request.
     
     - returns: A string represent the endpoint.
     */
    var path: String {
        switch self {
        case .CreateUser:
            return "/auth"
        case .Authenticate:
            return "/auth/sign_in"
        }
    }
    
    // MARK: URLRequestConvertible
    
    /**
     The request.
     
     - returns: The request as `NSMutableURLRequest` use by `RouterWrapper`.
     */
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

/**
 Responsible for creating and managing `RouterWrapper` requests, as well as their underlying `URLRequestConvertible`.
 */
class RouterWrapper: NSObject, NSURLSessionTaskDelegate {

    // MARK: - Singleton

    /**
     Initialize the shared instance of RouterWrapper.
     
     - returns: The instance created.
     */
    static let sharedInstance = RouterWrapper()

    private override init() {}
    
    /**
     Initialize the manager use by Alamofire.
     
     - returns: The created manager.
     */
    private lazy var manager: Manager = {
        let config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 15.0
        
        return Alamofire.Manager(configuration: config)
    }()
    
    /**
     Creates a request for the specified URL request.
     
     - parameters:
        - route: The request define in enum Router
        - completionHandler: A closure to be executed once the request has finished.
     */
    func request(request: Router, completionHandler: Response<AnyObject, NSError> -> Void) {
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
        
        RouterWrapper.sharedInstance.manager.request(request).responseJSON(completionHandler: completionHandler)
    }
}