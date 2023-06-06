//
//  IngredientsDetailViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/29.
//

import UIKit
import Photos
import FSCalendar

class IngredientsDetailViewController: UIViewController {
    
    var fridgeId: String?
    var ingredientsData: PresentIngredientsData?
    var completionHandler: ((URL?) -> Void)?
    var getImageCompletionHandler: ((UIImage) -> Void)?
    var originNotificationSetting: Bool?
    
    var imageURL: String?
    var selectedFileURL: String?
    var takingPicture: UIImagePickerController!
    var chineseCalendar: Calendar!
    
    @IBOutlet weak var choosePictureButton: UIButton!
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var ingredientsImage: UIImageView!
    @IBOutlet weak var ingredientsName: UITextField!
    @IBOutlet weak var ingredientsPrice: UITextField!
    @IBOutlet weak var ingredientsExpiration: UITextField!
    @IBOutlet weak var ingredientsBarcode: UITextField!
    @IBOutlet weak var ingredientsDescription: UITextView!
    @IBOutlet weak var ingredientsStoreStatus: UISegmentedControl!
    @IBOutlet weak var ingredientsNotification: UISegmentedControl!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var dismissImageView: UIImageView!
    @IBAction private func chooseCalendar() {
        guard let calendarView = UINib(nibName: "Calendar", bundle: nil).instantiate(withOwner: self, options: nil).first as? CalendarView else {
            print("畫面創建失敗")
            return
        }
        view.addSubview(calendarView)
        chineseCalendar = Calendar(identifier: .chinese)
        calendarView.calendar.pagingEnabled = true
        calendarView.calendar.scrollEnabled = true
        
        let locale = Locale(identifier: "zh_CN")
        calendarView.calendar.locale = locale
        calendarView.calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        calendarView.calendar.appearance.headerDateFormat = "yyyy年MM月"
        calendarView.calendar.delegate = self
        calendarView.calendar.dataSource = self
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 250),
            calendarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            calendarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            calendarView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置默认状态下的字体颜色
        ingredientsStoreStatus.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        // 设置选中状态下的字体颜色
        ingredientsStoreStatus.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(hex: "487A71")], for: .selected)
        setUp()
        setDismissAction() 
        setIngredientsData()
    }
}
// MARK: 畫面設定
extension IngredientsDetailViewController {
    private func setIngredientsData() {
        guard let ingredientsData = ingredientsData else {
            alertTitle("開發錯誤", self, "需要修正")
            return
        }
        ingredientsName.text = ingredientsData.name
        ingredientsPrice.text = String(ingredientsData.price)
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"

        let dateString = dateFormatter.string(from: ingredientsData.expiration)
        ingredientsExpiration.text = dateString
        
        ingredientsBarcode.text = ingredientsData.barcode
        ingredientsStoreStatus.selectedSegmentIndex = ingredientsData.storeStatus
        
        originNotificationSetting = ingredientsData.enableNotifications
        
        if ingredientsData.enableNotifications {
            ingredientsNotification.selectedSegmentIndex = 1
        } else {
            ingredientsNotification.selectedSegmentIndex = 0
        }
        imageURL = ingredientsData.url
        ingredientsDescription.text = ingredientsData.description
        guard let url = imageURL else {
            alertTitle("開發錯誤: 圖片url獲取失敗", self, "需要修正")
            return
        }
        UIImage.downloadImage(from: URL(string: url)!) { [weak self] image in
            DispatchQueue.main.async {
                self?.ingredientsImage.image = image
            }
        }
    }
}
// MARK: 掃描功能
extension IngredientsDetailViewController {
    @IBAction func barcodeScanner(_ sender: UIButton) {
        guard let nextVC = UIStoryboard.barcodeScanner.instantiateViewController(
            withIdentifier: String(describing: BarcodeScannerViewController.self)
        ) as? BarcodeScannerViewController
        else {
            print("創建失敗")
            return
        }
        nextVC.getClosure { [weak self] barcodeString, priceString in

            self?.ingredientsBarcode.text = barcodeString
            guard let price = Double(priceString) else {
                print("\(priceString) 出現問題")
                return
            }
            let result = Int(price * 4)
            let resultString = String(result)
            self?.ingredientsPrice.text = resultString
           
        } ingredientsCompletion: { [weak self] ingredientsString in

            self?.ingredientsName.text = ingredientsString

        } errorCompletion: { [weak self] errorMessage in
            alertTitle(errorMessage, self!, "錯誤")
        }
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.modalTransitionStyle = .crossDissolve
        present(nextVC, animated: true)
    }
}
// MARK: 照片功能連接
extension IngredientsDetailViewController {
    @IBAction func choosePicture(_ sender: UIButton) {
        getImageGo(type: 2)
    }
    
    @IBAction func takePicture(_ sender: UIButton) {
        getImageGo(type: 1)
    }
}
// MARK: - 照片選擇控制區域
extension IngredientsDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            self?.ingredientsImage.image = ingredientsImage
        }
        
        if let originalImage = info[.originalImage] as? UIImage {
            // 照片來自相簿
            // image.image = originalImage
            getImageCompletionHandler!(originalImage)
            if let imageURL = info[.imageURL] as? URL {
                self.imageURL = imageURL.absoluteString
            } else {
                // 將照片存儲到相冊並獲取 URL
                saveImageToPhotoAlbum(originalImage) { [weak self] photoUrl in
                    self?.imageURL = photoUrl?.absoluteString
                }
            }
        } else if let editedImage = info[.editedImage] as? UIImage {
            // 拍攝的照片
            // image.image = editedImage
            getImageCompletionHandler!(editedImage)
            // 將照片存儲到相冊並獲取 URL
            saveImageToPhotoAlbum(editedImage) { [weak self] photoUrl in
                self?.imageURL = photoUrl?.absoluteString
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
// MARK: - 日曆控制
extension IngredientsDetailViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let today = Date()
        if date <= today {
            return false
        }
        return true
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        print(dateFormatter.string(from: date))

        ingredientsExpiration.text = dateFormatter.string(from: date)
        calendar.superview?.removeFromSuperview()
    }
}
// MARK: - 送出資料
extension IngredientsDetailViewController {
    @IBAction private func sendData() {
        let priceText = ingredientsPrice.text
        let price = Double(priceText ?? "0")
        let storeStatus = ingredientsStoreStatus.selectedSegmentIndex
        guard let url = imageURL else {
            alertTitle("開發錯誤 url", self, "需要修正")
            return
        }
        guard let expireDate = ingredientsExpiration.text, !expireDate.isEmpty else {
            alertTitle("沒有選擇過期時間", self, "提示")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"

        guard let date = dateFormatter.date(from: expireDate) else {
            alertTitle("開發錯誤 日期轉換", self, "需要修正")
            return
        }
        print("測試日曆： \(date)")
        guard let belongFridgeId = fridgeId else {
            alertTitle("開發錯誤 沒有冰箱id", self, "需要修正")
            return
        }

        guard var fileURL = URL(string: url) else {
            print("沒有選取圖片")
            return
        }
        guard let name = ingredientsName.text else {
            alertTitle("食材名稱輸入格為空", self, "提示")
            return
        }
        guard let ingredientID = ingredientsData?.ingredientsID else {
            alertTitle("開發錯誤: 食材ID獲取失敗", self, "需要修正")
            return
        }
        
        let isNotificationEnable: Bool?

        if ingredientsNotification.selectedSegmentIndex == 0 {
            isNotificationEnable = false
        } else {
            isNotificationEnable = true
        }
        let barcode = ingredientsBarcode.text ?? ""
        let describe = ingredientsDescription.text ?? ""
        uploadPictureToFirebase(fileURL) { [weak self] (url, error) in
            if let error = error {
                // 上傳失敗，處理錯誤
                print("上傳失敗：\(error.localizedDescription)")
            } else {
                // 上傳成功，取得圖片的下載 URL
                if let downloadURL = url {
                    // 使用圖片的下載 URL 做相關操作
                    print("圖片上傳成功，下載 URL：\(downloadURL.absoluteString)")
                    
                    var data: DatabaseIngredientsData?
                    
                    data = DatabaseIngredientsData(barcode: barcode,
                                                   name: name,
                                                   price: price ?? 0,
                                                   storeStatus: storeStatus,
                                                   url: downloadURL.absoluteString,
                                                   enableNotification: isNotificationEnable!,
                                                   describe: describe,
                                                   expiration: date,
                                                   belongFridge: belongFridgeId)

                    if self?.originNotificationSetting == isNotificationEnable {
                        print("已經註冊過或是不需要開啟")
                    } else if self?.originNotificationSetting == false && isNotificationEnable == true {
                        notificationRegister(date, name, (self?.fridgeId)!)
                    } else if self?.originNotificationSetting == true && isNotificationEnable == false {
                        notificationDelete((self?.fridgeId)!)
                    }
                    // 修改已經存在的ingredients 資料
                    
                    reviseIngredientsData(ingredientID, data!)
                    self?.presentingViewController?.dismiss(animated: true)
                } else {
                    // 無法取得圖片的下載 URL
                    print("無法獲取圖片的下載 URL")
                }
            }
        }
    }
}
extension IngredientsDetailViewController {
    private func setDismissAction() {
        // 创建一个UITapGestureRecognizer对象
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))

        // 将手势识别器添加到UIImageView上
        dismissImageView.isUserInteractionEnabled = true
        dismissImageView.addGestureRecognizer(tapGesture)
    }
    @objc func imageViewTapped() {
        self.presentingViewController?.dismiss(animated: true)
    }
    private func setUp() {
        tabBarController?.tabBar.isHidden = true
        ingredientsImage.layer.cornerRadius = 10.0
        ingredientsImage.layer.masksToBounds = true
        choosePictureButton.layer.cornerRadius = 10.0
        choosePictureButton.layer.masksToBounds = true
        takePictureButton.layer.cornerRadius = 10.0
        takePictureButton.layer.masksToBounds = true
        ingredientsDescription.layer.cornerRadius = 10.0
        ingredientsDescription.layer.masksToBounds = true
        sendButton.layer.cornerRadius = 10.0
        sendButton.layer.masksToBounds = true
    }
}
