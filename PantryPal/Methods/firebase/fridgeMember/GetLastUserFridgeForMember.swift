//
//  getUserLastFridgeForMember.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/31.
//

import Foundation
import Firebase

func userLastUseFridgeForMember(addCompletion: @escaping (FridgeData) -> Void, manageClosure: @escaping ([MemberData]) -> Void) {
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
        let fridgeDoc = fridges.document(lastUseFridgeId)
        
        fridgeDoc.getDocument { (documentSnapshot, error) in
            if error != nil { return }
            guard let document = documentSnapshot else { return }
            guard let data = document.data() else { return }
            guard let id = data["id"] as? String,
                  let name = data["name"] as? String,
                  let createdTime = data["created_time"] as? Double else { return }
            
            let fridgeData = FridgeData(id: id, name: name, createdTime: createdTime)
            addCompletion(fridgeData)
        }
        
        let members = fridgeDoc.collection("members")
        
        members.getDocuments { (documentSnapshot, error) in
            if let error = error {
                print("查詢用戶時出錯：\(error.localizedDescription)")
                return
            }
            // 檢查查詢結果是否存在
            guard let documents = documentSnapshot?.documents else {
                print("沒有符合條件的用戶")
                return
            }
            // 獲取最後使用的冰箱文檔資料
            var memberIDArray: [String] = []
            for document in documents {
                let data = document.data()
                guard let id = data["id"] as? String else {
                    print("使用者資料獲取失敗")
                    return
                }
                memberIDArray.append(id)
            }
            getMemberForManage(memberIDArray, manageClosure)
        }
    }
}

func getMemberForManage(_ idArray: [String], _ completion: @escaping ([MemberData]) -> Void){
    let users = Firestore.firestore().collection("users")
    let usersQuery = users.whereField("id", in: idArray)
    
    usersQuery.getDocuments { (querySnapshot, error) in
        if let error = error {
            print("查詢用戶時出錯：\(error.localizedDescription)")
            return
        }
        // 檢查查詢結果是否存在
        guard let documents = querySnapshot?.documents else {
            print("沒有符合條件的用戶")
            return
        }
        var usersDataArray: [MemberData] = []
        
        for document in documents {
            let data = document.data()
            guard let email = data["email"] as? String,
                  let id = data["id"] as? String,
                  let joinFridges = data["join_fridges"] as? [String],
                  let ownFridge = data["own_fridges"] as? [String],
                  let name = data["name"] as? String else {
                print("資料確保失敗")
                return
            }
            let user = MemberData(email: email,
                                  id: id,
                                  joinFridges: joinFridges,
                                  ownFridge: ownFridge,
                                  name: name)
            usersDataArray.append(user)
        }
        completion(usersDataArray)
    }
}
