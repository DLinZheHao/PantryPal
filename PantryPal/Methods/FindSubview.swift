//
//  FindSubview.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/26.
//

import UIKit

func findSubview<T: UIView>(ofType targetType: T.Type, in superView: UIView) -> T? {
    for subview in superView.subviews {
        if let targetSubview = subview as? T {
            // 找到符合目標類型的 subview
            return targetSubview
        }
        
        if let foundSubview: T = findSubview(ofType: targetType, in: subview) {
            // 在子 subview 中找到符合目標類型的 subview
            return foundSubview
        }
    }
    
    // 在 superView 中未找到符合目標類型的 subview
    return nil
}

