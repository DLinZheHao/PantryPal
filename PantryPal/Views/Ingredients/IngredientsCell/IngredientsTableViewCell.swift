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

        // Configure the view for the selected state
    }
    
}
