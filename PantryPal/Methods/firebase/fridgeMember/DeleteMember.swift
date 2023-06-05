//
//  DeleteMember.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/1.
//

import Foundation
import Firebase

func deleteMember(_ controller: UIViewController, _ fridgeID: String, _ userID: String, successCompletion: @escaping () -> Void) {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
        print("登入狀態有問題")
        return
    }
    let users = Firestore.firestore().collection("users")
    let userDoc = users.document(currentUserId)
    
    
    userDoc.getDocument { (documentSnapshot, error) in
        if error != nil {
            return
        }
        guard let data = documentSnapshot?.data() else { return }
        
        var ownfridgeArray: [String] = []
        guard let ownFridgesData = data["own_fridges"] as? [String] else { return }
        
        ownfridgeArray = ownFridgesData
        
        if currentUserId == userID {
            alert("不能刪除自己", controller)
            print("不能刪除自己")
            return
        }
        
        if ownfridgeArray.contains(fridgeID) {
            deleteTargetMember(userID, fridgeID)
            deleteFridgeUser(userID, fridgeID, completion: successCompletion)
            deleteInviteRequest(userID, currentUserId)
        } else {
            alert("不是冰箱擁有者，不能進行成員刪除", controller)
            print("不是冰箱擁有者，不能進行成員刪除")
        }
        
    }
}

private func deleteTargetMember(_ targetUserID: String, _ fridgeID: String) {
    let users = Firestore.firestore().collection("users")
    let targerUserDoc = users.document(targetUserID)
    
    targerUserDoc.getDocument { (documentSnapshot, error) in
        if error != nil {
            return
        }
        guard var data = documentSnapshot?.data() else { return }
        guard var joinFridgesData = data["join_fridges"] as? [String],
              var lastUseFridge = data["last_use_fridge"] as? String,
              var ownFridgesData = data["own_fridges"] as? [String] else { return }
        
        if lastUseFridge == fridgeID {
            data["last_use_fridge"] = ownFridgesData[0]
        }
        
        joinFridgesData.removeAll { $0 == fridgeID }
        // 將修改後的資料重新寫入屬性
        data["join_fridges"] = joinFridgesData

        // 更新文檔數據
        targerUserDoc.setData(data, merge: true) { error in
            if let error = error {
                // 在此處理錯誤
                print("更新文檔數據時出錯：\(error.localizedDescription)")
            } else {
                // 文檔數據更新成功
                print("文檔數據更新成功")
            }
        }
    }
}
private func deleteFridgeUser(_ targetUserID: String, _ fridgeID: String, completion: @escaping () -> Void) {
    let fridges = Firestore.firestore().collection("fridges")
    let fridgeDoc = fridges.document(fridgeID)
    let members = fridgeDoc.collection("members")
    let targetDocumentRef = members.document(targetUserID)
    
    targetDocumentRef.delete { error in
        if let error = error {
            print("Error deleting document: \(error)")
        } else {
            print("Document deleted successfully")
            completion()
        }
    }
    
}
func deleteInviteRequest(_ receiver: String, _ sender: String) {
    let inviteRequests = Firestore.firestore().collection("invite_requests")
    let query = inviteRequests.whereField("receiver", isEqualTo: receiver).whereField("sender", isEqualTo: sender)
    
    query.getDocuments { (querySnapshot, error) in
        if let error = error {
            print("查詢資料失敗：\(error.localizedDescription)")
            return
        }
        
        guard let querySnapshot = querySnapshot else {
            print("查詢結果為空")
            return
        }
        
        for document in querySnapshot.documents {
            document.reference.delete { (error) in
                if let error = error {
                    print("刪除文件失敗：\(error.localizedDescription)")
                } else {
                    print("刪除文件成功")
                }
            }
        }
    }
}
