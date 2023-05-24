//
//  SignInViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/23.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var informationStackView: InformationStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
extension RegisterViewController {
    
    @IBAction func tapRegister() {
        informationStackView.register(self)
    }
}
