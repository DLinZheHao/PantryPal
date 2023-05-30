//
//  getMembers.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/30.
//

import Foundation
import Firebase

func getMembers(_ fridgeID: String, completion: @escaping ([MemberData]) -> Void) {
    let fridge = Firestore.firestore().collection("fridges")
    let fridgeDoc = fridge.document(fridgeID)
    
    let members = fridgeDoc.collection("members")
    members.getDocuments { (document, error) in
        if error != nil {
            print("成員資料獲取失敗")
            return
        }
        guard let documents = document?.documents else {
            print("成員資料獲取失敗")
            return
        }
        var memberIDArray: [String] = []
        for document in documents {
            let data = document.data()
            guard let id = data["id"] as? String else {
                print("成員id 轉換失敗")
                return
            }
            memberIDArray.append(id)
        }
        
        let users = Firestore.firestore().collection("users")
        if !memberIDArray.isEmpty {
            let usersQuery = users.whereField("id", in: memberIDArray)
            usersQuery.getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("獲取資料失敗")
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("確保失敗")
                    return
                }
                var memberData: [MemberData] = []
                for document in documents {
                    let data = document.data()
                    guard let email = data["email"] as? String,
                          let id = data["id"] as? String,
                          let joinFridges = data["join_fridges"] as? [String],
                          let ownFridges = data["own_fridges"] as? [String],
                          let name = data["name"] as? String else {
                        print("資料準備失敗")
                        return
                    }
                    let member = MemberData(email: email,
                                             id: id,
                                             joinFridges: joinFridges,
                                             ownFridge: ownFridges,
                                             name: name)
                    memberData.append(member)
                }
                completion(memberData)
            }
            
        } else {
            print("這是空的")
        }
        
        
    }
}
