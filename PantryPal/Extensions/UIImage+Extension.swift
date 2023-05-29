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
    case tableViewCell_background_1
    case members
}
// swiftlint:enable identifier_name

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
}

extension UIImage {
    static func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                print("圖片下載失敗！！！")
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }.resume()
    }
}
