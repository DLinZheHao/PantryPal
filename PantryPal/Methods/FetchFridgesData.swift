//
//  FetchFridgesData.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//

import UIKit
import Firebase

func fetchFridgeData(completion: @escaping (Array<FridgeData>) -> Void) {
    print("開始連接資料")
    guard let currentUserId = Auth.auth().currentUser?.uid else {
        print("登入狀態有問題")
        return
    }
    let users = Firestore.firestore().collection("users")
    let currentUserData = users.document(currentUserId)
    
    currentUserData.addSnapshotListener { (document, error) in
        if let document = document, document.exists {
            // 檢查文檔是否存在
            if let data = document.data() {
                // 從文檔數據中獲取屬性數據
                if let joinFridgesArray = data["join_fridges"] as? [String],
                       !joinFridgesArray.isEmpty { // 將 arrayProperty 屬性轉換為 [String] 類型
                    let fridges = Firestore.firestore().collection("fridges")
                    let query = fridges.whereField("id", in: joinFridgesArray).order(by: "created_time", descending: true)
                    
                    query.getDocuments { (querySnapshot, error) in
                            if let error = error {
                                print("查詢冰箱時出錯：\(error.localizedDescription)")
                                return
                            }
                            // 檢查查詢結果是否存在
                            guard let documents = querySnapshot?.documents else {
                                print("沒有符合條件的冰箱")
                                return
                            }
                            // 處理符合條件的冰箱文檔
                            var userFridgeData: [FridgeData] = []
                            for document in documents {
                                let fridgeData = document.data()
                                // 在這裡處理冰箱數據
                                print("參與：\(fridgeData)")
                                guard let id = fridgeData["id"] as? String,
                                      let name = fridgeData["name"] as? String,
                                      let createdTime = fridgeData["created_time"] as? Double else {
                                    print("型態轉換失敗")
                                    return
                                }
                                let newFridge = FridgeData(id: id, name: name, createdTime: createdTime)
                                userFridgeData.append(newFridge)
                            }
                            completion(userFridgeData)
                        }
                } else { print("失敗1")}
            } else { print("失敗2")}
        } else {
            print("文檔不存在")
        }
    }
}
