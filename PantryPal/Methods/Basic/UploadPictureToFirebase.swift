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
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let fileName = "\(timestamp).jpg"
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let photosRef = storageRef.child("photos")
        let photoRef = photosRef.child(fileName)
        
        DispatchQueue.global().async {
            do {
                let fileData = try Data(contentsOf: selectedFileURL)
                let image = UIImage(data: fileData)
                let compressedImageData = image!.jpegData(compressionQuality: 0.0)
                _ = photoRef.putData(compressedImageData!, metadata: nil) { metadata, error in
                    if let error = error {
                        // 上傳失敗
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    } else {
                        // 上傳成功
                        print("照片上傳成功")
                        // 可以獲取下載 URL
                        photoRef.downloadURL { url, error in
                            if let error = error {
                                // 無法獲取下載 URL，回傳錯誤
                                DispatchQueue.main.async {
                                    completion(nil, error)
                                }
                            } else if let downloadURL = url {
                                // 回傳影片的下載 URL
                                DispatchQueue.main.async {
                                    completion(downloadURL, nil)
                                }
                            } else {
                                // 無效的 URL
                                let error = NSError(domain: "FirebaseStorage", code: -1, userInfo: [NSLocalizedDescriptionKey: "無效的 URL"])
                                DispatchQueue.main.async {
                                    completion(nil, error)
                                }
                            }
                        }
                    }
                }
            } catch {
                print("無法讀取檔案資料：\(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
}
