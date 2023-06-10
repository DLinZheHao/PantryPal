//
//  sendChatGPTRequest.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/9.
//

import Foundation

func sendChatGPTRequest(prompt: String, apiKey: String) {
    let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    // 创建请求
    var request = URLRequest(url: apiURL)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // 创建请求体
    let parameters = [
        "prompt": prompt,
        "max_tokens": 50 // 设定生成的回复的最大长度
    ] as [String : Any]
    let requestData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
    request.httpBody = requestData
    
    // 发送请求
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("请求错误：\(error)")
            return
        }
        
        guard let data = data else {
            print("未收到数据")
            return
        }
        
        // 解析响应数据
        if let responseString = String(data: data, encoding: .utf8) {
            print("API响应：\(responseString)")
            // 在这里处理API响应，提取所需的信息
        }
    }
    
    task.resume()
}
