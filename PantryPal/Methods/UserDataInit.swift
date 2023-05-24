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
    let articles = Firestore.firestore().collection("users")

    let document = articles.document()

    let data: [String: Any] = [
        "eamil": email,
        "id": document.documentID,
        "name": name,
        "own_fridges": [],
        "join_fridges": []
    ]
    document.setData(data)
}
