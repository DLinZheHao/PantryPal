//
//  ChatViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/6.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Member {
  let name: String
  let color: UIColor
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
class ChatViewController: MessagesViewController {

    var member: Member!
    let sender = Sender(senderId: "0528", displayName: "哲豪")
    let sender2 = Sender(senderId: "other", displayName: "西瓜")
    let sender3 = Sender(senderId: "self2", displayName: "南瓜")
    var messages: [Message] = []
    
    let customInputView = InputView()
    var inputTextField: UITextField?
    var sendButton: UIButton?
    
    let inputBarView = SlackInputBar()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 測試訊息陣列
        messages.append(Message(sender: sender2,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .photo(Media(url: nil,
                                                   image: .asset(.calendar_select),
                                                   placeholderImage: .asset(.calendar_not_select)!,
                                                   size: CGSize(width: 250, height: 100)))))
        messages.append(Message(sender: sender2,
                                messageId: "2",
                                sentDate: Date(),
                                kind: .photo(Media(url: nil,
                                                   image: .asset(.calendar_select),
                                                   placeholderImage: .asset(.calendar_not_select)!,
                                                   size: CGSize(width: 250, height: 100)))))
        messages.append(Message(sender: sender3,
                                messageId: "3",
                                sentDate: Date(),
                                kind: .photo(Media(url: nil,
                                                   image: .asset(.calendar_select),
                                                   placeholderImage: .asset(.calendar_not_select)!,
                                                   size: CGSize(width: 250, height: 100)))))
        inputBarView.delegate = self
        inputBarView.controller = self
        
        
//        customInputView.backgroundColor = .secondarySystemBackground
//
//        customInputView.setUp { [weak self] (returnTextfield, returnButton) in
//            self?.sendButton = returnButton
//            self?.inputTextField = returnTextfield
//            print("有設定到")
//            self?.sendButton?.addTarget(self, action: #selector(inputBarSend), for: .touchUpInside)
//        }
//
        inputBarType = .custom(inputBarView)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messagesCollectionView.reloadData()
        navigationItem.title = "xx 聊天室"
    }
    @objc func customButtonTapped() {
        // 自訂按鈕的點擊事件處理
        print("Custom button tapped!")
    }

}
extension ChatViewController: MessagesDataSource {
    // MARK: 選擇目前用戶
    var currentSender: MessageKit.SenderType {
        return sender
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageTopLabelHeight(
       for message: MessageType,
       at indexPath: IndexPath,
       in messagesCollectionView: MessagesCollectionView) -> CGFloat {
       
       return 12
     }
     
     func messageTopLabelAttributedText(
       for message: MessageType,
       at indexPath: IndexPath) -> NSAttributedString? {
       
       return NSAttributedString(
         string: message.sender.displayName,
         attributes: [.font: UIFont.systemFont(ofSize: 12)])
     }
}
extension ChatViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
}
extension ChatViewController: MessagesDisplayDelegate {
    func inputBar(_: InputBarAccessoryView, textViewTextDidChangeTo _: String) {
        
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    // 當用戶點擊發送按鈕時調用
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // 創建一個新的文字訊息
        if !text.isEmpty {
            let message = Message(sender: sender,
                                  messageId: UUID().uuidString,
                                  sentDate: Date(),
                                  kind: .text(text))
            
            // 添加到訊息陣列
            messages.append(message)
        }
        if !inputBarView.imageArray.isEmpty {
            for image in inputBarView.imageArray {
                messages.append(Message(sender: sender,
                                        messageId: "1",
                                        sentDate: Date(),
                                        kind: .photo(Media(url: nil,
                                                           image: image,
                                                           placeholderImage: .asset(.calendar_not_select)!,
                                                           size: image.size))))
            }
        }
        // 清空輸入欄的文字
        inputBar.inputTextView.text = ""
        // 清空所有資料
        inputBarView.attachmentManager.invalidate()
        inputBarView.imageURLArray = []
        inputBarView.imageArray = []
        // 重新加載聊天視圖
        messagesCollectionView.reloadData()
        // 滾動到最後一條訊息
        messagesCollectionView.scrollToLastItem(animated: true)
    }
}

//extension ChatViewController {
//    @objc private func inputBarSend() {
//        let message = Message(sender: sender,
//                              messageId: UUID().uuidString,
//                              sentDate: Date(),
//                              kind: .text(inputTextField!.text!))
//        // 添加到訊息陣列
//        messages.append(message)
//
//        // 清空輸入欄的文字
//        guard let inputTextField = inputTextField else { return }
//        inputTextField.text = ""
//        // 重新加載聊天視圖
//        messagesCollectionView.reloadData()
//
//        // 滾動到最後一條訊息
//        messagesCollectionView.scrollToLastItem(animated: true)
//    }
//
//}
