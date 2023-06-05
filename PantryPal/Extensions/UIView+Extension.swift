//
//  UIView+Extension.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/3.
//

import Foundation
import Lottie
import UIKit
extension UIView {
    func removeAllLottieViews() {
        for subview in subviews {
            if let animationView = subview as? LottieAnimationView {
                animationView.stop()
                animationView.removeFromSuperview()
            }
        }
    }
}
