//
//  FridgeMemberAddInvite.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/31.
//

import Foundation
import Firebase

func fridgeMemberAddInvite(_ receiverID: String,
                           _ fridgeID: String,
                           _ controller: UIViewController,
                           _ button: UIButton,
                           completion: @escaping () -> Void) {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
        print("登入狀態有問題")
        return
    }
    
    let fridges = Firestore.firestore().collection("fridges")
    let fridgeDoc = fridges.document(fridgeID)
    
    fridgeDoc.getDocument { (documentSnapshot, error) in
        if error != nil {
            return
        }
        guard let data = documentSnapshot?.data() else { return }
        guard let fridgeName = data["name"] as? String else { return }
        
        let inviteRequest = Firestore.firestore().collection("invite_requests")
        let inviteRequestQuery = inviteRequest.whereField("fridge", isEqualTo: fridgeID).whereField("receiver", isEqualTo: receiverID)
        
        inviteRequestQuery.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error retrieving documents: \(error)")
            } else {
                if querySnapshot?.isEmpty == true {
                    let document = inviteRequest.document()
                    
                    let data: [String: Any] = [
                        "sender": currentUserId,
                        "receiver": receiverID,
                        "fridge": fridgeID,
                        "created_time": Date().timeIntervalSince1970,
                        "status": 0,
                        "fridge_name": fridgeName
                    ]
                    document.setData(data) { _ in
                        completion()
                    }
                } else {
                    alert("已經有成員發出邀請", controller)
                    button.isHidden = true
                }
            }
        }
        
    }
    
    
}
