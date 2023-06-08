//
//  getChatMessage.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/7.
//

import Foundation
import Firebase

func getChatMessage(completion: @escaping ([MessageData]) -> Void) {
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
        guard let lastUseFridgeId = data["last_use_fridge"] as? String else {
            print("獲取最後使用冰箱失敗")
            return
        }
        let fridges = Firestore.firestore().collection("fridges")
        let fridgeDoc = fridges.document(lastUseFridgeId)
        let chatMessages = fridgeDoc.collection("chat_messages").order(by: "sendDate")
        
        chatMessages.addSnapshotListener { (documentSnapshot, error) in
            if error != nil { return }
            guard let documents = documentSnapshot?.documents else { return }
            
            var messageArray: [MessageData] = []
            for document in documents {
                let data = document.data()
                guard let action = data["action"] as? Int,
                      let id = data["id"] as? String,
                      let sendDate = data["sendDate"] as? Double,
                      let senderID = data["senderID"] as? String,
                      let textContent = data["text_content"] as? String,
                      let url = data["url"] as? String,
                      let name = data["name"] as? String else { return }
                let message = MessageData(name: name,
                                          action: action,
                                          id: id,
                                          sendDate: sendDate,
                                          senderID: senderID,
                                          textContent: textContent,
                                          url: url,
                                          isImageLoad: false)
                messageArray.append(message)
            }
            completion(messageArray)
        }
    }
}
