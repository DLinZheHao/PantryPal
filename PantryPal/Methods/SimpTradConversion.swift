//
//  SimpTradConversion.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/26.
//
import UIKit

func simpTradConversion(_ words: String, completion: @escaping ((String) -> Void)) {
    print("開始操作")
    guard let encodedContent = words.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
    guard let url = URL(string: "https://www.mxnzp.com/api/convert/zh?content=\(encodedContent)&type=1&app_id=xspmnogghrhqccyp&app_secret=WjIzQ1lJMEFWQWVyZ3JUWDZ2Wnowdz09") else {
            print("URL 出現錯誤")
        return
        
    }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        do {
            if let data = data {
                let jsonDecoder = JSONDecoder()
                let returnJsonDate = try jsonDecoder.decode(SimpTradConversionData.self, from: data)

                // print(returnJsonDate.code)
                //print(returnJsonDate.data.convertContent)
                completion(returnJsonDate.data.convertContent)
            }
        } catch {
            print("HTTP Request Error: \(error)")
        }
        
    }
    task.resume()
    
}
