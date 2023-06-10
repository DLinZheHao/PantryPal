//
//  FridgeTabBar.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//

import UIKit

class FridgeTabBarController: UITabBarController {
    var fridgeId: String?
    private let tabs: [Tab] = [.ingredients, .teamLink, .join, .calendarPage]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = tabs.map { $0.makeViewController() }
        self.tabBar.itemPositioning = .automatic
        delegate = self
    }
}

extension FridgeTabBarController {
    private enum Tab {
        case ingredients
        case teamLink
        case join
        case calendarPage
        
        func makeViewController() -> UIViewController {
            let controller: UIViewController
            switch self {
            case .ingredients:
                controller = UIStoryboard.ingredients.instantiateInitialViewController()!
                controller.tabBarItem = makeTabBarItem("冰箱")
            case .teamLink:
                controller = UIStoryboard.teamLink.instantiateInitialViewController()!
                controller.tabBarItem = makeTabBarItem("管理")
            case .join:
                controller = UIStoryboard.join.instantiateInitialViewController()!
                controller.tabBarItem = makeTabBarItem("加入")
            case .calendarPage:
                controller = UIStoryboard.calendarPage.instantiateInitialViewController()!
                controller.tabBarItem = makeTabBarItem("日曆")
            }
            
            // controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
            return controller
        }
        
        private func makeTabBarItem(_ title: String) -> UITabBarItem {
            return UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        }
        
        private var image: UIImage? {
            switch self {
            case .ingredients:
                return .asset(.fridge_not_select)!.withRenderingMode(.alwaysOriginal)
            case .teamLink:
                return .asset(.teamLink_not_select)!.withRenderingMode(.alwaysOriginal)
            case .join:
                return .asset(.join_not_select)!.withRenderingMode(.alwaysOriginal)
            case .calendarPage:
                return .asset(.calendar_not_select)!.withRenderingMode(.alwaysOriginal)
            }
        }

        private var selectedImage: UIImage? {
            switch self {
            case .ingredients:
                return .asset(.fridge_select)!.withRenderingMode(.alwaysOriginal)
            case .teamLink:
                return .asset(.teamLink_select)!.withRenderingMode(.alwaysOriginal)
            case .join:
                return .asset(.join_select)!.withRenderingMode(.alwaysOriginal)
            case .calendarPage:
                return .asset(.calendar_select)!.withRenderingMode(.alwaysOriginal)
            }
        }
        
    }
   
}

// MARK: - UITabBarControllerDelegate
extension FridgeTabBarController: UITabBarControllerDelegate {

    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        
        return true
    }
}
