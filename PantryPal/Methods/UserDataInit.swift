//
//  UserDataInit.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/23.
//

import Foundation
import Firebase

func userDataInit(email: String, name: String) {
    print("資料傳入資料庫")
    guard let currentUserId = Auth.auth().currentUser?.uid else {
          print("登入狀態有問題")
          return
      }
    
    let articles = Firestore.firestore().collection("users")

    let document = articles.document(currentUserId)

    let data: [String: Any] = [
        "eamil": email,
        "id": currentUserId,
        "name": name,
        "own_fridges": [],
        "join_fridges": []
    ]
    document.setData(data)
}
