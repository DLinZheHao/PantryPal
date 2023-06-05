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


//func isSameDay(timeInterval: TimeInterval, referenceDate: Date) -> Bool {
//    let date = Date(timeIntervalSince1970: timeInterval)
//
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy年MM月dd日"
//
//    let dateString = dateFormatter.string(from: date)
//    let referenceDateString = dateFormatter.string(from: referenceDate)
//
//    print("\(dateString) 與 \(referenceDateString)")
//    return dateString == referenceDateString
//}
//func isSameDay(timeInterval: TimeInterval, referenceDate: Date) -> Bool {
//    let date = Date(timeIntervalSince1970: timeInterval)
//
//    let calendar = Calendar.current
//    return calendar.isDate(date, inSameDayAs: referenceDate)
//}

//func isSameDay(timeInterval: TimeInterval, referenceDate: Date) -> Bool {
//    let date = Date(timeIntervalSince1970: timeInterval)
//
//    let calendar = Calendar.current
//    let components = calendar.dateComponents([.year, .month, .day], from: date)
//    let referenceComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
//
//    return components.year == referenceComponents.year &&
//           components.month == referenceComponents.month &&
//           components.day == referenceComponents.day
//}
