//
//  FridgeListViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//

import UIKit

class FridgeListViewController: UIViewController {
    
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
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithDefaultBackground()
        barAppearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        
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
    
//    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        return false // 返回 false，不显示选中状态的动画
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        guard let nextVC = UIStoryboard.fridgeTabBar.instantiateViewController(
            withIdentifier: String(describing: FridgeTabBarController.self)) as? FridgeTabBarController
        else {
            print("創建失敗")
            return
        }
        guard let navigationController = self.navigationController else {
            print("导航控制器不存在")
            return
        }
        nextVC.fridgeId = fridges[indexPath.row].id
        navigationController.pushViewController(nextVC, animated: true)
    }
}

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
            createNewFridge(fridgeName)
            sender.superview?.removeFromSuperview()
            
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
