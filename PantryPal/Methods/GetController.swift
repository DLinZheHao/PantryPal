//
//  GetController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//
import UIKit

enum ViewControllerMember: String {
    case FridgeListViewController = "FridgeListViewController"
    
    
    func getViewController() -> UIViewController? {
        switch self {
        // 全部參與冰箱列表
        case .FridgeListViewController:
            return UIStoryboard(name: "FridgeList", bundle: nil).instantiateViewController(withIdentifier: ViewControllerMember.FridgeListViewController.rawValue)
        }
    }
}
