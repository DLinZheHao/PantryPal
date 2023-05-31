//
//  generateQRCode.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/31.
//

import Foundation
import UIKit

func generateQRCode(from text: String) -> UIImage? {
    let data = text.data(using: String.Encoding.ascii)
    
    if let filter = CIFilter(name: "CIQRCodeGenerator") {
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        if let output = filter.outputImage?.transformed(by: transform) {
            let context = CIContext()
            if let cgImage = context.createCGImage(output, from: output.extent) {
                let qrCodeImage = UIImage(cgImage: cgImage)
                print("成功產出qr code")
                return qrCodeImage
            }
        }
    }
    print("失敗產出 qr code")
    return nil
}
