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
    
    var ingredientsData: PresentIngredientsData?
    var completionHandler: ((URL?) -> Void)?
    var getImageCompletionHandler: ((UIImage) -> Void)?
    
    var imageURL: String?
    var selectedFileURL: URL?
    var takingPicture: UIImagePickerController!
    
    @IBOutlet weak var ingredientsImage: UIImageView!
    @IBOutlet weak var ingredientsName: UITextField!
    @IBOutlet weak var ingredientsPrice: UITextField!
    @IBOutlet weak var ingredientsExpiration: UITextField!
    @IBOutlet weak var ingredientsBarcode: UITextField!
    @IBOutlet weak var ingredientsStoreStatus: UISegmentedControl!
    @IBOutlet weak var ingredientsNotification: UISegmentedControl!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
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
        
        if ingredientsData.enableNotifications {
            ingredientsNotification.selectedSegmentIndex = 1
        } else {
            ingredientsNotification.selectedSegmentIndex = 0
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
        navigationController?.pushViewController(nextVC, animated: true)
    }

}
// MARK: 照片功能連接
extension IngredientsDetailViewController {
    @IBAction func choosePicture(_ sender: UIButton) {
        getImageGo(type: 2)
    }
    
    @IBAction  func takePicture(_ sender: UIButton) {
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
        }else if type == 2 {
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
            // MARK: ---------- 施工開始區域 -----------------
            ingredientsImage.image = ingredientsImage
            // MARK: ---------- 施工結束區域 -----------------
        }
        
        if let originalImage = info[.originalImage] as? UIImage {
            // 照片來自相簿
            // image.image = originalImage
            getImageCompletionHandler!(originalImage)
            if let imageURL = info[.imageURL] as? URL {
                selectedFileURL = imageURL
                // MARK: ---------- 施工開始區域 -----------------
                let addIngredientsView = findSubview(ofType: AddIngredientsView.self, in: (self.view)!)
                addIngredientsView?.imageUrl = imageURL.absoluteString
                // MARK: ---------- 施工結束區域 -----------------
            } else {
                // 將照片存儲到相冊並獲取 URL
                saveImageToPhotoAlbum(originalImage) { [weak self] photoUrl in
                    self?.selectedFileURL = photoUrl!
                    // MARK: ---------- 施工開始區域 -----------------
                    let addIngredientsView = findSubview(ofType: AddIngredientsView.self, in: self!.view )
                    addIngredientsView?.imageUrl = photoUrl!.absoluteString
                    // MARK: ---------- 施工結束區域 -----------------
                }
            }
        } else if let editedImage = info[.editedImage] as? UIImage {
            // 拍攝的照片
            // image.image = editedImage
            getImageCompletionHandler!(editedImage)
            // 將照片存儲到相冊並獲取 URL
            saveImageToPhotoAlbum(editedImage) { [weak self] photoUrl in
                self?.selectedFileURL = photoUrl
                // MARK: ---------- 施工開始區域 -----------------
                let addIngredientsView = findSubview(ofType: AddIngredientsView.self, in: self!.view )
                addIngredientsView?.imageUrl = photoUrl!.absoluteString
                // MARK: ---------- 施工結束區域 -----------------
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

        let targetView = findSubview(ofType: AddIngredientsView.self, in: (calendar.superview?.superview?.superview)!)
        guard let addIngredientsView = targetView else {
            print("日曆日期失敗")
            calendar.superview?.removeFromSuperview()
            return
        }
        addIngredientsView.expireTimeTextfield.text = dateFormatter.string(from: date)
        calendar.superview?.removeFromSuperview()
    }
}
