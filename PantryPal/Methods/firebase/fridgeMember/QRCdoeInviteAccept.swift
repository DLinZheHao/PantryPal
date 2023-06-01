//
//  QRCdoeInviteAccept.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/1.
//

import Foundation
import Firebase

func qrCodeInviteAccpet(_ fridgeID: String, successCompletion: @escaping () -> Void, fallCompletion: @escaping () -> Void, fall2Completion: @escaping () -> Void) {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
        print("登入狀態有問題")
        return
    }
    
    let fridges = Firestore.firestore().collection("fridges")
    let fridgesDoc = fridges.document(fridgeID)
    let members = fridgesDoc.collection("members")
    let membersQuery = members.whereField("id", isEqualTo: currentUserId)
    
    membersQuery.getDocuments { (querySnapshot, error) in
        if error != nil {
            return
        }
        guard let documents = querySnapshot?.documents else { return }
        
        var result: [String] = []
        
        for document in documents {
            let data = document.data()
            guard let id = data["id"] as? String else { return }
            result.append(id)
        }
        if result.isEmpty {
            let inviteRequest = Firestore.firestore().collection("invite_requests")
            let inviteRequestQuery = inviteRequest.whereField("fridge", isEqualTo: fridgeID).whereField("receiver", isEqualTo: currentUserId)
            
            inviteRequestQuery.getDocuments { (querySnapshot2, error) in
                if error != nil {
                    return
                }
                guard let inviteDocuments = querySnapshot2?.documents else { return }
                var result2: [String] = []
                for document in inviteDocuments {
                    let data = document.data()
                    guard let id = data["fridge"] as? String else { return }
                    result2.append(id)
                }
                if result2.isEmpty {
                    qrCodeAcceptInvite(fridgeID, currentUserId, completion: successCompletion)
                } else {
                    fall2Completion()
                }
            }
        } else {
            // 跳提示: 用戶已在該冰箱群組
            fallCompletion()
        }
    }
    
}
private func qrCodeAcceptInvite(_ fridgeID: String, _ userID: String, completion: @escaping () -> Void) {
   
    let fridges = Firestore.firestore().collection("fridges")
    let fridgesDoc = fridges.document(fridgeID)
    let members = fridgesDoc.collection("members")
    let membersDocument = members.document(userID)
    
    let userIdData: [String: Any] = [
        "id": userID
    ]
    membersDocument.setData(userIdData)
    
    let users = Firestore.firestore().collection("users")
    let usersDoc = users.document(userID)
    
    usersDoc.getDocument { (documentSnapshot, error) in
        if error != nil {
            return
        }
        guard var data = documentSnapshot?.data() else { return }
        guard var joinFridges = data["join_fridges"] as? [String] else { return }
        
        joinFridges.append(fridgeID)
        data["last_use_fridge"] = fridgeID
        data["join_fridges"] = joinFridges
        usersDoc.setData(data, merge: true) { error in
            if let error = error {
                // 在此處理錯誤
                print("更新文檔數據時出錯：\(error.localizedDescription)")
            } else {
                // 文檔數據更新成功
                print("文檔數據更新成功")
                completion()
            }
        }
    }
}
