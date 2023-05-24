//
//  InformationStackView.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/23.
//

import UIKit
import Firebase

class InformationStackView: UIStackView {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    func register(_ controller: UIViewController) {
        guard let name = nameTextField.text, name != "",
              let email = emailTextField.text, email != "",
              let password = passwordTextField.text, password != ""
        else {
            let message = "Please make sure you provide information to complete the registration"
            alert(message, controller)
            return
        }
        if password.count < 8 || password.count > 16 {
            alert("密碼長度不正確", controller)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alert(error.localizedDescription, controller)
                return
            }
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                changeRequest.displayName = name
                changeRequest.commitChanges { error in
                    if error != nil {
                        print("用戶名稱改變失敗")
                    }
                    
                }
            }
            
            guard let user = authResult?.user else {
                print("发送验证电子邮件失败：\(error!.localizedDescription)")
                return
            }
            // 发送验证电子邮件
            user.sendEmailVerification { (error) in
                if let error = error {
                    print("发送验证电子邮件失败：\(error.localizedDescription)")
                    return
                }
                
                print("验证电子邮件已发送至：\(user.email!)")
                userDataInit(email: email, name: name)
            }
        }
    }
    
}
