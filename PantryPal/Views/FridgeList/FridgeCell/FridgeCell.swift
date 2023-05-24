//
//  FridgeCell.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/24.
//

import UIKit

class FridgeCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
