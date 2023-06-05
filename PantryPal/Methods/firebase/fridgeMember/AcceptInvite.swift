//
//  AcceptInvite.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/31.
//

import Foundation
import Firebase

func acceptInvite(_ inviteData: InviteData, completion: @escaping () -> Void) {
    let inviteRequest = Firestore.firestore().collection("invite_requests")
    let inviteRequestQuery = inviteRequest.whereField("sender", isEqualTo: inviteData.sender)
        .whereField("receiver", isEqualTo: inviteData.receiver)
    
    inviteRequestQuery.getDocuments { (querySnapshot, error) in
        if error != nil {
            return
        }
        guard let documents = querySnapshot?.documents else { return }
        
        if documents.count > 1 {
            return
        }
        guard let document = querySnapshot?.documents.first else { return }
        let documentRef = inviteRequest.document(document.documentID)
        
        documentRef.updateData(["status": 1]) { (error) in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document updated successfully")
            }
        }
        
    }
    let users = Firestore.firestore().collection("users")
    let usersDoc = users.document(inviteData.receiver)
    
    usersDoc.getDocument { (documentSnapshot, error) in
        if error != nil {
            return
        }
        guard var data = documentSnapshot?.data() else { return }
        guard var joinFridges = data["join_fridges"] as? [String] else { return }
        
        joinFridges.append(inviteData.fridge)
        data["last_use_fridge"] = inviteData.fridge
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
    let fridges = Firestore.firestore().collection("fridges")
    let fridgeDoc = fridges.document(inviteData.fridge)
    let members = fridgeDoc.collection("members")
    
    // 要新增的文件資料
    let newMemberData: [String: Any] = [
        "id": inviteData.receiver
    ]
    let newMemberRef = members.document(inviteData.receiver)
    // 新增文件到 "members" 集合
    newMemberRef.setData(newMemberData) { (error) in
        if let error = error {
            print("新增文件失敗：\(error.localizedDescription)")
        } else {
            print("新增文件成功")
        }
    }
}
