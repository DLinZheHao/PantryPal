//
//  SigninStackView.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/23.
//

import UIKit
import Firebase
import LocalAuthentication
import SwiftKeychainWrapper

class SigninStackView: UIStackView {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var faceIDButton: UIButton!
    @IBAction func faceIDButtonTap() {
        authenticateWithBiometric()
    }
    func showFaceIDButton() {
        let creds = KeyChainStorage.getCredentials()
        guard let credsPassword = creds?.password,
              let credsEmail = creds?.email else { return }
        if credsPassword.isEmpty || credsEmail.isEmpty {
            faceIDButton.isHidden = true
        } else {
            faceIDButton.isHidden = false
        }
    }
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
        let creds = Credentials.init(email: emallAddress, password: password)
        KeyChainStorage.saveCredentials(credentials: creds)
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
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = nextVC
            }

        }
    }
    func authenticateWithBiometric() {
        // Get the local authentication context.
        let localAuthContext = LAContext()
        let reasonText = "Authentication is required to sign in AppCoda"
        var authError: NSError?
        
        if !localAuthContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            if let error = authError {
                print(error.localizedDescription)
            }
            return
        }
        
        // Perform the Biometric authentication
        localAuthContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonText, reply: { (success: Bool, error: Error?) -> Void in
            
            // Failure workflow
            if !success {
                if let error = error {
                    switch error {
                    case LAError.authenticationFailed:
                        print("Authentication failed")
                    case LAError.passcodeNotSet:
                        print("Passcode not set")
                    case LAError.systemCancel:
                        print("Authentication was canceled by system")
                    case LAError.userCancel:
                        print("Authentication was canceled by the user")
                    case LAError.biometryNotEnrolled:
                        print("Authentication could not start because you haven't enrolled either Touch ID or Face ID on your device.")
                    case LAError.biometryNotAvailable:
                        print("Authentication could not start because Touch ID / Face ID is not available.")
                    case LAError.userFallback:
                        print("User tapped the fallback button (Enter Password).")
                    default:
                        print(error.localizedDescription)
                    }
                }
            } else {
            
                // Success workflow
                let creds = KeyChainStorage.getCredentials()
                OperationQueue.main.addOperation {
                    print("輸入： print ")
                    self.emailTextField.text = creds?.email
                    self.passwordTextField.text = creds?.password
                }
                
                print("Successfully authenticated")
            }
            
        })
    }
}
