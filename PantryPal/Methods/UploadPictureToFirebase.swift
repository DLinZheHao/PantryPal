//
//  UploadPictureToFirebase.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/26.
//

import UIKit
import Firebase
import FirebaseStorage

func uploadPictureToFirebase(_ selectedFileURL: URL?, completion: @escaping (URL?, Error?) -> Void) {
    if let selectedFileURL = selectedFileURL {
        // 建立一個自訂的檔案名稱，例如使用時間戳記作為檔案名稱
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let fileName = "\(timestamp).jpg"
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let photosRef = storageRef.child("photos")
        let photoRef = photosRef.child(fileName)
        
        do {
            let fileData = try Data(contentsOf: selectedFileURL)
            
            _ = photoRef.putData(fileData, metadata: nil) { metadata, error in
                if let error = error {
                    // 上傳失敗
                    completion(nil, error)
                    return
                } else {
                    // 上傳成功
                    print("照片上傳成功")
                    // 可以獲取下載 URL
                    photoRef.downloadURL { url, error in
                        if let error = error {
                            // 無法獲取下載 URL，回傳錯誤
                            completion(nil, error)
                            return
                        }
                        // 回傳影片的下載 URL
                        completion(url, nil)
                    }
                }
            }
        } catch {
            print("無法讀取檔案資料：\(error.localizedDescription)")
        }
    }
}

