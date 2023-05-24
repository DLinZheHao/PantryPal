//
//  UITableView+Extension.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//

import UIKit

extension UITableView {

    func lk_registerCellWithNib(identifier: String, bundle: Bundle?) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forCellReuseIdentifier: identifier)
    }

    func lk_registerHeaderWithNib(identifier: String, bundle: Bundle?) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
}

extension UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView {
    
    static var identifier: String {
        return String(describing: self)
    }
}
// tableView.lk_registerCellWithNib(identifier: String(describing: TrolleyTableViewCell.self), bundle: nil)
