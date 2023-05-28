//
//  AddIngredientsView.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/25.
//
import UIKit
import FSCalendar
class AddIngredientsView: UIView, FSCalendarDelegate {
    var fridgeId: String?
    var ingredientsController: IngredientsViewController?
    var imageUrl: String?
    var barcode: String?
    var isEnable = false
    
    @IBOutlet weak var barcodeTextField: UITextField!
    @IBOutlet weak var ingredientsNameTextField: UITextField!
    @IBOutlet weak var priceTextfield: UITextField!
    @IBOutlet weak var scannerButton: UIButton!
    @IBOutlet weak var expireTimeTextfield: UITextField!
    @IBOutlet weak var ingredientsImageView: UIImageView!
    @IBOutlet weak var ingredientsDescribe: UITextView!
    
    @IBOutlet weak var takePictureButtin: UIButton!
    @IBOutlet weak var choosePictureButton: UIButton!
    @IBOutlet weak var storeStatusSegment: UISegmentedControl!
    @IBOutlet weak var enableImageView: UIImageView! {
        didSet {
            enableImageView.isHidden = true
        }
    }
    @IBOutlet weak var containerView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(enableAlert))
            containerView.addGestureRecognizer(tapGesture)
        }
    }
    
}
extension AddIngredientsView {
    // MARK: 日曆選擇日期
    @IBAction private func chooseCalendar() {
        guard let calendarView = UINib(nibName: "Calendar", bundle: nil).instantiate(withOwner: self, options: nil).first as? CalendarView else {
            print("畫面創建失敗")
            return
        }
        self.superview?.addSubview(calendarView)
        calendarView.calendar.delegate = ingredientsController
        calendarView.calendar.dataSource = ingredientsController
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: 150),
            calendarView.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor),
            calendarView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    @IBAction private func sendData() {
        let priceText = priceTextfield.text
        let price = Double(priceText ?? "0")
        let storeStatus = storeStatusSegment.selectedSegmentIndex
        guard let url = imageUrl else {
            alertTitle("開發錯誤 url", ingredientsController!, "需要修正")
            return
        }
        guard let expireDate = expireTimeTextfield.text, !expireDate.isEmpty else {
            alertTitle("沒有選擇過期時間", ingredientsController!, "提示")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        
        guard let date = dateFormatter.date(from: expireDate) else {
            alertTitle("開發錯誤 日期轉換", ingredientsController!, "需要修正")
            return
        }
        guard let belongFridgeId = fridgeId else {
            alertTitle("開發錯誤 沒有冰箱id", ingredientsController!, "需要修正")
            return
        }
        
        guard let fileURL = URL(string: url) else {
            print("沒有選取圖片")
            return
        }
        guard let name = ingredientsNameTextField.text else {
            alertTitle("食材名稱輸入格為空", ingredientsController!, "提示")
            return
        }
        let isNotificationEnable = isEnable
        let barcode = barcode ?? ""
        let describe = ingredientsDescribe.text ?? ""
        uploadPictureToFirebase(fileURL) { (url, error) in
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
                                                   enableNotification: isNotificationEnable,
                                                   describe: describe,
                                                   expiration: date,
                                                   belongFridge: belongFridgeId)

                    createNewIndredients(data!)
                } else {
                    // 無法取得圖片的下載 URL
                    print("無法獲取圖片的下載 URL")
                }
            }
        }
        removeFromSuperview()
    }

    @objc func enableAlert() {
        enableImageView.isHidden = isEnable
        isEnable = !isEnable
    }
}

