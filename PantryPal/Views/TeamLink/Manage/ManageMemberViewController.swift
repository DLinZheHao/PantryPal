//
//  ManageViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/30.
//

import UIKit

class ManageMemberViewController: UIViewController {
    var memberData: [MemberData] = []
    var currentFridgeID: String?
    
    @IBOutlet weak var memberManageTableView: UITableView! {
        didSet {
            memberManageTableView.dataSource = self
            memberManageTableView.delegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        memberManageTableView.lk_registerCellWithNib(identifier: String(describing: ManageMemberTableViewCell.self), bundle: nil)
    }
}

extension ManageMemberViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ManageMemberTableViewCell.self),
            for: indexPath)
        guard let manageMemberCell = cell as? ManageMemberTableViewCell else { return cell}
        
        manageMemberCell.nameLabel.text = memberData[indexPath.row].name
        manageMemberCell.emailLabel.text = memberData[indexPath.row].email
        
        return manageMemberCell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (action, sourceView, completionHandler) in
            if let fridgeID = self?.currentFridgeID,
               let targetUserID = self?.memberData[indexPath.row].id {
                deleteMember(fridgeID, targetUserID) { [weak self] in
                    userLastUseFridgeForMember { data in
                        print("不做事")
                    } manageClosure: { memberData in
                        self?.memberData = memberData
                        self?.memberManageTableView.reloadData()
                    }
                    
                }
            } else {
                print("失敗啟用")
            }
            
            completionHandler(true)
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
}
