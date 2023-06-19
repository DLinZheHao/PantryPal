//
//  ToolsViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/16.
//

import UIKit

class ToolsViewController: UIViewController {
    @IBOutlet weak var toolCollectionView: UICollectionView! {
        didSet {
            toolCollectionView.delegate = self
            toolCollectionView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension ToolsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ToolsCollectionViewCell.self),
            for: indexPath
        )
        guard let profileCell = cell as? ToolsCollectionViewCell else { return cell }
        return profileCell
    }
    
}
extension ToolsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: view.frame.width / 2.0, height: 180.0)
        } 
        return CGSize.zero
    }
}
