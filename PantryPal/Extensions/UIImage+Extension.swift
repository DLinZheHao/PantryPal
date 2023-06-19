//
//  UIImage+Extension.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//

import UIKit

// swiftlint:disable identifier_name
enum ImageAsset: String {
    case fridge
    case fridge_click
    case watermelon
    case tableViewCell_background_1
    case members
    case fridge_select
    case fridge_not_select
    case teamLink_not_select
    case teamLink_select
    case join_not_select
    case join_select
    case calendar_not_select
    case calendar_select
    case calendar_background
    case outline_kitchen_black_36pt
    case outline_people_black_36pt
    case outline_change_circle_black_36pt
    case outline_add_box_black_36pt
    case chat_not_select
    case chat_select
    case outline_send_black_48pt
    case outline_send_black_36pt
    case refresh
    case small_chat
    case chatGPT_not_select
    case chatGPT_select
    case user
    case profile_user
    case ai
    case measure_not_select
    case measure_select
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
