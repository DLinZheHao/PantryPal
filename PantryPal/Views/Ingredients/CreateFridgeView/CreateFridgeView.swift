//
//  CreateFridgeView.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//

import UIKit

class CreateFridgeView: UIView {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var fridgeNameTextfield: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    func setUp() {
        self.backgroundColor = UIColor(hex: "#caeded")
        self.sendButton.layer.cornerRadius = 10.0
        self.sendButton.layer.masksToBounds = true
    }
}
