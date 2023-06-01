//
//  GetAllInvite.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/31.
//

import Foundation
import Firebase

func getAllInvite(completion: @escaping ([InviteData]) -> Void) {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
        print("登入狀態有問題")
        return
    }
    let inviteRequest = Firestore.firestore().collection("invite_requests")
    let inviteRequestQuery = inviteRequest.whereField("receiver", isEqualTo: currentUserId).whereField("status", isEqualTo: 0).order(by: "created_time")
    
    inviteRequestQuery.getDocuments { (querySnapshot, error) in
        if error != nil {
            print("發生錯誤：\(error)")
            return
        }
        guard let documents = querySnapshot?.documents else {
            print("轉換失敗")
            return }
        
        var inviteArray: [InviteData] = []
        for document in documents {
            let data = document.data()
            guard let sender = data["sender"] as? String,
                  let receiver = data["receiver"] as? String,
                  let fridge = data["fridge"] as? String,
                  let createdTime = data["created_time"] as? Double,
                  let status = data["status"] as? Int,
                  let fridgeName = data["fridge_name"] as? String else { return }
            let invite = InviteData(sender: sender,
                                    receiver: receiver,
                                    fridge: fridge,
                                    createdTime: createdTime,
                                    status: status,
                                    fridgeName: fridgeName)
            inviteArray.append(invite)
        }
        completion(inviteArray)
    }
}
