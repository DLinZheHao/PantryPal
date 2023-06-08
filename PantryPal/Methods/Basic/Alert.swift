//
//  Alert.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//

import UIKit

func alert(_ message: String, _ controller: UIViewController) {
    let alertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
    alertController.addAction(okAction)
    controller.present(alertController, animated: true, completion: nil)
}

func alertTitle(_ message: String, _ controller: UIViewController, _ title: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
    alertController.addAction(okAction)
    controller.present(alertController, animated: true, completion: nil)
}

