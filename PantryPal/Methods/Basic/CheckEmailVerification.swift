//
//  CheckEmailVerification.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/23.
//
import Firebase

// 检查电子邮件是否已验证
func checkEmailVerification(_ controller: UIViewController) -> Bool {
    guard let user = Auth.auth().currentUser else {
        print("用户未登录")
        situationJudgment(0, controller)
        return false
    }
    
    if user.isEmailVerified {
        print("电子邮件已验证")
        return true
    } else {
        print("电子邮件未验证")
        situationJudgment(2, controller)
        return false
    }
}

private func situationJudgment(_ condition: Int, _ controller: UIViewController) {
    if condition == 0 {
        alert("用戶尚未登入", controller)
    } else if condition == 2 {
        alert("電子郵件尚未驗證", controller)
    }
}
