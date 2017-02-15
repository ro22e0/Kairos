//
//  ProjectRequestCell.swift
//  Kairos
//
//  Created by rba3555 on 18/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit

class ProjectRequestCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tasksLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var dateStartLabel: UILabel!
    @IBOutlet weak var dateEndLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.acceptButton.setImage(UIImage(named: "Checkmark"), for: UIControlState())
        self.acceptButton.setImage(UIImage(named: "Checkmark Filled"), for: .disabled)
        self.declineButton.setImage(UIImage(named: "Delete"), for: UIControlState())
        self.declineButton.setImage(UIImage(named: "Delete Filled"), for: .disabled)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func accept(_ sender: Any) {
        let project = Project.find("id == %@", args: self.tag) as! Project
        let parameters = ["id": project.id!]
        
        ProjectManager.shared.accept(parameters) { (status) in
            switch status {
            case .success:
                self.acceptButton.isEnabled = false
                self.declineButton.isEnabled = true
                Spinner.showWhistle("kProjectSuccess")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.ProjectStatusChange.rawValue), object: nil)
            case .error(let error):
                Spinner.showWhistle("kProjectError", success: false)
                print(error)
            }
        }
    }

    @IBAction func decline(_ sender: Any) {
        let project = Project.find("id == %@", args: self.tag) as! Project
        let parameters = ["id": project.id!]
        
        ProjectManager.shared.refuse(parameters) { (status) in
            switch status {
            case .success:
                self.declineButton.isEnabled = false
                self.acceptButton.isEnabled = true
                Spinner.showWhistle("kProjectSuccess")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.ProjectStatusChange.rawValue), object: nil)
            case .error(let error):
                Spinner.showWhistle("kProjectError", success: false)
                print(error)
            }
        }
    }
}
