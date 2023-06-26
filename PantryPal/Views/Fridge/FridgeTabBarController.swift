//
//  FridgeTabBar.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//

import UIKit

class FridgeTabBarController: UITabBarController {
    var fridgeId: String?
    private let tabs: [Tab] = [.ingredients, .calendarPage, .teamLink, .join, .measure]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = tabs.map { $0.makeViewController() }
        self.tabBar.itemPositioning = .automatic
        self.tabBar.tintColor = .black
        delegate = self
    }
}

extension FridgeTabBarController {
    private enum Tab {
        case ingredients
        case teamLink
        case join
        case calendarPage
        case measure
        
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
            case .measure:
                controller = UIStoryboard.measure.instantiateInitialViewController()!
                controller.tabBarItem = makeTabBarItem("測量")
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
                return UIImage(systemName: "refrigerator")
            case .teamLink:
                return UIImage(systemName: "person.2.crop.square.stack")
            case .join:
                return UIImage(systemName: "person.crop.circle.badge.plus")
            case .calendarPage:
                return UIImage(systemName: "calendar.circle")
            case .measure:
                return UIImage(systemName: "ruler")
            }
        }

        private var selectedImage: UIImage? {
            switch self {
            case .ingredients:
                return UIImage(systemName: "refrigerator.fill")?.withRenderingMode(.alwaysOriginal)
            case .teamLink:
                return UIImage(systemName: "person.2.crop.square.stack.fill")?.withRenderingMode(.alwaysOriginal)
            case .join:
                return UIImage(systemName: "person.crop.circle.fill.badge.plus")?.withRenderingMode(.alwaysOriginal)
            case .calendarPage:
                return UIImage(systemName: "calendar.circle.fill")
            case .measure:
                return UIImage(systemName: "ruler.fill")?.withRenderingMode(.alwaysOriginal)
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
