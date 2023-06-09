//
//  CheckDayDateExist.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/9.
//

import Foundation
import Firebase

func checkDayDateExist(completion: @escaping (Set<Date>) -> Void) {

    guard let currentUserID = Auth.auth().currentUser?.uid else { return }
    
    let users = Firestore.firestore().collection("users")
    let userDoc = users.document(currentUserID)
    
    userDoc.getDocument { (documentSnapshot, error) in
        if error != nil {
            return
        }
        guard let data = documentSnapshot?.data() else { return }
        guard let fridgeID = data["last_use_fridge"] as? String else { return }
        
        let fridges = Firestore.firestore().collection("fridges")
        let fridgeDoc = fridges.document(fridgeID)
        let historyIngreidents = fridgeDoc.collection("history_ingredients")
        // 读取数据
        historyIngreidents.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            } else {
                // 创建一个集合来存储日期
                var uniqueDates: Set<Date> = Set()
                
                // 遍历查询快照
                for document in querySnapshot!.documents {
                    // 将文档数据转换为数据模型对象
                    let data = document.data()
                    // 解析数据
                    print("實驗數據：\(data)")
                    if let actionDayTimestamp = data["action_time"] as? Double {
                        // 将时间戳转换为Date类型
                        let actionDay = Date(timeIntervalSince1970: actionDayTimestamp)
                        // 将日期添加到集合中
                        uniqueDates.insert(actionDay)
                    }
                }
                
                // 在这里可以使用uniqueDates集合进行进一步处理或展示
                print("實驗結果：\(uniqueDates)")
                completion(uniqueDates)
            }
        }
    }
}
