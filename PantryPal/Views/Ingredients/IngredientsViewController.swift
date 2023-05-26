//
//  IngredientsViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//

import UIKit
import FSCalendar
import Photos

class IngredientsViewController: UIViewController {
    
    var completionHandler: ((URL?) -> Void)?
    var getImageCompletionHandler: ((UIImage) -> Void)?
    
    var selectedFileURL: URL?
    var takingPicture: UIImagePickerController!
    
    var fridgeData: FridgeData?
    var memberData: [MemberData]?
    var ingredientsData: [IngredientData]?
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var changeFridgeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLastUseFridge { [weak self] passFridgeData in
            self?.fridgeData = passFridgeData
            self?.textLabel.text = self?.fridgeData?.name
            self?.changeFridgeButton.setTitle(self?.fridgeData?.name, for: .normal)
        } memberCompletion: { [weak self] passMemberData in
            self?.memberData = passMemberData
        } ingredientCompletion: { [weak self] passIngredientsData in
            self?.ingredientsData = passIngredientsData
        }
    }

}
// 新增食材畫面 掃描條碼 照片
extension IngredientsViewController {
    
    @IBAction private func showAddIngredientsView() {
        guard let addIngredientsView = UINib(nibName: "AddIngredients", bundle: nil).instantiate(withOwner: self, options: nil).first as? AddIngredientsView else {
            print("畫面創建失敗")
            return
        }
        view.addSubview(addIngredientsView)
        
        addIngredientsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addIngredientsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            addIngredientsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addIngredientsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addIngredientsView.heightAnchor.constraint(equalToConstant: 400)
        ])
        addIngredientsView.scannerButton.addTarget(self, action: #selector(barcodeScanner), for: .touchUpInside)
        addIngredientsView.choosePictureButton.addTarget(self, action: #selector(choosePicture), for: .touchUpInside)
        addIngredientsView.takePictureButtin.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        addIngredientsView.ingredientsController = self
    }
    
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
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc func choosePicture(_ sender: UIButton) {
        getImageGo(type: 2)
    }
    
    @objc func takePicture(_ sender: UIButton) {
        getImageGo(type: 1)
    }
}
// 日曆控制
extension IngredientsViewController: FSCalendarDelegate, FSCalendarDataSource {
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
            print("失敗")
            calendar.superview?.removeFromSuperview()
            return
        }
        addIngredientsView.expireTimeTextfield.text = dateFormatter.string(from: date)
        calendar.superview?.removeFromSuperview()
    }
}

// 照片選擇控制區域
extension IngredientsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //去拍照或者去相册选择图片
    func getImageGo(type:Int){
        takingPicture =  UIImagePickerController.init()
        if(type == 1) {
            takingPicture.sourceType = .camera
            //拍照时是否显示工具栏
            //takingPicture.showsCameraControls = true
        }else if( type == 2 ) {
            takingPicture.sourceType = .photoLibrary
        }
        //是否截取，设置为true在获取图片后可以将其截取成正方形
        takingPicture.allowsEditing = false
        takingPicture.delegate = self
        present(takingPicture, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        takingPicture.dismiss(animated: true, completion: nil)
        getImageClosure { [weak self] ingredientsImage in
            let addIngredientsView = findSubview(ofType: AddIngredientsView.self, in: (self?.view)!)
            addIngredientsView?.ingredientsImageView.image = ingredientsImage
        }
        
        if let originalImage = info[.originalImage] as? UIImage {
            // 照片來自相簿
            //image.image = originalImage
            getImageCompletionHandler!(originalImage)
            if let imageURL = info[.imageURL] as? URL {
                selectedFileURL = imageURL
                print("相冊：\(imageURL)")
            } else {
                // 將照片存儲到相冊並獲取 URL
                saveImageToPhotoAlbum(originalImage) { [weak self] photoUrl in
                    self?.selectedFileURL = photoUrl!
                    print("拍照：\(photoUrl)")
                }
            }
        } else if let editedImage = info[.editedImage] as? UIImage {
            // 拍攝的照片
            //image.image = editedImage
            
            // 將照片存儲到相冊並獲取 URL
            saveImageToPhotoAlbum(editedImage) { [weak self] url in
                self?.selectedFileURL = url
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
