//
//  UICollectionView+Extension.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/30.
//

import Foundation
import UIKit

extension UICollectionView {
    func lk_registerCellWithNib(identifier: String, bundle: Bundle?) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: identifier)
    }
}
