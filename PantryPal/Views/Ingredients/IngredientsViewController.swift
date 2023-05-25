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
            print(self?.fridgeData)
            self?.textLabel.text = self?.fridgeData?.name
            self?.changeFridgeButton.setTitle(self?.fridgeData?.name, for: .normal)
        } memberCompletion: { [weak self] passMemberData in
            self?.memberData = passMemberData
            print(self?.memberData)
        } ingredientCompletion: { [weak self] passIngredientsData in
            self?.ingredientsData = passIngredientsData
            print(self?.ingredientsData)
        }
    }

}

extension IngredientsViewController {

}
