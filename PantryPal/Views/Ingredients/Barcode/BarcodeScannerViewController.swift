//
//  BarcodeScannerViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/5/26.
//

import UIKit
import AVFoundation
class BarcodeScannerViewController: UIViewController {
    
    typealias DataReturn =  (String, String) -> Void
    typealias IngredientsNameReturn = (String) -> Void
    typealias NotInDatabase = (String) -> Void
    
    var barcodeReturn: DataReturn?
    var ingredientsNameReturn: IngredientsNameReturn?
    var notInDatabase: NotInDatabase?
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var topbar: UIView!
    private let supportedCodeTypes = [ AVMetadataObject.ObjectType.upce,
                                       AVMetadataObject.ObjectType.ean8,
                                       AVMetadataObject.ObjectType.ean13 ]
    // 設定
    // AVCaptureSession 物件是用來協調來自影片輸入裝置至輸出的資料流
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        // AVCaptureDevice.default 類別設計作為特定裝置型態來找出所有可用裝置
        // 這裡指定支援媒體型態為 .video 的裝置
        // 取得後置鏡頭來擷取影片
        guard let captrueDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Error: Failed to get the camera device!")
            return
        }
        
        do {
            // 使用前一個裝置物件來取得 AVCaptureDeviceInput 類別的實例
            let input = try AVCaptureDeviceInput(device: captrueDevice)
            
            // 在擷取 session 設定輸入裝置
            captureSession.addInput(input)
            
            // session 輸出設定為一個 AVCaptureMetaDataOutput 物件 ， 為 QR Code 讀取的核心
            // AVCaptureMetaDataOutput 結合了 AVCaptureMetadataOutputObjectsDelegate 協定 ， 可攔截(intercept)任何來自輸入裝置所發現的元資料(metadata)，也就是裝置相機擷取的 QR CODE 或是條碼，並轉成人可以看得懂的格式
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // 設定委派並使用預設的調度佇列來執行 call back
            // 當新的元資料被擷取時，將物件交給委派做進一步處理，需要設定處理物件的佇列，且必須是 serial queue
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // 告訴 App 對哪一種元資料有興趣
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // 初始化影片預覽層，並將其作為子層加入 viewPreview 視圖的圖層中
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
            
            qrCodeFrameView = UIView()

            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
        } catch {
            print("Error: \(error)")
            return
        }
        
        view.bringSubviewToFront(messageLabel)
        view.bringSubviewToFront(topbar)
    }

}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 檢查  metadataObjects 陣列為非空值，它至少需包含一個物件
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
    
        // 取得元資料（metadata）物件
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else { return }
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            
            guard let barcodeObjectBounds = barcodeObject?.bounds else { return }
            qrCodeFrameView?.frame = barcodeObjectBounds
            
            if metadataObj.stringValue != nil {
                captureSession.stopRunning()
                messageLabel.text = metadataObj.stringValue
                guard let barcode = metadataObj.stringValue else { return }
                fetchIngredientApiData(barcode) { goodsName, goodsPrice in
                    sleep(2)
                    simpTradConversion(goodsName) { [weak self] convertName in
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
                            self?.barcodeReturn!(barcode, goodsPrice)
                            self?.ingredientsNameReturn!(convertName)
                        }
                    }
                } fallCompletion: { [weak self] errorMessage in
                    DispatchQueue.main.async {
                        self?.navigationController?.popViewController(animated: true)
                        self?.notInDatabase!(errorMessage)
                    }
                }
            }
        }
    }
}

extension BarcodeScannerViewController {
    func getClosure(barcodeCompletion: @escaping DataReturn, ingredientsCompletion: @escaping IngredientsNameReturn, errorCompletion: @escaping NotInDatabase) {
        barcodeReturn = barcodeCompletion
        ingredientsNameReturn = ingredientsCompletion
        notInDatabase = errorCompletion
    }
}
