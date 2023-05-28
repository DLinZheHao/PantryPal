//
//  GetTimeLeft.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/28.
//

import Foundation

func getLeftTime(_ futureDate: Date) -> String {
    let remainingTime = futureDate.timeIntervalSinceNow

    if remainingTime > 0 {
        let remainingHours = Int(remainingTime / (60 * 60))
        let remainingMinutes = Int((remainingTime.truncatingRemainder(dividingBy: (60 * 60))) / 60)
        let remainingSeconds = Int(remainingTime.truncatingRemainder(dividingBy: 60))

        //print("剩餘時間: \(remainingHours)小時 \(remainingMinutes)分鐘 \(remainingSeconds)秒")
        return "剩餘時間: \(remainingHours)小時 \(remainingMinutes)分鐘 "
    } else {
        //print("指定時間已過")
        return "已過期"
    }

}
