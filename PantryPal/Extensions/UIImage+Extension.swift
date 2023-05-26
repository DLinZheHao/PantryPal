//
//  UIImage+Extension.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//

import UIKit

// swiftlint:disable identifier_name
enum ImageAsset: String {

    // Fridge tab - Tab
    case fridge
    case fridge_click
    case watermelon
}
// swiftlint:enable identifier_name

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
}
