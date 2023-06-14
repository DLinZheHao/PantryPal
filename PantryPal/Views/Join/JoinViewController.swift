//
//  JoinViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/31.
//

import UIKit

class JoinViewController: UIViewController {
    var inviteData: [InviteData] = []

    @IBOutlet weak var mailboxLabel: UILabel!
    @IBOutlet weak var mailboxImage: UIImageView!
    @IBOutlet weak var inviteTableView: UITableView! {
        didSet {
            inviteTableView.delegate = self
            inviteTableView.dataSource = self
        }
    }
    @IBOutlet weak var scannerButton: UIButton!
    @IBAction func scannerButtonTapped() {
        print("按下")
        guard let nextVC = UIStoryboard.qrCodeScanner.instantiateViewController(
            withIdentifier: String(describing: QRCodeScannerViewController.self)
        ) as? QRCodeScannerViewController
        else {
            print("創建失敗")
            return
        }
        nextVC.modalPresentationStyle = .fullScreen
        present(nextVC, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        mailboxImage.isHidden = true
        mailboxLabel.isHidden = true
    }
    
}

extension JoinViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inviteData.isEmpty {
            tableView.isHidden = true
            mailboxImage.isHidden = false
            mailboxLabel.isHidden = false
        } else {
            tableView.isHidden = false
            mailboxImage.isHidden = true
            mailboxLabel.isHidden = true
        }
        return inviteData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: InviteTableViewCell.self),
            for: indexPath)
        guard let inviteCell = cell as? InviteTableViewCell else {
            print("失敗")
            return cell
        }
        inviteCell.fridgeNameLabel.text = inviteData[indexPath.row].fridgeName
        
        inviteCell.getClosure { [weak self] inputCell in
            guard let cellIndexPath = tableView.indexPath(for: inputCell) else {
                return
            }
            acceptInvite((self?.inviteData[cellIndexPath.row])!) { [weak self] in
                self?.getData()
                
            }
        }
        inviteCell.getRejectClosure { [weak self] inputCell in
            guard let cellIndexPath = tableView.indexPath(for: inputCell) else {
                return
            }
            deleteInviteRequest((self?.inviteData[cellIndexPath.row].receiver)!, (self?.inviteData[cellIndexPath.row].sender)!)
        }
        return inviteCell
    }
    
}
extension JoinViewController {
    private func getData() {
        getAllInvite { [weak self] data in
            self?.inviteData = data
            self?.inviteTableView.reloadData()
        }
    }

}
