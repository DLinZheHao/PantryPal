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
        
        guard let emallAddress = emailTextField.text, emallAddress != "",
              let password = passwordTextField.text, password != "" else {
            alert("輸入格不能為空白", controller)
            return
        }
        Auth.auth().signIn(withEmail: emallAddress, password: password) { _, error in
            if error != nil {
                alert("登入錯誤，請重新嘗試", controller)
                return
            }
            controller.view.endEditing(true)
            print("成功登入")
            
            guard let nextVC = UIStoryboard.fridgeList.instantiateViewController(
                withIdentifier: String(describing: FridgeListViewController.self)
            ) as? FridgeListViewController
            else {
                print("創建失敗")
                return }
            nextVC.modalPresentationStyle = .fullScreen
            controller.present(nextVC, animated: true, completion: nil)
        }
    }
}
