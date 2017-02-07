//
//  UserModelCollectionController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 02/02/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit

class UserModelCollectionController: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    var users: [User]?

    init(_ collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: "UserCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "userCell")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as? UserCollectionViewCell
        let user = users![indexPath.item]
        
        cell?.imageView.setImageWith(user.name!, color: .orangeTint(), circular: true)
        cell?.nameLabel.text = user.name

        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let user = users![indexPath.item]
        _ = user.name!.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 11)])
        return CGSize(width: 25, height: 25)
    }
}
