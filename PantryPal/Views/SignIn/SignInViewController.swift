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

    }
    
}
