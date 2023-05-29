//
//  UserLastUseFridge.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//

import UIKit
import Firebase

func userLastUseFridge(fridgeCompletion: @escaping (FridgeData, String) -> Void,
                       memberCompletion: @escaping (Array<MemberData>) -> Void,
                       ingredientCompletion: @escaping (Array<PresentIngredientsData>) -> Void) {
// completion: @escaping (FridgeData) -> Void
    guard let currentUserId = Auth.auth().currentUser?.uid else {
        print("登入狀態有問題")
        return
    }
    let users = Firestore.firestore().collection("users")
    let document = users.document(currentUserId)
    
    document.getDocument { (document, error) in
        if let error = error {
            print("獲取使用者資料有問題： \(error)")
            return
        }
        guard let document = document, document.exists else {
            print("使用者資料不存在！")
            return
        }
        guard let data = document.data() else {
            print("獲取資料失敗！")
            return
        }
        guard let lastUseFridgeId = data["last_use_fridge"] as? String else {
            print("獲取最後使用冰箱失敗")
            return
        }
        let fridges = Firestore.firestore().collection("fridges")
        let query = fridges.whereField("id", isEqualTo: lastUseFridgeId)
        
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
            // 獲取最後使用的冰箱文檔資料
            let document = documents[0]
            let fridgeData = document.data()
            guard let id = fridgeData["id"] as? String,
                  let name = fridgeData["name"] as? String,
                  let createdTime = fridgeData["created_time"] as? Double else {
                print("冰箱文檔發生錯誤")
                return
            }
            fridgeCompletion(FridgeData(id: id, name: name, createdTime: createdTime), lastUseFridgeId)
            print("使用者當前冰箱資料： \(fridgeData)")
            
            getMembers(lastUseFridgeId) { memberData in
                memberCompletion(memberData)
            }
            getIngredients(lastUseFridgeId) { ingredientData in
                ingredientCompletion(ingredientData)
            }
            
        }
    }
}
// 獲得冰箱成員資料
private func getMembers(_ fridgeId: String, completion: @escaping (Array<MemberData>) -> Void) {
    let members = Firestore.firestore().collection("fridges").document(fridgeId).collection("members")
    
    members.getDocuments { (documents, error) in
        if let error = error {
            print("查詢成員時出錯：\(error.localizedDescription)")
        }
        guard let documents = documents, !documents.isEmpty else {
            print("members資料不存在！")
            return
        }
        var fridgeMember: [MemberData] = []
        for document in documents.documents {
            let memberData = document.data()
            guard let id = memberData["id"] as? String else {
                print("型態轉換失敗")
                return
            }
            let newFridge = MemberData(id: id)
            fridgeMember.append(newFridge)
        }
        print("當前冰箱成員：\(fridgeMember)")
        completion(fridgeMember)
    }
}
// 獲得冰箱食材資料
private func getIngredients(_ fridgeId: String, completion: @escaping (Array<PresentIngredientsData>) -> Void) {
    let fridgeIngredients = Firestore.firestore().collection("fridges").document(fridgeId).collection("ingredients")
    
    fridgeIngredients.getDocuments { (documents, error) in
        if let error = error {
            print("查詢成員時出錯：\(error.localizedDescription)")
        }
        guard let documents = documents, !documents.isEmpty else {
            print("Fridge_ingredients資料不存在！")
            return
        }
        
        let semaphore = DispatchSemaphore(value: 1)
        let queue = DispatchQueue.global(qos: .background)
        
        var allIngredientsID: [String] = []
        for document in documents.documents {
            let ingredientData = document.data()
            guard let id = ingredientData["ingredients_id"] as? String else {
                print("型態轉換失敗: 食材")
                return
            }
            allIngredientsID.append(id)
        }
        
        let ingredients = Firestore.firestore().collection("ingredients")
        let query = ingredients.whereField("ingredients_id", in: allIngredientsID)
        
        query.getDocuments { (documents, error) in
            var fridgeIngredients: [PresentIngredientsData] = []
            guard let documents = documents else {
                print("ingredients資料不存在！")
                return
            }
            for document in documents.documents {
                let ingredientsData = document.data()

                guard let ingredientsID = ingredientsData["ingredients_id"] as? String,
                      let ingredientsName = ingredientsData["name"] as? String,
                      let ingredientsPrice = ingredientsData["price"] as? Double,
                      let ingredientsStoreStatus = ingredientsData["store_status"] as? Int,
                      let ingredientsUrl = ingredientsData["url"] as? String,
                      let ingredientsCreatedTime = ingredientsData["created_time"] as? Double,
                      let ingredientsEnableNotifications = ingredientsData["enable_Notification"] as? Bool,
                      let ingredietnsExpiration = ingredientsData["expiration"] as? Timestamp,
                      let ingredientsDescription = ingredientsData["describe"] as? String else {
                    print("食材資料獲取失敗")
                    continue
                }
                let newIngredients = PresentIngredientsData(
                    barcode: ingredientsData["barcode"] as? String,
                    ingredientsID: ingredientsID,
                    name: ingredientsName,
                    price: ingredientsPrice,
                    storeStatus: ingredientsStoreStatus,
                    url: ingredientsUrl,
                    createdTime: ingredientsCreatedTime,
                    enableNotifications: ingredientsEnableNotifications,
                    expiration: ingredietnsExpiration.dateValue(),
                    description: ingredientsDescription
                )
                fridgeIngredients.append(newIngredients)
            }
            print("符合食材結果：\(fridgeIngredients)")
            completion(fridgeIngredients)
        }
    }
}
