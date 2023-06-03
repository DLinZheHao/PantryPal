//
//  StoreStatus.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/3.
//

import Foundation

enum StoreStatus: String {
    case refrigerated = "冷藏"
    case freezer = "冷凍"
    case roomTemperature = "常溫"
    
    static func getStatus(input: Int) -> String {
        switch input {
        case 0:
            let value = StoreStatus.freezer.rawValue
            return value
        case 1:
            let value = StoreStatus.refrigerated.rawValue
            return value
        case 2:
            let value = StoreStatus.roomTemperature.rawValue
            return value
        default:
            return "發生問題"
        }
    }
}

enum ActionStatus: String {
    case runOut = "用完"
    case expired = "過期"
    case throwAway = "丟棄"
    
    static func getStatus(input: Int) -> String {
        switch input {
        case 0:
            let value = ActionStatus.runOut.rawValue
            return value
        case 1:
            let value = ActionStatus.expired.rawValue
            return value
        case 2:
            let value = ActionStatus.throwAway.rawValue
            return value
        default:
            return "發生問題"
        }
    }
}
