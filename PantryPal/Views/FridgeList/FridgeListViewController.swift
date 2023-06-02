//
//  FridgeListViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//

import UIKit

class FridgeListViewController: UIViewController {
    
    var currentFridgeID: String?
    var fridges: [FridgeData] = []
    
    @IBOutlet weak var fridgeListTableView: FridgeListTableView! {
        didSet {
            fridgeListTableView.dataSource = self
            fridgeListTableView.delegate = self
        }
    }
    
    @IBAction func created() {
        setUpCreatFridgeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
            
        fridgeListTableView.lk_registerCellWithNib(identifier: String(describing: FridgeCell.self), bundle: nil)
        
        fetchFridgeData { [weak self] getData in
            self?.fridges = getData
            self?.fridgeListTableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fridgeListTableView.lk_registerCellWithNib(identifier: String(describing: FridgeCell.self), bundle: nil)
        
        fetchFridgeData { [weak self] getData in
            self?.fridges = getData
            self?.fridgeListTableView.reloadData()
        }
    }
}
// MARK: tableview 控制
extension FridgeListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fridges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FridgeCell.self))
        
        guard let fridgeCell = cell as? FridgeCell else {
            print("cell 創建失敗")
            return cell!
        }
        
        fridgeCell.nameLabel.text = fridges[indexPath.row].name
        fridgeCell.selectionStyle = .default // 设置选择样式
        return fridgeCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chooseFridge(fridges[indexPath.row].id) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (action, sourceView, completionHandler) in
            if let id = self?.fridges[indexPath.row].id,
               let currentID = self?.currentFridgeID,
               id != currentID {
                deleteFridge(id) { [weak self] in
                    fetchFridgeData { [weak self] getData in
                        self?.fridges = getData
                        self?.fridgeListTableView.reloadData()
                    }
                }
            } else {
                alert("不可以刪除當前使用的冰箱，請先選擇其他冰箱在進行刪除", self!)
            }
            completionHandler(true)
        }
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
}
// MARK: - 新增fridge view
extension FridgeListViewController {
    private func setUpCreatFridgeView() {
        guard let customView = UINib(nibName: "CreateFridgeView", bundle: nil).instantiate(withOwner: self, options: nil).first as? CreateFridgeView else {
            print("畫面創建失敗")
            return
        }
        view.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            customView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customView.heightAnchor.constraint(equalToConstant: 300)
        ])
        customView.closeButton.addTarget(self, action: #selector(closeCreateView), for: .touchUpInside)
        customView.sendButton.addTarget(self, action: #selector(createNewFridgeAction), for: .touchUpInside)
        customView.layoutIfNeeded()
    }
    
    @objc private func closeCreateView(_ sender: UIButton) {
        sender.superview?.removeFromSuperview()
    }
    @objc private func createNewFridgeAction(_ sender: UIButton) {
        guard let createView = sender.superview as? CreateFridgeView else { return }
        
        if !checkEnterIsEmpty(createView.fridgeNameTextfield) {
            guard let fridgeName = createView.fridgeNameTextfield.text else { return }
            createNewFridge(fridgeName) {
                fetchFridgeData { [weak self] getData in
                    self?.fridges = getData
                    self?.fridgeListTableView.reloadData()
                    sender.superview?.removeFromSuperview()
                }
            }
            
        } else {
            alert("輸入欄位為空，請重新輸入", self)
        }
    }
    
    private func isTextFieldEmptyOrWhitespace(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedText.isEmpty
    }
    
    private func checkEnterIsEmpty(_ textField: UITextField) -> Bool {
        if isTextFieldEmptyOrWhitespace(textField) {
            alert("title 輸入欄為空，請重新輸入", self)
            textField.text = ""
            return true
        }
        return false
    }
}
