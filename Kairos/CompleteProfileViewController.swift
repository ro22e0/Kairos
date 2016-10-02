//
//  CompleteProfileViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 26/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former
import SwiftRecord

class CompleteProfileViewController: FormViewController {
    
    @IBOutlet weak var profileTableView: UITableView!
    
    var user: Owner!
    var rows = [RowFormer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.user = UserManager.sharedInstance.current
        configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configure() {
        former = Former(tableView: self.profileTableView)

        title = "Complete your profile"
                tableView.contentInset.top = 40
                tableView.contentInset.bottom = 40
        
        // Create RowFomers
        
        let imageRow = LabelRowFormer<ProfileImagePickerTableViewCell>(instantiateType: .Nib(nibName: "ProfileImagePickerTableViewCell")) {
            $0.imageProfileView.image = nil
            }.configure {
                $0.text = "Choose profile image from library"
                $0.rowHeight = 55
            }.onSelected { [weak self] _ in
                self?.former.deselect(true)
        }
        self.rows.append(imageRow)
        
        let fullnameRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "Fullname"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
            }.configure {
                $0.text = user.name
            }.onTextChanged { (text) in
                self.user.name = text
        }
        self.rows.append(fullnameRow)
        
        let nicknameRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "Nickname"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
            }.onTextChanged { (text) in
                self.user.nickname = text
        }
        self.rows.append(nicknameRow)
        
        let schoolRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "School"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
            }.onTextChanged { (text) in
                self.user.school = text
        }
        rows.append(schoolRow)
        
        let promotionRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "Promotion"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
            }.onTextChanged { (text) in
                self.user.promotion = text
        }
        rows.append(promotionRow)
        
        let locationRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "Location"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
            }.onTextChanged { (text) in
                self.user.location = text
        }
        rows.append(locationRow)
        
        let companyRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "Company"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
            }.onTextChanged { (text) in
                self.user.company = text
        }
        rows.append(companyRow)
        
        let jobRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "Job"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
            }.onTextChanged { (text) in
                self.user.job = text
        }
        rows.append(jobRow)
        
        // Create Headers
        
        let createHeader: (String -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 40
                    $0.text = text
            }
        }
        
        // Create SectionFormers
        
        let imageSection = SectionFormer(rowFormer: imageRow)
            .set(headerViewFormer: createHeader("Profile Image"))
        
        let aboutSection = SectionFormer(rowFormer: fullnameRow, nicknameRow)
            .set(headerViewFormer: createHeader("About"))
        
        let moreSection = SectionFormer(rowFormer: schoolRow, promotionRow, locationRow, companyRow, jobRow)
            .set(headerViewFormer: createHeader("More Informations"))
        
        former.append(sectionFormer: imageSection, aboutSection, moreSection)
    }
    
    @IBAction func done(sender: AnyObject) {
        let parameters = user.dictionaryWithValuesForKeys(["id", "name", "nickname", "image", "email", "school", "promotion", "location", "company", "job"])
        UserManager.sharedInstance.update(parameters) { (status) in
            switch status {
            case .Success:
                print("yeah")
                self.user.save()
                self.setRootVC(BoardStoryboardID)
            case .Error(let error):
                print(error)
            }
        }
    }
    
    @IBAction func skip(sender: AnyObject) {
        let changedValues = user.committedValuesForKeys(["name", "nickname", "image", "email", "school", "promotion", "location", "company", "job"])
        for (key, value) in changedValues {
            if value is NSNull {
                user.setValue(nil, forKey: key)
            } else {
                user.setValue(value, forKey: key)
            }
        }
        self.setRootVC(BoardStoryboardID)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
