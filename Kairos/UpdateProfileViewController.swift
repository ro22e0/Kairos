//
//  UpdateProfileViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 01/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import Former

class UpdateProfileViewController: FormViewController {
    
    var rows = [RowFormer]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configure() {
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
        
        let fullnameRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Fullname"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
        }
        self.rows.append(fullnameRow)
        
        let nicknameRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Nickname"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
        }
        self.rows.append(nicknameRow)
        
        let emailRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Email"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
            $0.textField.enabled = false
        }
        //            .configure {
        //                $0.enabled = false
        //        }
        self.rows.append(emailRow)
        
        let schoolRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "School"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
        }
        rows.append(schoolRow)
        
        let promotionRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Promotion"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
        }
        rows.append(promotionRow)
        
        let locationRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Location"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
        }
        rows.append(locationRow)
        
        let companyRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Company"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
        }
        rows.append(companyRow)
        
        let jobRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Job"
            $0.titleLabel.font = UIFont.boldSystemFontOfSize(15)
            
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFontOfSize(15)
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
        
        let aboutSection = SectionFormer(rowFormer: fullnameRow, nicknameRow, emailRow)
            .set(headerViewFormer: createHeader("About"))
        
        let moreSection = SectionFormer(rowFormer: schoolRow, promotionRow, locationRow, companyRow, jobRow)
            .set(headerViewFormer: createHeader("More Informations"))
        
        former.append(sectionFormer: imageSection, aboutSection, moreSection)
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
