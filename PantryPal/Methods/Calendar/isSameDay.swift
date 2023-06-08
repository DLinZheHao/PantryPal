//
//  isSameDay.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/2.
//

import UIKit
import Foundation

func isSameDay(timeInterval: TimeInterval, date: Date) -> Bool {
    let calendar = Calendar.current
    
    // 將 TimeInterval 轉換為具體日期
    let referenceDate = Date(timeIntervalSince1970: timeInterval)
    
    // 使用 calendar 提取日期元件
    let referenceComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    
    // 比較日期元件是否相等
    return referenceComponents.year == dateComponents.year &&
        referenceComponents.month == dateComponents.month &&
        referenceComponents.day == dateComponents.day
}
func isDateToday(_ date: Date) -> Bool {
    let calendar = Calendar.current
    let today = Date()
    
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
    
    return components.year == todayComponents.year && components.month == todayComponents.month && components.day == todayComponents.day
}
