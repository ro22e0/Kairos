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
        self.user = UserManager.shared.current
        configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func configure() {
//        self.former = Former(tableView: self.profileTableView)
        
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
                self?.former.deselect(animated: true)
                self?.presentImagePicker()
        }
        self.rows.append(imageRow)
        
        let fullnameRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "Fullname"
            $0.titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.configure {
                $0.text = user.user!.name
            }.onTextChanged { (text) in
                self.user.user!.name = text
        }
        self.rows.append(fullnameRow)
        
        let nicknameRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "Nickname"
            $0.titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.onTextChanged { (text) in
                self.user.user!.nickname = text
        }
        self.rows.append(nicknameRow)
        
        let schoolRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "School"
            $0.titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.onTextChanged { (text) in
                self.user.user!.school = text
        }
        rows.append(schoolRow)
        
        let promotionRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "Promotion"
            $0.titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.onTextChanged { (text) in
                self.user.user!.promotion = text
        }
        rows.append(promotionRow)
        
        let locationRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "Location"
            $0.titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.onTextChanged { (text) in
                self.user.user!.location = text
        }
        rows.append(locationRow)
        
        let companyRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "Company"
            $0.titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
            
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.onTextChanged { (text) in
                self.user.user!.company = text
        }
        rows.append(companyRow)
        
        let jobRow = TextFieldRowFormer<CustomTextFieldTableViewCell>(instantiateType: .Nib(nibName: "CustomTextFieldTableViewCell")) {
            $0.titleLabel.text = "Job"
            $0.titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
            
            $0.textField.textColor = .formerColor()
            $0.textField.font = .systemFont(ofSize: 15)
            }.onTextChanged { (text) in
                self.user.user!.job = text
        }
        rows.append(jobRow)
        
        // Create Headers
        
        let createHeader: ((String) -> ViewFormer) = { text in
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
    
    fileprivate func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        let parameters = user.user!.dictionaryWithValues(forKeys: ["id", "name", "nickname", "image", "email", "school", "promotion", "location", "company", "job"])
        UserManager.shared.update(parameters as [String : Any]) { (status) in
            switch status {
            case .success:
                print("yeah")
                _ = self.user.save()
                self.setRootVC(StoryboardID.Board.rawValue)
            case .error(let error):
                print(error)
            }
        }
    }

    @IBAction func skip(_ sender: Any) {
        let changedValues = user.user!.committedValues(forKeys: ["name", "nickname", "image", "email", "school", "promotion", "location", "company", "job"])
        for (key, value) in changedValues {
            if value is NSNull {
                user.user!.setValue(nil, forKey: key)
            } else {
                user.user!.setValue(value, forKey: key)
            }
        }
        self.setRootVC(StoryboardID.Board.rawValue)
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension CompleteProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            user.user!.imageData = UIImageJPEGRepresentation(image, 1) as NSData?
            let imageRow = self.rows.first as! LabelRowFormer<ProfileImagePickerTableViewCell>
            imageRow.cellUpdate {
                $0.imageProfileView.image = image
                $0.imageProfileView.round()
            }
        }
    }
}
