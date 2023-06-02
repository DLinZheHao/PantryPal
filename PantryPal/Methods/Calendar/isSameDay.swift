//
//  isSameDay.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/2.
//


import Foundation
func isSameDay(timeInterval: TimeInterval, referenceDate: Date) -> Bool {
    let date = Date(timeIntervalSince1970: timeInterval)
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    let referenceComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
    
    return components.year == referenceComponents.year &&
           components.month == referenceComponents.month &&
           components.day == referenceComponents.day
}
