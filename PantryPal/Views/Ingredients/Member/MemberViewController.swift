//
//  MemberViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/30.
//

import UIKit

class MemberViewController: UIViewController {
    var currentFridgeID: String?
    var memberData: [MemberData] = []
    
    
    @IBOutlet weak var memberCollectionView: UICollectionView! {
        didSet {
            memberCollectionView.delegate = self
            memberCollectionView.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        memberCollectionView.lk_registerCellWithNib(identifier: String(describing: MemberCollectionViewCell.self), bundle: nil)
        getData()
    }

}
// MARK: - collectionView 控制
extension MemberViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memberData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: MemberCollectionViewCell.self),
            for: indexPath)
        guard let memberCell = cell as? MemberCollectionViewCell else {
            print("發生cell轉換失敗")
            return cell
        }
        memberCell.memberNameLabel.text = memberData[indexPath.row].name
        
        return memberCell
    }
    
}
// MARK: 獲取成員資料
extension MemberViewController {
    private func getData() {
        guard let id = currentFridgeID else {
            print("沒有獲取到ID")
            return
        }
        
        getMembers(id) { [weak self] returnMemberData in
            self?.memberData = returnMemberData
            print(self?.memberData)
            print("成功獲取資料")
            self?.memberCollectionView.reloadData()
        }
    }
}
