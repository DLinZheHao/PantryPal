//
//  SigninStackView.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/23.
//

import UIKit
import Firebase

class SigninStackView: UIStackView {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    func signIn(_ controller: UIViewController) {
        
//        guard let emallAddress = emailTextField.text, emallAddress != "",
//              let password = passwordTextField.text, password != "" else {
//            alert("輸入格不能為空白", controller)
//            return
//        }
        let emallAddress = "a8570870z@gmail.com"
        let password = "0917652683c"
//        let emallAddress = "123@gmail.com"
//        let password = "123456789"
        Auth.auth().signIn(withEmail: emallAddress, password: password) { _, error in
            if error != nil {
                alert("登入錯誤，請重新嘗試", controller)
                return
            }
            controller.view.endEditing(true)
            print("成功登入")
            
            guard let nextVC = UIStoryboard.fridgeTabBar.instantiateViewController(
                withIdentifier: String(describing: FridgeTabBarController.self)
            ) as? FridgeTabBarController
            else {
                print("創建失敗")
                return }
            
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.modalTransitionStyle = .crossDissolve
            controller.present(nextVC, animated: true, completion: nil)
        }
    }
}
