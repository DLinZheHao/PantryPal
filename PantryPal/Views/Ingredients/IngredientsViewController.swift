//
//  IngredientsViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//

import UIKit

class IngredientsViewController: UIViewController {
    var fridgeData: FridgeData?
    var memberData: [MemberData]?
    var ingredientsData: [IngredientData]?
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var changeFridgeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        userLastUseFridge { [weak self] passFridgeData in
            self?.fridgeData = passFridgeData
            self?.textLabel.text = self?.fridgeData?.name
            self?.changeFridgeButton.setTitle(self?.fridgeData?.name, for: .normal)
        } memberCompletion: { [weak self] passMemberData in
            self?.memberData = passMemberData
        } ingredientCompletion: { [weak self] passIngredientsData in
            self?.ingredientsData = passIngredientsData
        }
    }

}

extension IngredientsViewController {
    @IBAction  private func showAddIngredientsView() {
        guard let addIngredientsView = UINib(nibName: "AddIngredients", bundle: nil).instantiate(withOwner: self, options: nil).first as? AddIngredientsView else {
            print("畫面創建失敗")
            return
        }
        view.addSubview(addIngredientsView)
        
        addIngredientsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addIngredientsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            addIngredientsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addIngredientsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addIngredientsView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
}
