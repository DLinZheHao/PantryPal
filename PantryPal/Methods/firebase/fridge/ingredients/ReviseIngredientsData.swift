//
//  ReviseIngredientsData.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/29.
//

import Foundation
import Firebase

func reviseIngredientsData(_ ingredientsID: String, _ databaseIngredientsData: DatabaseIngredientsData, _ completion: @escaping () -> Void) {
    let ingredients = Firestore.firestore().collection("ingredients")
    let ingredientsDoc = ingredients.document(ingredientsID)
    
    ingredientsDoc.getDocument { (document, error) in
        if let document = document {
            // 檢查文檔是否存在
            if var data = document.data() {
                // 將修改後的資料重新寫入屬性
                data["name"] = databaseIngredientsData.name
                data["price"] = databaseIngredientsData.price
                data["expiration"] = databaseIngredientsData.expiration
                data["barcdoe"] = databaseIngredientsData.barcode
                data["store_status"] = databaseIngredientsData.storeStatus
                data["enable_Notification"] = databaseIngredientsData.enableNotification
                data["describe"] = databaseIngredientsData.describe
                data["url"] = databaseIngredientsData.url
                
                // 更新文檔數據
                ingredientsDoc.setData(data, merge: true) { error in
                    if let error = error {
                        // 在此處理錯誤
                        print("更新文檔數據時出錯：\(error.localizedDescription)")
                    } else {
                        // 文檔數據更新成功
                        print("食材文檔數據更新成功")
                        completion()
                    }
                }
                
            } else {
                print("修改失敗")
            }
        } else {
            print("文檔不存在")
        }
    }
}
