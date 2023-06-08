//
//  ChatViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/6.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase

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
    var sender = Sender(senderId: "0528", displayName: "哲豪")
    let sender2 = Sender(senderId: "other", displayName: "西瓜")
    let sender3 = Sender(senderId: "self2", displayName: "南瓜")
    var messages: [Message] = []
    var messageDateArray: [MessageData] = []
    
    let customInputView = InputView()
    var inputTextField: UITextField?
    var sendButton: UIButton?
    
    let inputBarView = SlackInputBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        sender.senderId = currentUserID
        getChatMessage { [weak self] dataArray in
            self!.messageDateArray = findNewMessages(existingMessages: self!.messageDateArray, newMessages: dataArray)
            
            for messageData in self!.messageDateArray {
                if messageData.action == 0 {
                    let sender = Sender(senderId: messageData.senderID, displayName: messageData.name)
                    let message = Message(sender: sender,
                                          messageId: messageData.id,
                                          sentDate: Date(timeIntervalSince1970: messageData.sendDate),
                                          kind: .text(messageData.textContent))
                    self?.messages.append(message)
                } else if messageData.action == 1 {
                    let sender = Sender(senderId: messageData.senderID, displayName: messageData.name)
                    let url = URL(string: messageData.url)!
                    
                    // 創建占位圖片消息
                    let placeholderImage = UIImage.asset(.fridge)
                    let placeholderMediaItem = Media(url: url,
                                                     image: nil,
                                                     placeholderImage: placeholderImage!,
                                                     size: .zero)
                    let placeholderMessage = Message(sender: sender,
                                                      messageId: messageData.id,
                                                      sentDate: Date(timeIntervalSince1970: messageData.sendDate),
                                                      kind: .photo(placeholderMediaItem))
                    self?.messages.append(placeholderMessage)
                    
                    
                    // 下載圖片
                    UIImage.downloadImage(from: url) { [weak self] image in
                        guard let self = self else { return }

                        // 更新圖片消息
                        if let index = self.messages.firstIndex(where: { $0.messageId == messageData.id }) {
                            let mediaItem = Media(url: url,
                                                  image: image,
                                                  placeholderImage: placeholderImage!,
                                                  size: image?.size ?? .zero)
                            let updatedMessage = Message(sender: sender,
                                                          messageId: messageData.id,
                                                          sentDate: Date(timeIntervalSince1970: messageData.sendDate),
                                                          kind: .photo(mediaItem))
                            self.messages[index] = updatedMessage
                            self.messagesCollectionView.reloadData()
                        }
                    }
                }
            }
            self?.messageDateArray = dataArray
            self?.messagesCollectionView.reloadData()
            self?.messagesCollectionView.scrollToLastItem(animated: true)
        }

        // 測試訊息陣列
//        messages.append(Message(sender: sender2,
//                                messageId: "1",
//                                sentDate: Date(),
//                                kind: .photo(Media(url: nil,
//                                                   image: .asset(.calendar_select),
//                                                   placeholderImage: .asset(.calendar_not_select)!,
//                                                   size: CGSize(width: 250, height: 100)))))
//        messages.append(Message(sender: sender2,
//                                messageId: "2",
//                                sentDate: Date(),
//                                kind: .photo(Media(url: nil,
//                                                   image: .asset(.calendar_select),
//                                                   placeholderImage: .asset(.calendar_not_select)!,
//                                                   size: CGSize(width: 250, height: 100)))))
//        messages.append(Message(sender: sender3,
//                                messageId: "3",
//                                sentDate: Date(),
//                                kind: .photo(Media(url: nil,
//                                                   image: .asset(.calendar_select),
//                                                   placeholderImage: .asset(.calendar_not_select)!,
//                                                   size: CGSize(width: 250, height: 100)))))
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

        // messagesCollectionView.reloadData()
        navigationItem.title = "留言"
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
            createNewMessage(textContent: text, action: 0)
        }
        if !inputBarView.imageArray.isEmpty {
            for imageURL in inputBarView.imageURLArray {
                uploadPictureToFirebase(imageURL) { (url, error) in
                    if let error = error {
                        // 上傳失敗，處理錯誤
                        print("上傳失敗：\(error.localizedDescription)")
                    } else {
                        // 上傳成功，取得圖片的下載 URL
                        if let downloadURL = url {
                            createNewMessage(url: downloadURL.absoluteString, action: 1)
                        } else {
                            print("無法獲取圖片的下載 URL")
                        }
                    }
                }
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

