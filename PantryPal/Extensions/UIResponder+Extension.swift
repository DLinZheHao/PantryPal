//
//  UIResponder.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/26.
//

import Foundation
import UIKit
extension UIResponder {
    var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
