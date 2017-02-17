//
//  UserListCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 09/02/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit

class UserListCell: UITableViewCell {

    // MARK: Public
    
    var users = [User]()
    var onInfoSelected: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    // MARK: Private
    
    @IBOutlet private weak var collectionView: UICollectionView!

    private func configure() {
        selectionStyle = .none
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "UserCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "userCell")
    }
    
    @IBAction func showUsersList(_ sender: Any) {
        onInfoSelected?()
    }
}

extension UserListCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as? UserCollectionViewCell
        let user = users[indexPath.item]
        
        cell?.imageView.setImageWith(user.name!, color: .orangeTint(), circular: true)
        cell?.nameLabel.text = user.name
        
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let user = users[indexPath.item]
        let width = user.name!.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 11)]).width
        return CGSize(width: width, height: 40)
    }
}
