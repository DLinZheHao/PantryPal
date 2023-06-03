//
//  DataCell.swift
//  FoldingCell_and_someRefresh
//
//  Created by 林哲豪 on 2023/6/1.
//

import UIKit
import FoldingCell

class DataCell: FoldingCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var ingredientsNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var createdTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var ingredientsImage: UIImageView!
    
    @IBOutlet weak var storeStatusLabel: UILabel!
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
}
