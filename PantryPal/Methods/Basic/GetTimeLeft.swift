//
//  GetTimeLeft.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/28.
//

import Foundation

func getRemainingTime(_ futureDate: Date) -> String {
    let calendar = Calendar.current
    let currentDate = Date()

    let components = calendar.dateComponents([.day, .hour], from: currentDate, to: futureDate)

    if let remainingDays = components.day, let remainingHours = components.hour {
        if remainingDays > 0 {
            return "剩餘時間: \(remainingDays)天 \(remainingHours)小時"
        } else if remainingHours > 0 {
            return "剩餘時間: \(remainingHours)小時"
        } else {
            return "已過期"
        }
    } else {
        return "已過期"
    }
}

