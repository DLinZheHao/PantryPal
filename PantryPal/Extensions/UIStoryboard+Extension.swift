//
//  UIStoryboard+Extension.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//

import UIKit

extension UIStoryboard {
    static var fridgeList: UIStoryboard { return stStoryboard(name: "FridgeList") }
    static var fridgeTabBar: UIStoryboard { return stStoryboard(name: "FridgeTabBar") }
    static var ingredients: UIStoryboard { return stStoryboard(name: "Ingredients")}
    static var barcodeScanner: UIStoryboard { return stStoryboard(name: "BarcodeScanner")}
    static var ingredientsDetail: UIStoryboard { return stStoryboard(name: "IngredientsDetail")}
    static var members: UIStoryboard { return stStoryboard(name: "Members")}
    static var teamLink: UIStoryboard { return stStoryboard(name: "TeamLink")}
    
    private static func stStoryboard(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }
}
