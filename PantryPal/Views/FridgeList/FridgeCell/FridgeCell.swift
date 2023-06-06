//
//  FridgeCell.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//

import UIKit

class FridgeCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backgroundColorView: UIView!
    
    var onEditButtonTapped: ((UITableViewCell) -> Void)?

    @IBAction func editButtonTapped(_ sender: Any) {
        onEditButtonTapped?(self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColorView.layer.cornerRadius = 10
        backgroundColorView.layer.masksToBounds = true
        backgroundColorView.layer.shadowColor = UIColor.black.cgColor
        backgroundColorView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        backgroundColorView.layer.shadowOpacity = 0.2
        backgroundColorView.layer.shadowRadius = 4.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
