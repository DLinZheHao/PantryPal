//
//  SignInViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/23.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var signInStackView: SigninStackView!
    @IBAction func signIn() {
        signInStackView.signIn(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // 添加手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        // 收起键盘
        view.endEditing(true)
    }
}
