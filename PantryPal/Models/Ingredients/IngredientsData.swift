//
//  IngredientsData.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//
import UIKit

struct PresentIngredientsData {
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
}

struct DatabaseIngredientsData {
    let barcode: String?
    let name: String
    let price: Double
    let storeStatus: Int
    let url: String
    let enableNotification: Bool
    let describe: String
    let expiration: Date
    let belongFridge: String
}
