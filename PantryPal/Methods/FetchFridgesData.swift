//
//  FetchFridgesData.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//

import UIKit
import Firebase

func fetchFridgeData() {

    let frideges = Firestore.firestore().collection("fridges")
//    articles.order(by: "createdTime")
//        .getDocuments { (querySnapshot, error) in
//            articlesData = []
//            if error != nil {
//                print("Articles fetch ERROR！")
//                completion(nil) // 调用回调并传递 nil 表示出错
//                return
//            }
//            guard let snapshotDocuments = querySnapshot?.documents else {
//                completion(nil) // 调用回调并传递 nil 表示出错
//                return
//            }
//            for doc in snapshotDocuments {
//                let data = doc.data()
//                if let articleAuthor = data["author"] as? [String: String],
//                   let articleTitle = data["title"] as? String,
//                   let articleContent = data["content"] as? String,
//                   let articleCreatedTime = data["createdTime"] as? Double,
//                   let articleCategory = data["category"] as? String {
//                    guard let name = articleAuthor["name"] else {
//                        completion(nil) // 调用回调并传递 nil 表示出错
//                        return
//                    }
//                    
//                    let authorDetail = AuthorDetail(name: name)
//                    let article = Article(author: authorDetail, title: articleTitle, content: articleContent, createdTime: articleCreatedTime, category: articleCategory)
//                    articlesData.append(article)
//                    
//                } else {
//                    print("ERROR")
//                }
//            }
//            let newDataOnTop = Array(articlesData.reversed())
//            completion(newDataOnTop) // 调用回调并传递结果
//        }
}
