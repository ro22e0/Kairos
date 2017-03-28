//
//  FriendProfileViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 17/02/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class FriendProfileViewController: UIViewController {
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate lazy var former: Former = Former(tableView: self.tableView)
    var user: User?
    var status: FriendStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupActions()
        setupFormer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setupFormer() {
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
       
        let nameSection = labelSection(title: "Fullname :", value: user?.name ?? "")
        let emailSection = labelSection(title: "Email :", value: user?.email ?? "")
        let schoolSection = labelSection(title: "School :", value: user?.school ?? "")
        let promotionSection = labelSection(title: "Promotion :", value: user?.promotion ?? "")
        let jobSection = labelSection(title: "Job :", value: user?.job ?? "")
        let companySection = labelSection(title: "Company :", value: user?.company ?? "")
        former.append(sectionFormer: nameSection, emailSection, schoolSection, promotionSection, jobSection, companySection)
    }

    private func labelSection(title: String, value: Any) -> SectionFormer {
        let row = LabelRowFormer<FormLabelCell>() {
            $0.backgroundColor = .background()
            $0.formTextLabel()?.textColor = .formerColor()
            $0.formTextLabel()?.font = .boldSystemFont(ofSize: 15)
            $0.selectionStyle = .none
            }.configure {
                $0.rowHeight = 20
                $0.text = value as? String
            }.onUpdate {
                $0.text = value as? String
        }
        let section = SectionFormer(rowFormer: row)
            .set(headerViewFormer: Former.createHeader(title: title))
        return section
    }
    
    private func setupActions() {
        if let status = self.status {
            switch status {
            case .Requested:
                acceptButton.isHidden = false
                declineButton.isHidden = false
            case .Pending:
                cancelButton.isHidden = false
            case .Accepted:
                removeButton.isHidden = false
            case .None:
                inviteButton.isHidden = false
            }
        }
    }
    
    @IBAction func accept(_ sender: Any) {
        FriendManager.shared.accept([:]) { (status) in
            switch status {
            case .success(let value):
                print(value ?? "Empty")
            case .error(let error):
                print(error)
            }
        }
    }
    @IBAction func decline(_ sender: Any) {
        FriendManager.shared.refuse([:]) { (status) in
            switch status {
            case .success(let value):
                print(value ?? "Empty")
            case .error(let error):
                print(error)
            }
        }
    }
    @IBAction func invite(_ sender: Any) {
        FriendManager.shared.invite([:]) { (status) in
            switch status {
            case .success(let value):
                print(value ?? "Empty")
            case .error(let error):
                print(error)
            }
        }
    }
    @IBAction func remove(_ sender: Any) {
        FriendManager.shared.remove([:]) { (status) in
            switch status {
            case .success(let value):
                print(value ?? "Empty")
            case .error(let error):
                print(error)
            }
        }
    }
    @IBAction func cancel(_ sender: Any) {
        FriendManager.shared.cancel([:]) { (status) in
            switch status {
            case .success(let value):
                print(value ?? "Empty")
            case .error(let error):
                print(error)
            }
        }
    }
}

extension FriendProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension FriendProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
