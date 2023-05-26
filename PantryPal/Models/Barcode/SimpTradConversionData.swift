//
//  SimpTradConversionData.swift
//  barcode_scan
//
//  Created by 林哲豪 on 2023/5/21.
//

import Foundation

struct SimpTradConversionData: Codable {
    var code: Int
    var data: ConversionData
}

struct ConversionData: Codable {
    var originContent: String
    var convertContent: String
}
