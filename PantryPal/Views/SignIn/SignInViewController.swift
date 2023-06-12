//
//  SignInViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/23.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var signInStackView: SigninStackView!
    @IBAction func signIn() {
        signInStackView.signIn(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        showLoginDialog()
        signInStackView.showFaceIDButton()
    }
}
extension SignInViewController {
    private func setUp() {
        // 添加手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        let cornerRadius: CGFloat = 80
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        backgroundView.layer.mask = maskLayer
    }
    @objc func dismissKeyboard() {
        // 收起键盘
        view.endEditing(true)
    }
    
    // MARK: 登入動畫
    func showLoginDialog() {
        // Move the login view off screen
        signInStackView.isHidden = false
        signInStackView.transform = CGAffineTransform(translationX: 0, y: 900)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            
            self.signInStackView.transform = CGAffineTransform.identity
            
        }, completion: nil)
    }
}
