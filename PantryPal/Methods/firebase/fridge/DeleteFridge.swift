//
//  DeleteFridge.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/29.
//

import Firebase
func deleteFridge(_ fridgeID: String, completion: @escaping () -> Void) {

    let fridge = Firestore.firestore().collection("fridges")
    let fridgeDoc = fridge.document(fridgeID)
    let fridgeIngredients = fridgeDoc.collection("ingredients")
    
    let group = DispatchGroup()
    
    // 搜尋冰箱食材資料
    group.enter()
    fridgeIngredients.getDocuments { (querySnapshot, error) in
        if let error = error {
            print("冰箱開發錯誤！： \(error)")
            return
        }
        // 获取冰箱中的所有食材文档
        guard let documents = querySnapshot?.documents else {
            print("冰箱開發錯誤！ 獲取不到資料")
            return
        }
        var ingredientsIDArray: [String] = []
        
        for document in documents {
            let data = document.data()
            guard let ingredientID = data["ingredients_id"] as? String else {
                print("資料轉換！")
                return
            }
            ingredientsIDArray.append(ingredientID)
        }
        
        let ingredients = Firestore.firestore().collection("ingredients")
        if ingredientsIDArray.isEmpty == true {
            // 集合為空，不執行查詢操作
            print("空的")
            group.leave()
        } else {
            let ingredientsQuery = ingredients.whereField("ingredients_id", in: ingredientsIDArray)
            // 刪除所有參與食材資料
            ingredientsQuery.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("获取查询结果时出错：\(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("查询结果为空")
                    return
                }
                let batch = Firestore.firestore().batch()
                for document in documents {
                    batch.deleteDocument(document.reference)
                }
                
                // 删除查询结果中的文档
                batch.commit { (error) in
                    if let error = error {
                        print("批量删除文档时出错：\(error.localizedDescription)")
                    } else {
                        print("文档批量删除成功")
                    }
                    group.leave()
                }
            }
        }
    }
    group.enter()
    let fridgeMembers = fridgeDoc.collection("members")
    // 搜尋冰箱成員資料
    fridgeMembers.getDocuments { (querySnapshot, error) in
        if let error = error {
            print("冰箱開發錯誤！： \(error)")
            return
        }
        // 获取冰箱中的所有食材文档
        guard let documents = querySnapshot?.documents else {
            print("冰箱開發錯誤！ 獲取不到資料")
            return
        }
        var memberIDArray: [String] = []
        
        for document in documents {
            let data = document.data()
            guard let ingredientID = data["id"] as? String else {
                print("資料轉換！")
                return
            }
            memberIDArray.append(ingredientID)
        }
        
        let users = Firestore.firestore().collection("users")

        // 遍历参与冰箱的用户数组
        for userID in memberIDArray {
            let userRef = users.document(userID)
            
            // 更新用户文档，从参与冰箱数组中移除要删除的冰箱
            userRef.updateData(["join_fridges": FieldValue.arrayRemove([fridgeID])]) { error in
                if let error = error {
                    print("更新用户文档时出错：\(error.localizedDescription)")
                } else {
                    print("用户文档更新成功")
                }
            }
            userRef.updateData(["own_fridges": FieldValue.arrayRemove([fridgeID])]) { error in
                if let error = error {
                    print("更新用户文档时出错：\(error.localizedDescription)")
                } else {
                    print("用户文档更新成功")
                }
            }
        }
        group.leave()
    }
    group.enter()
    
    fridgeDoc.delete { error in
        if let error = error {
            print("移除冰箱文档时出错：\(error.localizedDescription)")
        } else {
            print("冰箱文档删除成功")
        }
        group.leave()
    }
}
