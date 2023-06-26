//
//  ChatGPTViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/9.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import ChatGPTKit
import JGProgressHUD

class ChatGPTViewController: MessagesViewController {
    let hud = JGProgressHUD(style: .dark)
    let chattyGPT = ChatGPTKit(apiKey: "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")
    var history = [
        Message(role: .system, content: "你是一個料理的專家，並且會用繁體中文回答")
    ]
    var firstTime = true
    var sender: Sender?
    var sender2 = Sender(senderId: "123", displayName: "小助手")
    var messages: [MessageForm] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.messagesCollectionView.addGestureRecognizer(tapGesture)

        hud.textLabel.text = "處理中"
        hud.addGestureRecognizer(tapGesture)
        tabBarController?.tabBar.isHidden = true
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        sender = Sender(senderId: currentUserID, displayName: "用戶")
        sender!.senderId = currentUserID
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messageInputBar.sendButton.setTitle("送出", for: .normal  )
        messagesCollectionView.messagesDisplayDelegate = self
        
        navigationItem.title = "智能小助手"
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

}
extension ChatGPTViewController: MessagesDataSource {
    // MARK: 選擇目前用戶
    var currentSender: MessageKit.SenderType {
        return sender!
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
       
       return 20
     }
     
     func messageTopLabelAttributedText(
       for message: MessageType,
       at indexPath: IndexPath) -> NSAttributedString? {
       
       return NSAttributedString(
         string: message.sender.displayName,
         attributes: [.font: UIFont.systemFont(ofSize: 12)])
     }
}

extension ChatGPTViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
}
extension ChatGPTViewController: MessagesDisplayDelegate {
    func inputBar(_: InputBarAccessoryView, textViewTextDidChangeTo _: String) {
        
    }
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
            // 根據消息設定頭像
            if let myMessage = message as? MessageForm, myMessage.sender.senderId == self.sender?.senderId {
                // 設定自定義的頭像
                // avatarView.image = ...
                avatarView.set(avatar: Avatar(image: UIImage.asset(.user)))
                
            } else {
                // 設定預設的頭像
                avatarView.set(avatar: Avatar(image: UIImage.asset(.ai)))
            }
        }

}

extension ChatGPTViewController: InputBarAccessoryViewDelegate {
    // 當用戶點擊發送按鈕時調用
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = MessageForm(sender: sender!,
                              messageId: "1",
                              sentDate: Date(),
                              kind: .text(text))
        
        inputBar.inputTextView.text = ""
        self.messages.append(message)
        
        if firstTime {
            hud.show(in: self.view)
            let newMessage = Message(role: .system, content: text)
            history.append(newMessage)
            performChatCompletions(history) { [weak self] answer in
                let aiMessage = MessageForm(sender: self!.sender2,
                                      messageId: "1",
                                      sentDate: Date(),
                                      kind: .text(answer))
                self?.messages.append(aiMessage)
                DispatchQueue.main.async {
                    self?.hud.dismiss()
                    self?.messagesCollectionView.reloadData()
                }
            }
            firstTime = false
        } else {
            hud.show(in: self.view)
            let newMessage = Message(role: .system, content: text)
            performChatCompletions([newMessage]) { [weak self] answer in
                let aiMessage = MessageForm(sender: self!.sender2,
                                      messageId: "1",
                                      sentDate: Date(),
                                      kind: .text(answer))
                self?.messages.append(aiMessage)
                DispatchQueue.main.async {
                    self?.hud.dismiss()
                    self?.messagesCollectionView.reloadData()
                }
            }
        }
        messagesCollectionView.reloadData()
        // sendChatGPTRequest(prompt: "你好", apiKey: "BDLinOrsWJ0528")
    }

    func performChatCompletions(_ dataArray: [Message], completion: @escaping (String) -> Void) {
        Task.init(priority: .medium) {
            do {
                switch try await chattyGPT.performCompletions(messages: dataArray) {
                case .success(let response):
                    let firstResponse = response.choices![0]
                    let answer = firstResponse.message.content
                    print(answer)
                    completion(answer)
                case .failure(let error):
                    print("錯誤發生" + error.message)
                }
            } catch {
                // 捕获并处理错误
                print("An error occurred: \(error)")
            }

            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }

}
