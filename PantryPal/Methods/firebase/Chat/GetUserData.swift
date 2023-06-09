//
//  getUserData.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/9.
//

import Foundation
import Firebase

func getUserData(completion: @escaping (String, String) -> Void) {
    guard let currentUserID = Auth.auth().currentUser?.uid else { return }
    let users = Firestore.firestore().collection("users")
    let userDoc = users.document(currentUserID)
    
    userDoc.getDocument { (documentSnapshot, error) in
        if error != nil {
            return
        }
        guard let data = documentSnapshot?.data() else { return }
        guard let userName = data["name"] as? String,
              let userID = data["id"] as? String else { return }
        completion(userName, userID)
    }
}
