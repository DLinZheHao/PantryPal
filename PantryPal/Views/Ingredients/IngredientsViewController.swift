//
//  IngredientsViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//

import UIKit
import FSCalendar
import Photos
import MJRefresh
import Floaty
import Lottie
import IQKeyboardManagerSwift

class IngredientsViewController: UIViewController {
    private var animationView: LottieAnimationView?
    var storeStatus = ["冷凍", "冷藏", "常溫"]
    
    var completionHandler: ((URL?) -> Void)?
    var getImageCompletionHandler: ((UIImage) -> Void)?
    
    var imageURL: String?
    var selectedFileURL: URL?
    var takingPicture: UIImagePickerController!
    
    var currentFridgeID: String?
    var fridgeData: FridgeData?
    var memberData: [MemberIDData]?
    var ingredientsData: [PresentIngredientsData] = []
    
    var searchIngredientsData = [PresentIngredientsData]()
    
    var header: HeaderView?
    
    @IBOutlet weak var ingredientTableView: UITableView! {
        didSet {
            ingredientTableView.delegate = self
            ingredientTableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationBar = navigationController?.navigationBar
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.shadowColor = .clear
        navigationBar?.scrollEdgeAppearance = navigationBarAppearance
        navigationBar?.standardAppearance = navigationBarAppearance
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        layoutFAB()
        ingredientTableView.lk_registerCellWithNib(identifier: String(describing: IngredientsTableViewCell.self), bundle: nil)
        ingredientTableView.lk_registerHeaderWithNib(identifier: String(describing: HeaderView.self), bundle: nil)
        ingredientTableView.sectionHeaderTopPadding = 0
        
        let header = MJRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refreshAction))
        header.isAutomaticallyChangeAlpha = true
        self.ingredientTableView.mj_header = header
        
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        ingredientsData = []
        ingredientTableView.reloadData()
        header?.orderButton.setTitle("名稱排序▾", for: .normal)
        getData()
    }
}
// MARK: - Floaty
extension IngredientsViewController {
    func layoutFAB() {
        let floaty = Floaty()
        floaty.addItem("新增食材", icon: .asset(.outline_kitchen_black_36pt)) { [weak self] (_) in
            self?.showAddIngredientsView()
        }
        floaty.addItem("查看成員", icon: .asset(.outline_people_black_36pt)) { [weak self] (_) in
            self?.goMemberPage()
        }
        floaty.addItem("切換冰箱", icon: .asset(.outline_change_circle_black_36pt)) { [weak self] (_) in
            self?.changeFridge()
        }
        floaty.addItem("新增冰箱", icon: .asset(.outline_add_box_black_36pt)) { [weak self] (_) in
            self?.setUpCreatFridgeView()
        }
        floaty.plusColor = .white
        floaty.paddingX = self.view.frame.width / 2 - floaty.frame.width / 2 - CGFloat(155)
        floaty.paddingY = 120
        floaty.sticky = true
        self.view.addSubview(floaty)
    }
}
// MARK: - 切換冰箱
extension IngredientsViewController {
    private func changeFridge() {
        guard let nextVC = UIStoryboard.fridgeList.instantiateViewController(
            withIdentifier: String(describing: FridgeListViewController.self)
        ) as? FridgeListViewController
        else {
            print("創建失敗")
            return }
        nextVC.currentFridgeID = currentFridgeID!
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.modalTransitionStyle = .crossDissolve
        present(nextVC, animated: true, completion: nil)
        // navigationController?.pushViewController(nextVC, animated: true)
    }
}
// MARK: - 新增冰箱
extension IngredientsViewController {
    private func setUpCreatFridgeView() {
        // 获取TabBarController的引用
        if let tabBarController = self.tabBarController {

            // 遍历所有选项卡并開啟它们
            if let tabItems = tabBarController.tabBar.items {
                for tabItem in tabItems {
                    tabItem.isEnabled = false
                }
            }
        }
        let blackView = BlackBackgroundView()
        blackView.frame = view.frame
        blackView.backgroundColor = .black
        blackView.alpha = 0.2
        view.addSubview(blackView)
        
        guard let customView = UINib(nibName: "CreateFridgeView", bundle: nil).instantiate(withOwner: self, options: nil).first as? CreateFridgeView else {
            print("畫面創建失敗")
            return
        }
        customView.frame = CGRect(x: 0, y: 900, width: view.frame.width, height: 250)
        view.addSubview(customView)
        customView.backgroundColor = UIColor(hex: "#caeded")
        customView.closeButton.layer.cornerRadius = 10.0
        customView.closeButton.layer.masksToBounds = true
        customView.sendButton.layer.cornerRadius = 10.0
        customView.sendButton.layer.masksToBounds = true
        customView.closeButton.addTarget(self, action: #selector(closeCreateView), for: .touchUpInside)
        customView.sendButton.addTarget(self, action: #selector(createNewFridgeAction), for: .touchUpInside)
        
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut)
        animator.addAnimations {
            customView.frame.origin.y = CGFloat(150)
        }
        animator.startAnimation()
        
    }
    
    @objc private func closeCreateView(_ sender: UIButton) {
        // 获取TabBarController的引用
        if let tabBarController = self.tabBarController {

            // 遍历所有选项卡并開啟它们
            if let tabItems = tabBarController.tabBar.items {
                for tabItem in tabItems {
                    tabItem.isEnabled = true
                }
            }
        }
        let targetView = findSubview(ofType: BlackBackgroundView.self, in: self.view)
        guard let blackBackgroundView = targetView else {
            print("找不到")
            sender.superview?.removeFromSuperview()
            return
        }
        blackBackgroundView.removeFromSuperview()
        sender.superview?.removeFromSuperview()
    }
    @objc private func createNewFridgeAction(_ sender: UIButton) {
        // 获取TabBarController的引用
        if let tabBarController = self.tabBarController {

            // 遍历所有选项卡并開啟它们
            if let tabItems = tabBarController.tabBar.items {
                for tabItem in tabItems {
                    tabItem.isEnabled = true
                }
            }
        }
        guard let createView = sender.superview as? CreateFridgeView else { return }
        
        if !checkEnterIsEmpty(createView.fridgeNameTextfield) {
            guard let fridgeName = createView.fridgeNameTextfield.text else { return }
            createNewFridge(fridgeName) {
                fetchFridgeData { [weak self] _ in
                    self?.getData()
                    let targetView = findSubview(ofType: BlackBackgroundView.self, in: self!.view)
                    guard let blackBackgroundView = targetView else {
                        print("找不到")
                        sender.superview?.removeFromSuperview()
                        return
                    }
                    blackBackgroundView.removeFromSuperview()
                    sender.superview?.removeFromSuperview()
                }
            }
            
        } else {
            alert("輸入欄位為空，請重新輸入", self)
        }
    }
    
    private func isTextFieldEmptyOrWhitespace(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedText.isEmpty
    }
    
    private func checkEnterIsEmpty(_ textField: UITextField) -> Bool {
        if isTextFieldEmptyOrWhitespace(textField) {
            alert("title 輸入欄為空，請重新輸入", self)
            textField.text = ""
            return true
        }
        return false
    }
}
// MARK: - 新創食材完後刷新頁面
extension IngredientsViewController: GetRefreshSignal {
    func getSignal() {
        getData()
        let targetView = findSubview(ofType: BlackBackgroundView.self, in: self.view)
        guard let blackBackgroundView = targetView else {
            return
        }
        blackBackgroundView.removeFromSuperview()
    }
}
// MARK: - tableView 控制
extension IngredientsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: IngredientsTableViewCell.self),
            for: indexPath)
        guard let ingredientsCell = cell as? IngredientsTableViewCell else { return cell }
        // 設置 cell 的選擇樣式為 .none
        ingredientsCell.selectionStyle = .none
        ingredientsCell.backgroundColor = UIColor.clear
        ingredientsCell.contentView.backgroundColor = UIColor.clear
        ingredientsCell.ingredientsNameLabel.text = ingredientsData[indexPath.row].name
        ingredientsCell.ingredientsPriceLabel.text = "\(String(Int(ingredientsData[indexPath.row].price)))元"
        ingredientsCell.ingredientsStatusLabel.text = "\(storeStatus[ingredientsData[indexPath.row].storeStatus])保存"
        ingredientsCell.expirationLabel.text = getLeftTime(ingredientsData[indexPath.row].expiration)
        
        if ingredientsCell.expirationLabel.text == "已過期" {
            ingredientsCell.backgroundImageView.backgroundColor = UIColor(hex: "E2271A", alpha: 0.3)
        } else {
            ingredientsCell.backgroundImageView.backgroundColor = UIColor(hex: "#caeded", alpha: 0.8)
        }
        
        if ingredientsData[indexPath.row].enableNotifications {
            ingredientsCell.notificationImage.isHidden = false
        } else {
            ingredientsCell.notificationImage.isHidden = true
        }
        UIImage.downloadImage(from: URL(string: ingredientsData[indexPath.row].url)!) { image in
            DispatchQueue.main.async {
                ingredientsCell.ingredientsImage.image = image
            }
        }
        return ingredientsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC = UIStoryboard.ingredientsDetail.instantiateViewController(
            withIdentifier: String(describing: IngredientsDetailViewController.self)
        ) as? IngredientsDetailViewController
        else {
            print("創建失敗")
            return }
        nextVC.ingredientsData = ingredientsData[indexPath.row]
        guard let fridgeID = currentFridgeID else {
            alertTitle("開發錯誤: 沒有按照流程獲得ID", self, "需要修正")
            return 
        }
        nextVC.fridgeId = fridgeID
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.modalTransitionStyle = .crossDissolve
        present(nextVC, animated: true, completion: nil)
       
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: HeaderView.self)) as? HeaderView
        header = headerView
        headerView?.searchBar.searchBarStyle = .minimal
        headerView?.searchBar.delegate = self
        headerView?.controller = self
        headerView?.dataArray = ingredientsData
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  UITableView.automaticDimension// 返回 Header View 高度
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (action, sourceView, completionHandler) in
            if let id = self?.currentFridgeID,
               let ingredientsID = self?.ingredientsData[indexPath.row].ingredientsID {
                deleteIngredients(id, ingredientsID) { [weak self] in
                    self?.getData()
                }
            }
            completionHandler(true)
        }
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let runOutAction = UIContextualAction(style: .normal, title: "用完") { [weak self] (action, sourceView, completionHandler) in
           
            guard let ingredientDataArray = self?.ingredientsData,
                  let currentFridgeID = self?.currentFridgeID else { return }
            self?.historyAction(action: 0, ingredietnsDataArray: ingredientDataArray, indexPath: indexPath, fridgeID: currentFridgeID)
            completionHandler(true)
        }
        let expiredAction = UIContextualAction(style: .normal, title: "過期") { [weak self] (action, sourceView, completionHandler) in
            guard let ingredientDataArray = self?.ingredientsData,
                  let currentFridgeID = self?.currentFridgeID else { return }
            self?.historyAction(action: 0, ingredietnsDataArray: ingredientDataArray, indexPath: indexPath, fridgeID: currentFridgeID)
            completionHandler(true)
        }
        let throwAway = UIContextualAction(style: .normal, title: "丟棄") { [weak self] (action, sourceView, completionHandler) in
            guard let ingredientDataArray = self?.ingredientsData,
                  let currentFridgeID = self?.currentFridgeID else { return }
            self?.historyAction(action: 0, ingredietnsDataArray: ingredientDataArray, indexPath: indexPath, fridgeID: currentFridgeID)
            completionHandler(true)
        }
        runOutAction.backgroundColor = .gray
        expiredAction.backgroundColor = .black
        throwAway.backgroundColor = .orange
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [runOutAction, expiredAction, throwAway])
        
        return swipeConfiguration
    }
    
    private func historyAction(action: Int, ingredietnsDataArray: [PresentIngredientsData], indexPath: IndexPath, fridgeID: String) {
        
        
        let ingredientsHistoryData = IngredientsHistoryData(barcode: ingredietnsDataArray[indexPath.row].barcode,
                                                            ingredientsID: ingredietnsDataArray[indexPath.row].ingredientsID,
                                                            name: ingredietnsDataArray[indexPath.row].name,
                                                            price: ingredietnsDataArray[indexPath.row].price,
                                                            storeStatus: ingredietnsDataArray[indexPath.row].storeStatus,
                                                            url: ingredietnsDataArray[indexPath.row].url,
                                                            createdTime: ingredietnsDataArray[indexPath.row].createdTime,
                                                            enableNotifications: ingredietnsDataArray[indexPath.row].enableNotifications,
                                                            expiration: ingredietnsDataArray[indexPath.row].expiration,
                                                            description: ingredietnsDataArray[indexPath.row].description,
                                                            action: action)

        processingAction(fridgeID: fridgeID, ingredientsHistoryData: ingredientsHistoryData) { [weak self] in
            self?.getData()
        }
        
    }
}
// MARK: - Floaty 新增食材畫面: 掃描條碼 照片選擇
extension IngredientsViewController {
    private func showAddIngredientsView() {
        // 获取TabBarController的引用
        if let tabBarController = self.tabBarController {

            // 遍历所有选项卡并禁用它们
            if let tabItems = tabBarController.tabBar.items {
                for tabItem in tabItems {
                    tabItem.isEnabled = false
                }
            }
        }

        let blackView = BlackBackgroundView()
        blackView.frame = view.frame
        blackView.backgroundColor = .black
        blackView.alpha = 0.2
        view.addSubview(blackView)
        
        guard let addIngredientsView = UINib(nibName: "AddIngredients", bundle: nil).instantiate(withOwner: self, options: nil).first as? AddIngredientsView else {
            print("畫面創建失敗")
            return
        }
        addIngredientsView.frame = CGRect(x: 0, y: 900, width: view.frame.width, height: 400)
        view.addSubview(addIngredientsView)
        
        // 設置邊框顏色和粗細
        addIngredientsView.sendButton.layer.borderWidth = 2.0
        addIngredientsView.sendButton.layer.borderColor = UIColor.white.cgColor

        // 如果需要圓角邊框，你可以添加以下代碼
        addIngredientsView.sendButton.layer.cornerRadius = 10.0
        addIngredientsView.sendButton.layer.masksToBounds = true
        
        addIngredientsView.backgroundColor = UIColor(hex: "#caeded")
        addIngredientsView.ingredientsDescribe.layer.cornerRadius = 10.0
        addIngredientsView.ingredientsDescribe.layer.masksToBounds = true
        addIngredientsView.ingredientsImageView.layer.cornerRadius = 10.0
        addIngredientsView.ingredientsImageView.layer.masksToBounds = true
        addIngredientsView.containerView.layer.cornerRadius = 10.0
        addIngredientsView.containerView.layer.masksToBounds = true
        addIngredientsView.takePictureButtin.layer.cornerRadius = 10.0
        addIngredientsView.takePictureButtin.layer.masksToBounds = true
        addIngredientsView.choosePictureButton.layer.cornerRadius = 10.0
        addIngredientsView.choosePictureButton.layer.masksToBounds = true
        addIngredientsView.scannerButton.addTarget(self, action: #selector(barcodeScanner), for: .touchUpInside)
        addIngredientsView.choosePictureButton.addTarget(self, action: #selector(choosePicture), for: .touchUpInside)
        addIngredientsView.takePictureButtin.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        addIngredientsView.ingredientsController = self
        addIngredientsView.delegate = self
        
        guard let fridgeID = fridgeData?.id else {
            alertTitle("開發錯誤: 沒有獲取到ID", self, "需要修正")
            return
        }
        addIngredientsView.fridgeId = fridgeID
        
        guard let presetUrl = imageURL else {
            alertTitle("開發錯誤: 沒有獲取成功初始url string", self, "需要修正")
            return
        }
        addIngredientsView.imageUrl = presetUrl

        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut)
        animator.addAnimations {
            addIngredientsView.frame.origin.y = CGFloat(150)
        }
        animator.startAnimation()

    }
    // MARK: 食材畫面功能 - 掃描條碼
    @objc func barcodeScanner(_ sender: UIButton) {
        guard let nextVC = UIStoryboard.barcodeScanner.instantiateViewController(
            withIdentifier: String(describing: BarcodeScannerViewController.self)
        ) as? BarcodeScannerViewController
        else {
            print("創建失敗")
            return
        }
        nextVC.getClosure { [weak senderSuperview = sender.superview] barcodeString, priceString in
            
            guard let senderSuperview = senderSuperview as? AddIngredientsView else { return }
            senderSuperview.barcodeTextField.text = barcodeString
            senderSuperview.barcode = barcodeString
            guard let price = Double(priceString) else {
                print("\(priceString) 出現問題")
                return
            }
            let result = Int(price * 4)
            let resultString = String(result)
            senderSuperview.priceTextfield.text = resultString
            
        } ingredientsCompletion: { [weak senderSuperview = sender.superview] ingredientsString in
            
            guard let senderSuperview = senderSuperview as? AddIngredientsView else { return }
            senderSuperview.ingredientsNameTextField.text = ingredientsString
            
        } errorCompletion: { [weak self] errorMessage in
            
            alertTitle(errorMessage, self!, "錯誤")
            
        }
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.modalTransitionStyle = .crossDissolve
        present(nextVC, animated: true)
    }
    
    @objc func choosePicture(_ sender: UIButton) {
        getImageGo(type: 2)
    }
    
    @objc func takePicture(_ sender: UIButton) {
        getImageGo(type: 1)
    }
    
}
// MARK: - 日曆控制
extension IngredientsViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let today = Date()
        if date < today {
            alert("不能選擇今日或之前的時間", self)
            return false
        }
        return true
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        print(dateFormatter.string(from: date))

        let targetView = findSubview(ofType: AddIngredientsView.self, in: (calendar.superview?.superview?.superview)!)
        guard let addIngredientsView = targetView else {
            print("日曆日期失敗")
            calendar.superview?.removeFromSuperview()
            return
        }
        addIngredientsView.expireTimeTextfield.text = dateFormatter.string(from: date)
        calendar.superview?.removeFromSuperview()
    }
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        if isDateToday(date) {
            return "今"
        }
        return nil
    }

}
// MARK: - 照片選擇控制區域
extension IngredientsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 去拍照或者去相册选择图片
    func getImageGo(type: Int) {
        takingPicture =  UIImagePickerController.init()
        if type == 1 {
            takingPicture.sourceType = .camera
            // 拍照时是否显示工具栏
            // takingPicture.showsCameraControls = true
        } else if type == 2 {
            takingPicture.sourceType = .photoLibrary
        }
        // 是否截取，设置为true在获取图片后可以将其截取成正方形
        takingPicture.allowsEditing = false
        takingPicture.delegate = self
        present(takingPicture, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        takingPicture.dismiss(animated: true, completion: nil)
        getImageClosure { [weak self] ingredientsImage in
            let addIngredientsView = findSubview(ofType: AddIngredientsView.self, in: (self?.view)!)
            addIngredientsView?.ingredientsImageView.image = ingredientsImage
        }
        
        if let originalImage = info[.originalImage] as? UIImage {
            // 照片來自相簿
            // image.image = originalImage
            getImageCompletionHandler!(originalImage)
            if let imageURL = info[.imageURL] as? URL {
                selectedFileURL = imageURL
                //print("相冊：\(imageURL)")
                let addIngredientsView = findSubview(ofType: AddIngredientsView.self, in: (self.view)!)
                addIngredientsView?.imageUrl = imageURL.absoluteString
            } else {
                // 將照片存儲到相冊並獲取 URL
                saveImageToPhotoAlbum(originalImage) { [weak self] photoUrl in
                    self?.selectedFileURL = photoUrl!
                    let addIngredientsView = findSubview(ofType: AddIngredientsView.self, in: self!.view )
                    addIngredientsView?.imageUrl = photoUrl!.absoluteString
                    //print("拍照：\(photoUrl)")
                }
            }
        } else if let editedImage = info[.editedImage] as? UIImage {
            // 拍攝的照片
            // image.image = editedImage
            getImageCompletionHandler!(editedImage)
            // 將照片存儲到相冊並獲取 URL
            saveImageToPhotoAlbum(editedImage) { [weak self] photoUrl in
                self?.selectedFileURL = photoUrl
                let addIngredientsView = findSubview(ofType: AddIngredientsView.self, in: self!.view )
                addIngredientsView?.imageUrl = photoUrl!.absoluteString
            }
        }
    }
    func saveImageToPhotoAlbum(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        // 在 `image(_:didFinishSavingWithError:contextInfo:)` 中獲取 URL
        self.completionHandler = completion
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("無法存儲照片: \(error.localizedDescription)")
            self.completionHandler?(nil)
        } else {
            // 從相冊中獲取最新的照片 URL
            fetchNewestPhotoURL { url in
                self.completionHandler?(url)
            }
        }
    }

    func fetchNewestPhotoURL(completion: @escaping (URL?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if let asset = fetchResult.firstObject {
            let options = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { _ in true }
            
            asset.requestContentEditingInput(with: options) { contentEditingInput, _ in
                completion(contentEditingInput?.fullSizeImageURL)
            }
        } else {
            completion(nil)
        }
    }
    
    func getImageClosure(completion: @escaping ((UIImage) -> Void)) {
        getImageCompletionHandler = completion
    }
}
// MARK: - MJRefresh
extension IngredientsViewController {
    @objc private func refreshAction() {
        self.ingredientTableView.mj_header?.beginRefreshing()
        getData()
        DispatchQueue.main.async {
            self.ingredientTableView.mj_header?.endRefreshing()
        }
    }
}
// MARK: 動作簡化
extension IngredientsViewController {
    private func getData() {
        userLastUseFridge { [weak self] (passFridgeData, passFridgeID) in
            self?.currentFridgeID = passFridgeID
            self?.fridgeData = passFridgeData
            self?.navigationItem.title = self?.fridgeData?.name
        } memberCompletion: { [weak self] passMemberData in
            self?.memberData = passMemberData
        } ingredientCompletion: { [weak self] passIngredientsData in
            self?.ingredientsData = sortByName(passIngredientsData)
            print("執行")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self?.view.removeAllLottieViews()
                self?.ingredientTableView.reloadData()
            }
        } fallCompletion: { [weak self] in
            self?.ingredientsData = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self?.view.removeAllLottieViews()
                self?.ingredientTableView.reloadData()
            }
        } loadding: { [weak self] in
            self?.animationView = .init(name: "loadding")
            self?.animationView!.frame = (self?.view.bounds)!
            self?.animationView!.contentMode = .scaleAspectFit
            self?.animationView!.loopMode = .loop
            self?.animationView!.animationSpeed = 1.3
            self?.view.addSubview((self?.animationView!)!)
            self?.animationView!.play()
        } 
        getInitialPictureURL { [weak self] returnURL in
            self?.imageURL = returnURL
        }
    }
}
// MARK: go member Page
extension IngredientsViewController {

    func goMemberPage() {
        guard let nextVC = UIStoryboard.members.instantiateViewController(
            withIdentifier: String(describing: MemberViewController.self)
        ) as? MemberViewController else {
            print("創建失敗")
            return
        }
        nextVC.currentFridgeID = currentFridgeID
        present(nextVC, animated: true, completion: nil)
    }
}

extension IngredientsViewController: UISearchBarDelegate {
    func search(_ searchTerm: String) {
        print("搜尋觸發")
        if searchTerm.isEmpty {
            print("沒有結果")
            // searchIngredientsData = ingredientsData
        } else {
            print("有結果")
            searchIngredientsData = ingredientsData
            ingredientsData = ingredientsData.filter {
                $0.name.contains(searchTerm)
            }
            header?.dataArray = ingredientsData
        }
        ingredientTableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchTerm = searchBar.text ?? ""
        search(searchTerm)
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // 清除按鈕被按下，搜索文字被清空
            // 在這裡處理相應操作
            print("清除按鈕觸發")
            getData()
        }
    }

}
