//
//  DeleteIngredients.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/28.
//

import Foundation
import Firebase

func deleteIngredients(_ fridgeID: String, _ ingredientsID: String, completion: @escaping () -> Void) {
    let fridge = Firestore.firestore().collection("fridges")
    let fridgeDoc = fridge.document(fridgeID)
    
    let allIngreditents = fridgeDoc.collection("ingredients")
    let allIngredientsQuery = allIngreditents.whereField("ingredients_id", isEqualTo: ingredientsID)
    
    allIngredientsQuery.getDocuments { (querySnapshot, error) in
        if let error = error {
            print("查詢食材時出錯：\(error.localizedDescription)")
            return
        }
        // 檢查查詢結果是否存在
        guard let documents = querySnapshot?.documents else {
            print("沒有符合條件的食材")
            return
        }
        // 獲取冰箱食材文檔資料
        let document = documents[0]
        document.reference.delete { error in
            if let error = error {
                print("刪除文件時發生錯誤：\(error)")
            } else {
                print("文件成功刪除")
                completion()
            }
        }
    }
    
    let ingredients = Firestore.firestore().collection("ingredients")
    let ingredientsDoc = ingredients.document(ingredientsID)

    ingredientsDoc.delete { error in
        if let error = error {
            print("刪除文件時發生錯誤：\(error)")
        } else {
            print("文件成功刪除")
        }
    }
    
}
