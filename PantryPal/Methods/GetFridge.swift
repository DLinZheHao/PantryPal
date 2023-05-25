//
//  GetFridge.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//

import UIKit
import Firebase

func getFridge(_ id: String) {
    let fridges = Firestore.firestore().collection("fridges")
    let query = fridges.whereField("id", isEqualTo: id)
    
    query.getDocuments { (snapshot, error) in
        if let error = error {
            print("查询文档时出现错误：\(error.localizedDescription)")
        }
        guard let documents = snapshot?.documents else {
            print("沒有找到符合結果文檔")
            return
        }
        
        for document in documents {
            let data = document.data()
            print("目標冰箱\(data)")
        }
    }
}

