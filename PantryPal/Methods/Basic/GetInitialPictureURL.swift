//
//  GetInitialPictureURL.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/27.
//

import UIKit
import Firebase
import FirebaseStorage

func getInitialPictureURL(completion: @escaping (String) -> Void) {
    let storage = Storage.storage()
    let storageRef = storage.reference()
    // watermelon
    // 取得圖片的參考位置
    let imageRef = storageRef.child("watermelon.png")

    // 取得圖片的下載 URL
    imageRef.downloadURL { (url, error) in
        if let error = error {
            // 發生錯誤，無法取得 URL
            print("無法取得圖片 URL: \(error.localizedDescription)")
        } else {
            if let downloadURL = url {
                // 使用圖片的下載 URL
                print(downloadURL.absoluteString)
                completion(downloadURL.absoluteString)
            } else {
                // 無效的 URL
                print("無效的圖片 URL")
            }
        }
    }

}
