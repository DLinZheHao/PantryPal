//
//  ImageDownloader.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/13.
//

import Foundation
import UIKit

class ImageDownloader {
    static let shared = ImageDownloader()
    private let cache = URLCache.shared

    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let request = URLRequest(url: url)
        
        if let cachedResponse = cache.cachedResponse(for: request) {
            // 如果图像已经被缓存，直接从缓存中获取
            let image = UIImage(data: cachedResponse.data)
            print("使用緩存")
            completion(image)
        } else {
            // 如果图像未被缓存，使用 URLSession 下载图像
            URLSession.shared.dataTask(with: request) { [weak self] (data, response, _) in
                guard let self = self, let data = data, let response = response else {
                    completion(nil)
                    return
                }
                
                let image = UIImage(data: data)
                
                // 将下载的图像存入缓存
                let cachedResponse = CachedURLResponse(response: response, data: data)
                self.cache.storeCachedResponse(cachedResponse, for: request)
                
                DispatchQueue.main.async {
                    print("使用下載")
                    completion(image)
                }
            }.resume()
        }
    }
}
