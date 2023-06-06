//
//  HeaderView.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/6.
//

import UIKit

class HeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var searchBar: UISearchBar!
    var controller: UIViewController?
    var dataArray: [PresentIngredientsData]?
    
    @IBOutlet weak var orderButton: UIButton!
    
    @IBAction func sortTapped(_ sender: Any) {
        guard let controller = controller else {
            print("獲得controller失敗")
            return }
        guard let dataArray = dataArray else {
            print("獲得資料失敗")
            return }
        
        let actionSheetController = UIAlertController()
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel)
        
        let sortByName = UIAlertAction(title: "名稱排序", style: UIAlertAction.Style.default) { (_) -> Void in
            var sortArray = chooseSort(0, dataArray)
            self.orderButton.setTitle("名稱排序▾", for: .normal)
            guard let ingredientViewController = controller as? IngredientsViewController else {
                print("失敗")
                return
            }
            DispatchQueue.main.async {
                ingredientViewController.ingredientsData = sortArray
                ingredientViewController.ingredientTableView.reloadData()
            }
        }
        
        let sortByLeftTime = UIAlertAction(title: "時間排序", style: UIAlertAction.Style.default) { (alertAction) -> Void in
            var sortArray = chooseSort(1, dataArray)
            self.orderButton.setTitle("時間排序▾", for: .normal)
            guard let ingredientViewController = controller as? IngredientsViewController else {
                print("失敗")
                return
            }
            DispatchQueue.main.async {
                ingredientViewController.ingredientsData = sortArray
                ingredientViewController.ingredientTableView.reloadData()
            }
        }
                
        actionSheetController.addAction(cancelAction)
        actionSheetController.addAction(sortByName)
        actionSheetController.addAction(sortByLeftTime)
        
        controller.present(actionSheetController, animated: true, completion: nil)
    }
    
}
