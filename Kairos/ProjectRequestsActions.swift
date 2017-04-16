//
//  ProjectRequestsActions.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 06/04/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import SwiftMessages

class ProjectRequestsActions: MessageView {
    
    var cancelAction: (() -> Void)?
    var createProject: (() -> Void)?
    var projectsRequests: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func createProject(_ sender: Any) {
        cancelAction?()
        createProject?()
    }
    
    @IBAction func projectsRequests(_ sender: Any) {
        cancelAction?()
        projectsRequests?()
    }
}
