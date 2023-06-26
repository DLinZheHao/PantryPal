//
//  AddMemberViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/30.
//

import UIKit

class AddMemberViewController: UIViewController {
    var currentFridge: String?
    var receiverID: String?
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var searchNameLabel: UILabel!
    @IBOutlet weak var searchEmailLabel: UILabel!
    @IBOutlet weak var emailSearchTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBAction func searchTapped() {
        guard let email = emailSearchTextField.text else {
            alert("輸入欄為空，請重新輸入", self)
            return
        }
        searchUser(currentFridge!, email) { [weak self] searchUserData in
            self?.searchNameLabel.text = searchUserData.name
            self?.searchEmailLabel.text = searchUserData.email
            self?.emailSearchTextField.text = ""
            self?.addButton.isHidden = false
            self?.receiverID = searchUserData.id
        } fallCompletion: { [weak self] in
            alert("沒有搜尋到該用戶", self!)
            self?.emailSearchTextField.text = ""
        }
    }
    
    @IBAction func sendInvite() {
        guard let id = receiverID else { return }
        guard let fridgeID = currentFridge else { return }
        fridgeMemberAddInvite(id, fridgeID, self, addButton) { [weak self] in
            self?.searchNameLabel.text = "   "
            self?.searchEmailLabel.text = "   "
            self?.addButton.isHidden = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.isHidden = true
        searchButton.layer.cornerRadius = 10
        searchButton.layer.masksToBounds = true
        searchNameLabel.layer.cornerRadius = 5
        searchNameLabel.layer.masksToBounds = true
        searchEmailLabel.layer.cornerRadius = 5
        searchEmailLabel.layer.masksToBounds = true
    }
    
}
