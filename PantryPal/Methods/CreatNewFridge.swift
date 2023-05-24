//
//  CreatNewFridge.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//

import UIKit
import Firebase

func createNewFridge(_ name: String) {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
        print("登入狀態有問題")
        return
    }
    
    // 新增冰箱 document 屬性
    let fridges = Firestore.firestore().collection("fridges")
    
    let document = fridges.document()
    
    let data: [String: Any] = [
        "id": document.documentID,
        "name": name,
        "created_time": Date().timeIntervalSince1970
    ]
    document.setData(data)
    
    // 新增冰箱 memeber document 的屬性 （創建用戶）
    let members = fridges.document(document.documentID).collection("members")
    let membersDocument = members.document(currentUserId)
    
    let userIdData: [String: Any] = [
        "id": currentUserId
    ]
    membersDocument.setData(userIdData)
    
    let fridgeDocumentId = document.documentID
    // 將創建使用者的資料加入創建冰箱
    let users = Firestore.firestore().collection("users")
    let currentUserData = users.document(currentUserId)
    
    currentUserData.getDocument { (document, error) in
        if let document = document, document.exists {
            // 檢查文檔是否存在
            if var data = document.data() {
                // 從文檔數據中獲取屬性數據
                if var joinFridgesArray = data["join_fridges"] as? [String],
                   var ownFridgesArray = data["own_fridges"] as? [String] { // 將 arrayProperty 屬性轉換為 [String] 類型
                    // 修改陣列資料
                    joinFridgesArray.append(fridgeDocumentId)
                    ownFridgesArray.append(fridgeDocumentId)
                    
                    // 將修改後的陣列資料重新寫入屬性
                    data["join_fridges"] = joinFridgesArray
                    data["own_fridges"] = ownFridgesArray
                    
                    // 更新文檔數據
                    currentUserData.setData(data, merge: true) { error in
                        if let error = error {
                            // 在此處理錯誤
                            print("更新文檔數據時出錯：\(error.localizedDescription)")
                        } else {
                            // 文檔數據更新成功
                            print("文檔數據更新成功")
                        }
                    }
                }
            }
        } else {
            print("文檔不存在")
        }
    }
}
