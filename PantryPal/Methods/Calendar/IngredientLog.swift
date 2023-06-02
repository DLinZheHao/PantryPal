//
//  IngredientLog.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/2.
//

import Foundation
import Firebase

func ingredientsLog(chooseDay: Date) {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
        print("登入狀態有問題")
        return
    }
    let users = Firestore.firestore().collection("users")
    let currentUserDoc = users.document(currentUserId)
    
    currentUserDoc.getDocument { (documentSnapshot, error) in
        if error != nil {
            return
        }
        guard let data = documentSnapshot?.data() else { return }
        guard let lastUseFridgeID = data["last_use_fridge"] as? String else { return }
        
        getHistoryIngredients(lastUseFridgeID, chooseDay)
    }
    
}

func getHistoryIngredients(_ fridgeID: String, _ chooseDay: Date) {
    let fridges = Firestore.firestore().collection("fridges")
    let fridgeDoc = fridges.document(fridgeID)
    let historyIngredients = fridgeDoc.collection("history_ingredients")
    
    historyIngredients.getDocuments { (documentSnapshot, error) in
        if error != nil {
            return
        }
        guard let documents = documentSnapshot?.documents else { return }
        
        var historyArray: [IngredientsHistoryPresentData] = []
        
        for document in documents {
            let data = document.data()
            guard let actionTime = data["action_time"] as? Double else { return }
            if isSameDay(timeInterval: actionTime, referenceDate: chooseDay) {
                guard let barcode = data["barcode"] as? String,
                      let action = data["action"] as? Int,
                      let ingredientsID = data["ingredients_id"] as? String,
                      let name = data["name"] as? String,
                      let price = data["price"] as? Double,
                      let storeStatus = data["store_status"] as? Int,
                      let url = data["url"] as? String,
                      let createdTime = data["created_time"] as? Double,
                      let expiration = data["expiration"] as? Timestamp,
                      let description = data["description"] as? String else { return }
                let newHistoryData = IngredientsHistoryPresentData(barcode: barcode,
                                                                   ingredientsID: ingredientsID,
                                                                   name: name,
                                                                   price: price,
                                                                   storeStatus: storeStatus,
                                                                   url: url,
                                                                   createdTime: createdTime,
                                                                   expiration: expiration.dateValue(),
                                                                   description: description,
                                                                   action: action)
                historyArray.append(newHistoryData)
            } 
        }
        print("今日結果：\(historyArray)")
    }
    
}


