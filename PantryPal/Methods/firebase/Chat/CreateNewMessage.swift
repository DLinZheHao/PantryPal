//
//  CreateNewMessage.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/7.
//

import Foundation
import Firebase

func createNewMessage(url: String = "", textContent: String = "", action: Int) {
    guard let currentUserID = Auth.auth().currentUser?.uid else { return }
    let users = Firestore.firestore().collection("users")
    let userDoc = users.document(currentUserID)
    
    userDoc.getDocument { (document, error) in
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
        guard let lastUseFridgeId = data["last_use_fridge"] as? String,
              let userName = data["name"] as? String else {
            print("獲取最後使用冰箱失敗")
            return
        }
        let fridges = Firestore.firestore().collection("fridges")
        let fridgeDoc = fridges.document(lastUseFridgeId)
        let chatMessages = fridgeDoc.collection("chat_messages")
        let chatMessageDoc = chatMessages.document()
        
        let userIdData: [String: Any] = [
            "name": userName,
            "id": chatMessageDoc.documentID,
            "url": url,
            "senderID": currentUserID,
            "text_content": textContent,
            "action": action,
            "sendDate": Date().timeIntervalSince1970
        ]
        chatMessageDoc.setData(userIdData)
    }
}
