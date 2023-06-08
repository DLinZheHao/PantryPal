//
//  findNewMessage.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/8.
//

import Foundation
func findNewMessages(existingMessages: [MessageData], newMessages: [MessageData]) -> [MessageData] {
    let existingMessageIDs = Set(existingMessages.map { $0.id })
    
    // 過濾出在 newMessages 中但不在 existingMessages 中的消息
    let newMessagesFiltered = newMessages.filter { !existingMessageIDs.contains($0.id) }
    
    return newMessagesFiltered
}
