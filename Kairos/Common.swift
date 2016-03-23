//
//  Common.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 17/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation

let MainStoryboardID = "Main"
let LoginStoryboardID = "Login"

let initialVC = "InitialViewController"

let kUSER_GOOGLE_AUTH_NOTIFICATION = "kUserGoogleAuth"
let kUSER_FB_AUTH_NOTIFICATION = "kUserFbAuth"

enum LoginSDK: String {
    case Facebook = "Facebook"
    case Google = "Google"
}