//
//  CreateNewIngredients.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/26.
//

import Firebase

func createNewIndredients(_ ingredientData: DatabaseIngredientsData) {
    // 新增冰箱 document 屬性
    let ingredients = Firestore.firestore().collection("ingredients")
    
    let document = ingredients.document()
    
    let data: [String: Any] = [
        "ingredients_id": document.documentID,
        "barcode": ingredientData.barcode ?? "",
        "belong_fridge": ingredientData.belongFridge,
        "describe": ingredientData.describe,
        "name": ingredientData.name,
        "price": ingredientData.price,
        "store_status": ingredientData.storeStatus,
        "url": ingredientData.url,
        "created_time": Date().timeIntervalSince1970,
        "expiration": ingredientData.expiration,
        "enable_Notification": ingredientData.enableNotification
    ]
    
    document.setData(data)
    
    let fridge = Firestore.firestore().collection("fridges").document(ingredientData.belongFridge).collection("ingredients")
    let fridgeDocument = fridge.document()
    
    let userIdData: [String: Any] = [
        "ingredients_id": document.documentID,
        "barcode": ingredientData.barcode ?? ""
    ]
    fridgeDocument.setData(userIdData)
    
    if ingredientData.enableNotification {
        notificationRegister(ingredientData.expiration, ingredientData.name, document.documentID)
    }
}
