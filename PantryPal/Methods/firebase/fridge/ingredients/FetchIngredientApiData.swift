//
//  FetchIngredientApiData.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/26.
//
import UIKit

func fetchIngredientApiData(_ barcode: String, successCompletion: @escaping ((String, String) -> Void), fallCompletion: @escaping (String) -> Void ) {
    guard let url = URL(string: "https://www.mxnzp.com/api/barcode/goods/details?barcode=\(barcode)&app_id=xspmnogghrhqccyp&app_secret=WjIzQ1lJMEFWQWVyZ3JUWDZ2Wnowdz09") else { return }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        do {
            if let data = data {
                let jsonDecoder = JSONDecoder()
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let code = jsonObject["code"] as? Int {
                        if code == 0 {
                            // 处理错误响应
                            if let msg = jsonObject["msg"] as? String {
                                print("错误信息：\(msg)")
                                fallCompletion(msg)
                            }
                            print("错误代码：\(code)")
                            
                        } else if code == 1 {
                            // 处理成功响应
                            if let dataObject = jsonObject["data"] as? [String: Any],
                               let goodsName = dataObject["goodsName"] as? String,
                               let goodsPrice = dataObject["price"] as? String {
                                print("商品名称：\(goodsName)")
                                // 解码其他属性...
                                successCompletion(goodsName, goodsPrice)
                            }
                        } else {
                            print("无法识别的响应代码")
                        }
                    }
                } else {
                    print("无法解析响应数据")
                }
            }
        } catch {
            print("解码错误：\(error)")
        }
    }
    task.resume()
    
}
