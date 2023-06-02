//
//  IngredientsRecording.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/28.
//

import Foundation
import Firebase

func processingAction(fridgeID: String, ingredientsHistoryData: IngredientsHistoryData, completion: @escaping () -> Void) {
    // history_ingredients
    let fridge = Firestore.firestore().collection("fridges")
    let fridgeDoc = fridge.document(fridgeID)
    
    let historyIngredients = fridgeDoc.collection("history_ingredients")
    let historyIngredientsDoc = historyIngredients.document()
    
    let data: [String: Any] = [
        "created_time": ingredientsHistoryData.createdTime,
        "expiration": ingredientsHistoryData.expiration,
        "action": ingredientsHistoryData.action,
        "price": ingredientsHistoryData.price,
        "ingredients_id": ingredientsHistoryData.ingredientsID,
        "barcode": ingredientsHistoryData.barcode ?? "",
        "name": ingredientsHistoryData.name,
        "store_status": ingredientsHistoryData.storeStatus,
        "url": ingredientsHistoryData.url,
        "description": ingredientsHistoryData.description,
        "action_time": Date().timeIntervalSince1970
    ]
    historyIngredientsDoc.setData(data)
    
    // ingredients
    let allIngreditents = fridgeDoc.collection("ingredients")
    let allIngredientsQuery = allIngreditents.whereField("ingredients_id", isEqualTo: ingredientsHistoryData.ingredientsID)
    
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
}
