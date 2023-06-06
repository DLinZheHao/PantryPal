//
//  changeFridgeName.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/6.
//

import Foundation
import Firebase

func changeFridgeName(_ fridgeID: String, _ newFridgeName: String, _ completion: @escaping () -> Void) {
    let fridges = Firestore.firestore().collection("fridges")
    let fridgeDoc = fridges.document(fridgeID)
    fridgeDoc.updateData(["name": newFridgeName]) { error in
        if let error = error {
            print("更新失敗：\(error)")
        } else {
            print("更新成功")
            completion() 
        }
    }
    
}
