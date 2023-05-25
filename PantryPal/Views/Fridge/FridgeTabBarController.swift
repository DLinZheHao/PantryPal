//
//  FridgeTabBar.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//

import UIKit

class FridgeTabBarController: UITabBarController {
    private let tabs: [Tab] = [.ingredients]
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = tabs.map { $0.makeViewController() }
        delegate = self
    }
}

extension FridgeTabBarController {
    private enum Tab {
        case ingredients
        // case calendar
        
        func makeViewController() -> UIViewController {
            let controller: UIViewController
            switch self {
            case .ingredients: controller = UIStoryboard.ingredients.instantiateInitialViewController()!
            }
//            controller.tabBarItem = makeTabBarItem()
//            controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
            return controller
        }
        
//        private func makeTabBarItem() -> UITabBarItem {
//            return UITabBarItem(title: nil, image: image, selectedImage: selectedImage)
//        }
        
//        private var image: UIImage? {
//            switch self {
//            case .ingredients:
//                return .asset(.Icons_36px_Home_Normal)
//            }
//        }
//
//        private var selectedImage: UIImage? {
//            switch self {
//            case .ingredients:
//                return .asset(.Icons_36px_Home_Selected)
//            }
//        }
        
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
