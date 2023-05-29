//
//  ChooseFridge.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/28.
//

import Foundation
import Firebase

func chooseFridge(_ fridgeID: String, completion: @escaping () -> Void) {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
        print("登入狀態有問題")
        return
    }
    let userDoc = Firestore.firestore().collection("users").document(currentUserId)
    userDoc.getDocument { (document, error) in
        if let document = document, document.exists {
            // 檢查文檔是否存在
            if var data = document.data() {
                // 從文檔數據中獲取屬性數據
                if var lastUseFridge = data["last_use_fridge"] as? String { // 將 arrayProperty 屬性轉換為 [String] 類型
                    // 更新文檔數據
                    lastUseFridge = fridgeID
                    data["last_use_fridge"] = lastUseFridge
                    
                    userDoc.setData(data, merge: true) { error in
                        if let error = error {
                            // 在此處理錯誤
                            print("更新文檔數據時出錯：\(error.localizedDescription)")
                        } else {
                            // 文檔數據更新成功
                            print("文檔數據更新成功")
                            completion()
                        }
                    }
                }
            }
        } else {
            print("文檔不存在")
        }
    }
}
