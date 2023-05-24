//
//  UIStoryboard+Extension.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//

import UIKit

extension UIStoryboard {
    static var fridgeList: UIStoryboard { return stStoryboard(name: "FridgeList") }
    
    private static func stStoryboard(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }
}
