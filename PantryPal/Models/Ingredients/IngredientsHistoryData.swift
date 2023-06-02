//
//  IngredientsHistoryData.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/2.
//

import Foundation

struct IngredientsHistoryData {
    let barcode: String?
    let ingredientsID: String
    let name: String
    let price: Double
    let storeStatus: Int
    let url: String
    let createdTime: Double
    let enableNotifications: Bool
    let expiration: Date
    let description: String
    let action: Int
}

struct IngredientsHistoryPresentData {
    let barcode: String
    let ingredientsID: String
    let name: String
    let price: Double
    let storeStatus: Int
    let url: String
    let createdTime: Double
    let expiration: Date
    let description: String
    let action: Int
}



