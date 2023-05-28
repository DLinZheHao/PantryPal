//
//  UNUserNotificationCenter.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/27.
//

import Foundation
import UserNotifications

func notificationRegister(_ date: Date, _ itemName: String, _ itemID: String) {
    // 生成通知內容的物件
    let content = UNMutableNotificationContent()
    // 設定通知的標題、主旨、內容
    content.title = "食材過期提醒"
    content.subtitle = itemName
    content.body = "明日過期．記得處理"
    content.sound = UNNotificationSound.default
    
    // 設置日曆組件
    let calendar = Calendar.current
    let previousDate = calendar.date(byAdding: .day, value: -1, to: date)
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    let request = UNNotificationRequest(identifier: itemID, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
        print("成功建立通知...")
    })

}
func notificationDelete(_ itemID: String) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [itemID])
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [itemID])
}
