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
    private var successCreateView: LottieAnimationView?
    
    var isSearch = false
    var storeStatus = ["冷藏", "冷凍", "常溫"]
    
    var currentUserName: String?
    var currentUserID: String?
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
    var blackBlurEffectView: UIVisualEffectView?
    
    @IBOutlet weak var ingredientTableView: UITableView! {
        didSet {
            ingredientTableView.delegate = self
            ingredientTableView.dataSource = self
        }
    }
    
    @IBOutlet weak var emptyImage: UIImageView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyImage.isHidden = true
        emptyLabel.isHidden = true
        
        navigationSetting()
        layoutFAB()
        getData()
        
        getUserData { [weak self] (userName, userID) in
            self?.currentUserID = userID
            self?.currentUserName = userName
        }
        
        ingredientTableView.lk_registerCellWithNib(identifier: String(describing: IngredientsTableViewCell.self), bundle: nil)
        ingredientTableView.lk_registerHeaderWithNib(identifier: String(describing: HeaderView.self), bundle: nil)
        ingredientTableView.sectionHeaderTopPadding = 0
        
        let newHeader = MJRefreshStateHeader(refreshingTarget: self, refreshingAction: #selector(refreshAction))
        self.ingredientTableView.mj_header = newHeader
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if ingredientsData.isEmpty {
            emptyImage.isHidden = false
            emptyLabel.isHidden = false
        }
        tabBarController?.tabBar.isHidden = false
    }
    // MARK: navigation bar item 設置
    func navigationSetting() {
        let navigationBar = navigationController?.navigationBar
        let navigationBarAppearance = UINavigationBarAppearance()
        
        navigationBarAppearance.shadowColor = .clear
        navigationBar?.scrollEdgeAppearance = navigationBarAppearance
        navigationBar?.standardAppearance = navigationBarAppearance
        
        let buttonImage = UIImage(systemName: "ellipsis.bubble")
        let button = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(chatButtonTapped))

        let refreshButtonImage = UIImage(systemName: "arrow.triangle.2.circlepath")
        let refreshButton = UIBarButtonItem(image: refreshButtonImage, style: .plain, target: self, action: #selector(refreshAction))
        
        navigationItem.rightBarButtonItems = [button, refreshButton]

    }
    @objc func chatButtonTapped() {
        let nextVC = UIStoryboard.chat.instantiateInitialViewController()!
        guard let controller = nextVC as? ChatViewController else {
            self.navigationController?.pushViewController(nextVC, animated: true)
            return
        }
        controller.currentUserID = currentUserID!
        controller.curruentUserName = currentUserName!
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    private func tabbarSwitch(_ switchBool: Bool) {
        if let tabBarController = self.tabBarController {
            if let tabItems = tabBarController.tabBar.items {
                for tabItem in tabItems {
                    tabItem.isEnabled = switchBool
                }
            }
        }
    }
}
// MARK: - Floaty
extension IngredientsViewController {
    func layoutFAB() {
        let floaty = Floaty()
        floaty.addItem("新增食材", icon: .asset(.outline_kitchen_black_36pt)) { [weak self] (_) in
            self?.showAddIngredientsView()
        }
        floaty.addItem("新增冰箱", icon: .asset(.outline_add_box_black_36pt)) { [weak self] (_) in
            self?.setUpCreatFridgeView()
        }
        floaty.addItem("查看成員", icon: .asset(.outline_people_black_36pt)) { [weak self] (_) in
            self?.goMemberPage()
        }
        floaty.addItem("切換冰箱", icon: .asset(.outline_change_circle_black_36pt)) { [weak self] (_) in
            self?.changeFridge()
        }
        floaty.addItem("智能小助手", icon: .asset(.chatGPT_select)) { [weak self] (_) in
            self?.goChatGPT()
        }
        floaty.plusColor = .white
        floaty.paddingX = self.view.frame.width / 2 - floaty.frame.width / 2 - CGFloat(155)
        floaty.paddingY = 120
        floaty.sticky = true
        self.view.addSubview(floaty)
    }
}
// MARK: - ChatGPT
extension IngredientsViewController {
    private func goChatGPT() {
        let nextVC = UIStoryboard.chatGPT.instantiateInitialViewController()!
        guard let viewController = nextVC as? ChatGPTViewController else {
            self.navigationController?.pushViewController(nextVC, animated: true)
            return
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
// MARK: - 切換冰箱
extension IngredientsViewController {
    private func changeFridge() {
        guard let nextVC = UIStoryboard.fridgeList.instantiateViewController(
            withIdentifier: String(describing: FridgeListViewController.self)
        ) as? FridgeListViewController
        else { return }
        
        nextVC.currentFridgeID = currentFridgeID!
        nextVC.ingredientsViewController = self
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.modalTransitionStyle = .crossDissolve
        present(nextVC, animated: true, completion: nil)
    }
}
// MARK: - 新增冰箱
extension IngredientsViewController {
    private func setUpCreatFridgeView() {
        tabbarSwitch(false)
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = BlackEffectBackgroundView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blackBlurEffectView = blurEffectView
        view.addSubview(blurEffectView)

        let customView = UINib(nibName: "CreateFridgeView", bundle: nil).instantiate(withOwner: self, options: nil).first
        guard let createFridgeView = customView as? CreateFridgeView else { return }
        
        createFridgeView.frame = CGRect(x: 0, y: 900, width: view.frame.width, height: 190)
        view.addSubview(createFridgeView)
        
        createFridgeView.setUp()
        createFridgeView.closeButton.addTarget(self, action: #selector(closeCreateView), for: .touchUpInside)
        createFridgeView.sendButton.addTarget(self, action: #selector(createNewFridgeAction), for: .touchUpInside)
        
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut)
        animator.addAnimations {
            if let navigationBar = self.navigationController?.navigationBar {
                let convertedFrame = navigationBar.convert(navigationBar.bounds, to: self.view)
                let yPosition = convertedFrame.maxY
                createFridgeView.frame.origin.y = yPosition
            }
        }
        animator.startAnimation()
        
    }
    
    @objc private func closeCreateView(_ sender: UIButton) {
        tabbarSwitch(true)
        
        let targetView = findSubview(ofType: BlackEffectBackgroundView.self, in: self.view)
        guard let blackEffectBackgroundView = targetView else {
            sender.superview?.removeFromSuperview()
            return
        }
        blackEffectBackgroundView.removeFromSuperview()
        sender.superview?.removeFromSuperview()
    }
    @objc private func createNewFridgeAction(_ sender: UIButton) {
        tabbarSwitch(true)
        guard let createView = sender.superview as? CreateFridgeView else { return }
        
        if !checkEnterIsEmpty(createView.fridgeNameTextfield) {
            guard let fridgeName = createView.fridgeNameTextfield.text else { return }
            createNewFridge(fridgeName) { [weak self] in

                // MARK: Lotties 動畫設置
                self?.successCreateView = .init(name: "ingredient_success")
                self?.successCreateView!.loopMode = .playOnce
                if let navigationBar = self?.navigationController?.navigationBar {
                    let convertedFrame = navigationBar.convert(navigationBar.bounds, to: self!.view)
                    let yPosition = convertedFrame.maxY
                    self?.successCreateView!.frame = (self?.view.frame)!
                    self?.successCreateView!.frame.origin.y = yPosition
                }
                self?.successCreateView!.contentMode = .scaleAspectFit
                self?.view.addSubview((self?.successCreateView!)!)
                self?.successCreateView!.play { (_) in
                    let targetView = findSubview(ofType: BlackEffectBackgroundView.self, in: self!.view)
                    guard let blackEffectBackgroundView = targetView else {
                        sender.superview?.removeFromSuperview()
                        return
                    }
                    blackEffectBackgroundView.removeFromSuperview()
                    sender.superview?.removeFromSuperview()
                    self?.successCreateView?.removeFromSuperview()
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
        let targetView = findSubview(ofType: BlackEffectBackgroundView.self, in: self.view)
        guard let blackEffectBackgroundView = targetView else {
            return
        }
        blackEffectBackgroundView.removeFromSuperview()
    }
}
// MARK: - tableView 控制
extension IngredientsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isSearch {
            if ingredientsData.isEmpty == true {
                ingredientTableView.isHidden = true
                emptyImage.isHidden = false
                emptyLabel.isHidden = false
            } else {
                ingredientTableView.isHidden = false
                emptyImage.isHidden = true
                emptyLabel.isHidden = true
            }
        }
        return ingredientsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: IngredientsTableViewCell.self),
            for: indexPath)
        guard let ingredientsCell = cell as? IngredientsTableViewCell else { return cell }
        
        ingredientsCell.styleSetting()
        ingredientsCell.textLabelSetting(name: ingredientsData[indexPath.row].name,
                                         price: "\(String(Int(ingredientsData[indexPath.row].price)))元",
                                         status: "\(storeStatus[ingredientsData[indexPath.row].storeStatus])保存")
        ingredientsCell.expirationLabel.text = getLeftTime(ingredientsData[indexPath.row].expiration)
        ingredientsCell.updateCellColorBasedOnExpiration()
        ingredientsCell.shouldEnableNotificationsImage(isEnable: ingredientsData[indexPath.row].enableNotifications)
        ImageDownloader.shared.downloadImage(from: URL(string: ingredientsData[indexPath.row].url)!) { (image) in
            if let image = image {
                DispatchQueue.main.async {
                    ingredientsCell.ingredientsImage.image = image
                }
            } else {
                print("載入圖片失敗")
            }
        }

        return ingredientsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC = UIStoryboard.ingredientsDetail.instantiateViewController(
            withIdentifier: String(describing: IngredientDetailTableViewController.self)
        ) as? IngredientDetailTableViewController
        else {
            print("創建失敗")
            return }
        nextVC.ingredientsData = ingredientsData[indexPath.row]
        guard let fridgeID = currentFridgeID else {
            alertTitle("開發錯誤: 沒有按照流程獲得ID", self, "需要修正")
            return 
        }
        nextVC.fridgeId = fridgeID
        nextVC.ingredientController = self
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
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { [weak self] (_, _, completionHandler) in
            if let id = self?.currentFridgeID,
               let ingredientsID = self?.ingredientsData[indexPath.row].ingredientsID {
                deleteIngredients(id, ingredientsID) { [weak self] in
                    self?.getData()
                }
            }
            completionHandler(true)
        }
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = true
        
        return swipeConfiguration
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0.0
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1.0
        }
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let ingredientDataArray = self.ingredientsData.isEmpty ? nil : self.ingredientsData,
              let currentFridgeID = self.currentFridgeID else { return nil }
        let runOutAction = UIContextualAction(style: .normal, title: "用完") { [weak self] (_, _, completionHandler) in
            self?.historyAction(action: 0, ingredietnsDataArray: ingredientDataArray, indexPath: indexPath, fridgeID: currentFridgeID)
            completionHandler(true)
        }
        let expiredAction = UIContextualAction(style: .normal, title: "過期") { [weak self] (_, _, completionHandler) in
            self?.historyAction(action: 1, ingredietnsDataArray: ingredientDataArray, indexPath: indexPath, fridgeID: currentFridgeID)
            completionHandler(true)
        }
        let throwAway = UIContextualAction(style: .normal, title: "丟棄") { [weak self] (_, _, completionHandler) in
            self?.historyAction(action: 2, ingredietnsDataArray: ingredientDataArray, indexPath: indexPath, fridgeID: currentFridgeID)
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
        tabbarSwitch(false)
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = BlackEffectBackgroundView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blackBlurEffectView = blurEffectView
        view.addSubview(blurEffectView)
        
        let customView = UINib(nibName: "AddIngredients", bundle: nil).instantiate(withOwner: self, options: nil).first
        guard let addIngredientsView = customView as? AddIngredientsView else { return }
        addIngredientsView.frame = CGRect(x: 0, y: 900, width: view.frame.width, height: 400)
        view.addSubview(addIngredientsView)
        
        // MARK: - 將一些 addIngredientsView 的設定，弄到 addIngredientsView 成為 func
        addIngredientsView.addIngredientsViewSetUp()
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
            if let navigationBar = self.navigationController?.navigationBar {
                let convertedFrame = navigationBar.convert(navigationBar.bounds, to: self.view)
                let yPosition = convertedFrame.maxY
                addIngredientsView.frame.origin.y = yPosition
            }
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
        let myCalendar = Calendar.current

        // 從現在的日期和時間創建 `Date` 實例
        let currentDate = Date()

        // 將日期元素（年、月、日）提取出來
        let dateComponents = myCalendar.dateComponents([.year, .month, .day], from: currentDate)

        // 設定日期元素的時、分、秒為 0
        var newDateComponents = DateComponents()
        newDateComponents.year = dateComponents.year
        newDateComponents.month = dateComponents.month
        newDateComponents.day = dateComponents.day
        newDateComponents.hour = 0
        newDateComponents.minute = 0
        newDateComponents.second = 0

        // 使用 `Calendar` 創建當天凌晨 12 點的 `Date` 實例
        let midnightDate = myCalendar.date(from: newDateComponents)

        if date < midnightDate! {
            alert("不能選擇之前的時間", self)
            return false
        }
        return true
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        
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
            getImageCompletionHandler!(originalImage)
            if let imageURL = info[.imageURL] as? URL {
                selectedFileURL = imageURL
                let addIngredientsView = findSubview(ofType: AddIngredientsView.self, in: (self.view)!)
                addIngredientsView?.imageUrl = imageURL.absoluteString
            } else {
                // 將照片存儲到相冊並獲取 URL
                saveImageToPhotoAlbum(originalImage) { [weak self] photoUrl in
                    self?.selectedFileURL = photoUrl!
                    let addIngredientsView = findSubview(ofType: AddIngredientsView.self, in: self!.view )
                    addIngredientsView?.imageUrl = photoUrl!.absoluteString
                }
            }
        } else if let editedImage = info[.editedImage] as? UIImage {
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
        self.completionHandler = completion
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            self.completionHandler?(nil)
        } else {
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
    }
}
// MARK: 動作簡化
extension IngredientsViewController {
    func getData() {
        fetchFridgeData() { [weak self] (passFridgeData, passFridgeID) in
            self?.currentFridgeID = passFridgeID
            self?.fridgeData = passFridgeData
            self?.navigationItem.title = self?.fridgeData?.name
        } memberDataFetchCompletion: { [weak self] passMemberData in
            self?.memberData = passMemberData
        } ingredientDataFetchCompletion: { [weak self] passIngredientsData in
            self?.ingredientsData = sortByName(passIngredientsData)
            self?.header?.dataArray = sortByName(passIngredientsData)
            print("執行")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self?.header?.orderButton.setTitle("名稱排序▾", for: .normal)
                self?.view.removeAllLottieViews()
                self?.ingredientTableView.reloadData()
                self?.ingredientTableView.mj_header?.endRefreshing()
            }
        } fallHandler: { [weak self] in
            self?.ingredientsData = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self?.view.removeAllLottieViews()
                self?.ingredientTableView.reloadData()
            }
        } loadingHandler: { [weak self] in
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
        ) as? MemberViewController else { return }
        nextVC.currentFridgeID = currentFridgeID
        present(nextVC, animated: true, completion: nil)
    }
}
// MARK: searchBar 控制區域
extension IngredientsViewController: UISearchBarDelegate {
    func search(_ searchTerm: String) {
        isSearch = true
        if searchTerm.isEmpty {
            print("沒有結果")
        } else {
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
            isSearch = false
            getData()
        }
    }
}
