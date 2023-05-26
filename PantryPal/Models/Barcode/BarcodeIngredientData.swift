//
//  IngredientData.swift
//  barcode_scan
//
//  Created by 林哲豪 on 2023/5/20.
//

import Foundation
import UIKit

struct ErrorResponse: Codable {
    var msg: String
    var code: Int
}

struct SuccessResponse: Codable {
    var code: Int
    var msg: String
    var data: DetailData
}

struct DetailData: Codable {
    var goodsName: String
    var barcode: String
    var price: String
    var brand: String
    var supplier: String
    var standard: String
}
