//
//  searchUser.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/31.
//

import Foundation
import Firebase

func searchUser(_ fridegeID: String, _ email: String, successCompletion: @escaping (MemberData) -> Void, fallCompletion: @escaping () -> Void) {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
        print("登入狀態有問題")
        return
    }
    
    let fridges = Firestore.firestore().collection("fridges")
    let fridgesDoc = fridges.document(fridegeID)
    let members = fridgesDoc.collection("members")
    
    members.getDocuments { (documentSnapshot, error) in
        if error != nil {
            return
        }
        guard let documents = documentSnapshot?.documents else { return }
        var fridgeMemberIDArray: [String] = []
        
        for document in documents {
            let data = document.data()
            guard let id = data["id"] as? String else { return }
            fridgeMemberIDArray.append(id)
        }
        print("當前冰箱成員：\(fridgeMemberIDArray)")
        searchUserByCondition(fridgeMemberIDArray,
                              currentUserId,
                              email,
                              successCompletion,
                              fallCompletion)
    }
    
}

private func searchUserByCondition(_ fridgeMemberID: [String], _ currentUserId: String, _ email: String, _ successCompletion: @escaping (MemberData) -> Void, _ fallCompletion: @escaping () -> Void) {
    let users = Firestore.firestore().collection("users")
    let usersQuery = users.whereField("email", isEqualTo: email)
                          .whereField("id", notIn: fridgeMemberID)
    usersQuery.getDocuments { (documentSnapshot, error) in
        if error != nil {
            return
        }
        guard let documents = documentSnapshot?.documents else { return }
        
        var userDataArray: [MemberData] = []
        for document in documents {
            let data = document.data()
            guard let email = data["email"] as? String,
                  let id = data["id"] as? String,
                  let joinFridges = data["join_fridges"] as? [String],
                  let ownFridge = data["own_fridges"] as? [String],
                  let name = data["name"] as? String else { return }
            let searchUser = MemberData(email: email,
                                        id: id,
                                        joinFridges: joinFridges,
                                        ownFridge: ownFridge,
                                        name: name)
            userDataArray.append(searchUser)
        }
        if userDataArray.isEmpty {
            fallCompletion()
        } else {
            successCompletion(userDataArray[0])
        }
    }
}
