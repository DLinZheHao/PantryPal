//
//  IngredientsTableViewCell.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/27.
//

import UIKit

class IngredientsTableViewCell: UITableViewCell {

    @IBOutlet weak var ingredientsImage: UIImageView!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var ingredientsNameLabel: UILabel!
    @IBOutlet weak var ingredientsPriceLabel: UILabel!
    @IBOutlet weak var ingredientsStatusLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundImageView.layer.cornerRadius = 10
        backgroundImageView.layer.masksToBounds = true
        ingredientsImage.layer.cornerRadius = ingredientsImage.bounds.width / 2
        ingredientsImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func styleSetting() {
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }
    
    func textLabelSetting(name: String, price: String, status: String) {
        self.ingredientsNameLabel.text = name
        self.ingredientsPriceLabel.text = price
        self.ingredientsStatusLabel.text = status
    }
    
    func updateCellColorBasedOnExpiration() {
        if self.expirationLabel.text == "已過期" {
            self.backgroundImageView.backgroundColor = UIColor(hex: "E2271A", alpha: 0.3)
        } else {
            self.backgroundImageView.backgroundColor = UIColor(hex: "#caeded", alpha: 0.8)
        }
    }
    
    func shouldEnableNotificationsImage(isEnable: Bool) {
        if isEnable {
            self.notificationImage.isHidden = false
        } else {
            self.notificationImage.isHidden = true
        }
    }
}
