//
//  TeamLinkViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/30.
//

import UIKit

class TeamLinkViewController: UIViewController {
    var currentFridgeData: FridgeData?
    var memberData: [MemberData] = []
    
    var addMemberViewController: AddMemberViewController?
    
    private enum FunctionType: Int {
        case addMember = 0
        case manage = 1
        
    }

    private struct Segue {
        static let addMember = "SegueAdd"
        static let manage = "SegueManage"
    }
    
    @IBOutlet weak var fridgeChangeButton: UIButton!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet var productBtns: [UIButton]!
    @IBOutlet weak var indicatorCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addContainerView: UIView!
    @IBOutlet weak var manageContainerView: UIView!
    private var containerViews: [UIView] {
        return [addContainerView, manageContainerView]
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        if addMemberViewController != nil {
            updateContainerViewData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        if identifier == Segue.addMember {
            guard let addMemberVC = segue.destination as? AddMemberViewController else { return }
            addMemberViewController = addMemberVC
            
            userLastUseFridgeForMember { data in
                addMemberVC.qrCodeImageView.image = generateQRCode(from: data.id)
            } manageClosure: { _ in
                print("不做事")
            }
        } else {
            guard let manageVC = segue.destination as? ManageViewController else { return }
        }

    }
    
   @IBAction func onChangeProducts(_ sender: UIButton) {
        for btn in productBtns {
            btn.isSelected = false
        }
        sender.isSelected = true
        moveIndicatorView(reference: sender)
        
        guard let type = FunctionType(rawValue: sender.tag) else { return }
        updateContainer(type: type)
    }
    
    private func moveIndicatorView(reference: UIView) {
        indicatorCenterXConstraint.isActive = false
        indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: reference.centerXAnchor)
        indicatorCenterXConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }

    private func updateContainer(type: FunctionType) {
        containerViews.forEach { $0.isHidden = true }
        
        switch type {
        case .addMember:
            addContainerView.isHidden = false
        case .manage:
            manageContainerView.isHidden = false
        }
    }
}

extension TeamLinkViewController {
    private func getData() {
        userLastUseFridgeForMember { [weak self] data in
            self?.currentFridgeData = data
            self?.fridgeChangeButton.setTitle(data.name, for: .normal)
        } manageClosure: { [weak self] memberDataArray in
            self?.memberData = memberDataArray
        }
    }
    func updateContainerViewData() {
        print("執行container view 更新")
        userLastUseFridgeForMember { [weak self] data in
            self?.addMemberViewController!.qrCodeImageView.image = generateQRCode(from: data.id)
        } manageClosure: { _ in
            print("不做事")
        }
    }

}
