//
//  InputView.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/7.
//

import UIKit

class InputView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func setUp(_ completion: (UITextField, UIButton) -> Void) {
        let inputTextField = UITextField()
        let sendButton = UIButton()
        let choosePictureButton = UIButton()

        choosePictureButton.translatesAutoresizingMaskIntoConstraints = false
        let systemImage = UIImage(systemName: "photo")
        choosePictureButton.setImage(systemImage, for: .normal)
        choosePictureButton.tintColor = UIColor(hex: "487A71")
        self.addSubview(choosePictureButton)

        NSLayoutConstraint.activate([
            choosePictureButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            choosePictureButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            choosePictureButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            choosePictureButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        
        inputTextField.placeholder = "輸入"
        inputTextField.backgroundColor = .white
        inputTextField.textColor = .black
        self.addSubview(inputTextField)

        NSLayoutConstraint.activate([
            inputTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            inputTextField.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            inputTextField.leadingAnchor.constraint(equalTo: choosePictureButton.trailingAnchor, constant: 8),
            inputTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -55)
        ])
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setImage(.asset(.outline_send_black_36pt), for: .normal)
        sendButton.tintColor = UIColor(hex: "487A71")
        self.addSubview(sendButton)

        NSLayoutConstraint.activate([
            sendButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            sendButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            sendButton.leadingAnchor.constraint(equalTo: inputTextField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15)
        ])
        completion(inputTextField, sendButton)
    }
    
}
