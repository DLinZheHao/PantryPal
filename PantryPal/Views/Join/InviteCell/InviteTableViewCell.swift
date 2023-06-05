//
//  InviteTableViewCell.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/31.
//

import UIKit

class InviteTableViewCell: UITableViewCell {

    var acceptInviteClosure: ((UITableViewCell) -> Void)?
    var rejectInviteClosure: ((UITableViewCell) -> Void)?
    @IBOutlet weak var fridgeNameLabel: UILabel!
    @IBOutlet weak var refuseButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func getClosure(completion: @escaping (UITableViewCell) -> Void) {
        acceptInviteClosure = completion
    }
    func getRejectClosure(completion: @escaping (UITableViewCell) -> Void) {
        rejectInviteClosure = completion
    }
    @IBAction func acceptButtonTapped() {
        acceptInviteClosure!(self)
    }
    @IBAction func rejectButtonTaaped() {
        rejectInviteClosure!(self)
    }
}
