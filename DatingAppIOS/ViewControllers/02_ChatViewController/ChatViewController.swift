//
//  ChatViewController.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/10/16.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import Photos
import FirebaseDatabase
import Firebase
import SVProgressHUD

class ChatViewController: JSQMessagesViewController
, UIImagePickerControllerDelegate
, UINavigationControllerDelegate
, UIGestureRecognizerDelegate {
    
    internal var currentGroupId: NSString!
    internal var toUser: User!

    private var messageData : NSMutableArray = NSMutableArray()
    private var chatData : NSMutableArray = NSMutableArray()
    private var delegateObj: AppDelegate?
    private var gPopupMaskBG: UIView?;
    private var incomingCount: Int = 0
    private var outgoingCount: Int = 0
    private var sendedImg: UIImage?
    private var imgTempArr : NSMutableArray = NSMutableArray()

    lazy var bubbleImageOutgoing: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var bubbleImageIncoming: JSQMessagesBubbleImage = self.setupIncomingBubble()
    var avatarImageBlank: JSQMessagesAvatarImage?

      override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.senderId = Common.me?.fbId as String?
        self.senderDisplayName = Common.me?.name as String?

        SVProgressHUD.show()
        self.initialize()

      }
    
    func initialize() {
        self.userImgView.layer.cornerRadius = 20
        self.userImgView.clipsToBounds = true
        if toUser.imageUrl1 != "" {
            let url = NSURL(string: toUser.imageUrl1)
            userImgView.sd_setImage(with: url as URL?) { (img, err, type, url) in
            }
        }else {
            self.userImgView.image = UIImage(named: "profile_image_placeholder")
        }
        
        self.userNameLb.text = toUser.name

        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 50, height: 50)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        JSQMessagesCollectionViewCell.registerMenuAction(#selector(actionCopy(indexPath:)))
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(actionDelete(index_path:)))

        let menuItemCopy: UIMenuItem = UIMenuItem.init(title: "コピー", action: #selector(actionCopy(indexPath:)))
        let menuItemDelete: UIMenuItem = UIMenuItem.init(title: "削除", action: #selector(actionDelete(index_path:)))
        UIMenuController.shared.menuItems = [menuItemCopy, menuItemDelete]

        self.collectionView.register(UINib(nibName: "AdminCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AdminCollectionViewCell")

        setupAvataImage()
        changeMessageWithState()
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(fromGesture:)))
         self.collectionView.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.tabBarController?.tabBar.isHidden = true
       self.collectionView.collectionViewLayout.springinessEnabled = false
}

    @objc func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
      override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      }

    func changeMessageWithState()  {
        SVProgressHUD.dismiss()
        let chatRef = Common.firebaseDb.child("chat").child(toUser.fbId + "-" + (Common.me?.fbId)!)
        chatRef.observe(.childAdded) { (snapshot) in
            self.addMessage(message: self.getChatModelFromSnapshot(snapshot: snapshot))
        }
        chatRef.observe(.childChanged) { (snapshot) in
            self.updateMessage(message: self.getChatModelFromSnapshot(snapshot: snapshot))
        }
        chatRef.observe(.childRemoved) { (snapshot) in
            self.deleteMessage(message: self.getChatModelFromSnapshot(snapshot: snapshot))
        }
    }
    
    func getChatModelFromSnapshot(snapshot: DataSnapshot) -> Chat{
        let item = Chat()
        item.id = snapshot.key
        item.receiverId = (snapshot.childSnapshot(forPath: "receiver_id").value as! String)
        item.senderId = (snapshot.childSnapshot(forPath: "sender_id").value as! String)
        item.senderName = (snapshot.childSnapshot(forPath: "sender_name").value as! String)
        item.message = (snapshot.childSnapshot(forPath: "text").value as! String)
        item.picture = (snapshot.childSnapshot(forPath: "pic_url").value as! String)
        item.type = (snapshot.childSnapshot(forPath: "type").value as! String)
        item.status = (snapshot.childSnapshot(forPath: "status").value as! String)
        item.time = (snapshot.childSnapshot(forPath: "time").value as! String)
        item.timestamp = (snapshot.childSnapshot(forPath: "timestamp").value as! String)
        return item
    }
    
    func insertMessage(message: Chat) {
        if message.senderId == Common.me?.fbId {
            outgoingCount += 1
        }else {
            incomingCount += 1
        }
//        self.automaticallyScrollsToMostRecentMessage = false
//        self.finishReceivingMessage()
//        self.automaticallyScrollsToMostRecentMessage = true
    }
    
    func addMessage(message: Chat) {
        if message.senderId == Common.me?.fbId {
            outgoingCount += 1
        }else {
            self.changeStatus()
            incomingCount += 1
        }
        self.messageData.insert(loadJSQMessage(message: message), at: 0)
        self.chatData.insert(message, at: 0)
//        self.automaticallyScrollsToMostRecentMessage = true
        self.finishReceivingMessage()
        self.collectionView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func updateMessage(message: Chat) {
        for i in 0..<self.chatData.count {
            let msg = self.chatData.object(at: i) as! Chat
            if msg.id == message.id {
                self.messageData.replaceObject(at: i, with: loadJSQMessage(message: message))
                self.chatData.replaceObject(at: i, with: message)
                self.collectionView.reloadData()
                return
            }
        }
    }
    
    func deleteMessage(message: Chat) {
        for i in 0..<self.chatData.count {
            let msg = self.chatData.object(at: i) as! Chat
            if msg.id == message.id {
                self.chatData.removeObject(at: i)
                self.messageData.removeObject(at: i)
                self.collectionView.reloadData()
            }
        }
    }
    
    func sendMessage(text: String, img_path: String) {
        
//        JSQSystemSoundPlayer
    }
    
    func loadJSQMessage(message: Chat) -> JSQMessage {
        var jsqMessage = JSQMessage(senderId: (message.senderId!), senderDisplayName: (message.senderName!), date: Date.init(timeIntervalSince1970: Common.getTimeFromString(dateStr: message.timestamp!)), text: message.message!)
        if message.type == "image" { //imgae message
            var ss = 2
            var dd = false
            if message.senderId == senderId {
                ss = 3
                dd = true
            }
            let mediaItem: PhotoMediaItem = PhotoMediaItem.init(image: UIImage(named: "no_img.png"), width: 200, height: 200, readable: dd)
            self.getMediaItemImage(image_path: message.picture!, media_item: mediaItem, state: ss)
            jsqMessage = JSQMessage(senderId: message.senderId!, senderDisplayName: message.senderName!, date: Date.init(timeIntervalSince1970: Common.getTimeFromString(dateStr: message.timestamp!)), media: mediaItem)
        }
        return jsqMessage!
    }
    
    func getMediaItemImage(image_path: String, media_item: PhotoMediaItem, state: Int) {
        let url = NSURL(string: image_path)
        media_item.status = 1
        let view = UIImageView()
        self.imgTempArr.add(view)
        view.sd_setImage(with: url as! URL) { (img, err, type, url) in
            if err == nil {
                media_item.image = img;
                media_item.status = Int32(state)
                self.collectionView.reloadData()
            }
            self.imgTempArr.remove(view)
        }
    }

    @objc func actionCopy(indexPath: IndexPath) {
        let message = messageData[indexPath.item] as! JSQMessage
        UIPasteboard.general.string = message.text
    }

    @objc func actionDelete(index_path: IndexPath) {
        let message = chatData.object(at: index_path.item) as! Chat
        let current_user_ref: String = "chat/" + Common.me!.fbId + "-" + toUser.fbId
        let chat_user_ref: String = "chat/" + toUser.fbId + "-" + Common.me!.fbId
        
        let message_user_map = [
            "receiver_id":message.receiverId,
            "sender_id":message.senderId,
            "sender_name":Common.me?.name,
            "chat_id":message.id,
            "text":"Deleted this message",
            "pic_url":"",
            "type":"delete",
            "status":"0",
            "time":"",
            "timestamp":message.timestamp
        ]

        let user_map = [
            (current_user_ref + "/" + message.id!): message_user_map,
            (chat_user_ref + "/" + message.id!): message_user_map
        ]
        
        Common.firebaseDb.updateChildValues(user_map)
    }
    
    @objc func onRefresh() {
        
    }
    
    @objc func imageTap(gestureRecognizer: UIGestureRecognizer) {
        
    }

    
      // MARK: Collection view data source (and related) methods
      //----------------------------------------------------------------------------------------------------------------------------
      //                                              Message Data at IndexPath
      //----------------------------------------------------------------------------------------------------------------------------

      override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let message = messageData[indexPath.item] as! JSQMessage
        message.isTopDateView = true

        return message
      }
    
    
    //----------------------------------------------------------------------------------------------------------------------------
    //                                              Message Bubble Image
    //----------------------------------------------------------------------------------------------------------------------------

    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = chatData[indexPath.item] as! Chat
        if message.senderId! == self.senderId {
            return bubbleImageOutgoing
        } else { // 3
            return bubbleImageIncoming
        }
    }
    
    //----------------------------------------------------------------------------------------------------------------------------
    //                                              Cell Avatar Text
    //----------------------------------------------------------------------------------------------------------------------------

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = chatData[indexPath.item] as! Chat
        if message.senderId! == self.senderId {
            return nil
        } else { // 3
            return avatarImageBlank
        }
    }
    
    //----------------------------------------------------------------------------------------------------------------------------
    //                                              Cell Top Label Text
    //----------------------------------------------------------------------------------------------------------------------------

    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = chatData[indexPath.item] as! Chat

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm:ssZZ"
        let mDate: Date = dateFormatterGet.date(from: message.timestamp!)!

        let expiredTime: Int = Common.currentTimeInMiliseconds() - Int(mDate.timeIntervalSince1970 * 1000)
        let day: Int = 60000 * 60 * 24
        if expiredTime < day {
            return NSAttributedString(string: "今日")
        }else if expiredTime < day * 2 {
            return NSAttributedString(string: "昨日")
        }else if expiredTime < day * 3 {
            return NSAttributedString(string: "一昨日")
        }else {
            return NSAttributedString(string: "\(Common.calExpairedDate(time: mDate.timeIntervalSince1970 * 1000))")
        }
    }

    //----------------------------------------------------------------------------------------------------------------------------
    //                                              Cell Bubble Top Label Text
    //----------------------------------------------------------------------------------------------------------------------------

    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
      let message = messageData[indexPath.item] as! JSQMessage
        
      switch message.senderId {
      case self.senderId:
        return nil
      default:
        guard let senderDisplayName = message.senderDisplayName else {
          assertionFailure()
          return nil
        }
        return NSAttributedString(string: senderDisplayName as String)
      }
    }

    //----------------------------------------------------------------------------------------------------------------------------
    //                                              Side Label Text
    //----------------------------------------------------------------------------------------------------------------------------

    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForCellSideLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = chatData[indexPath.item] as! Chat
        let currentDate = Date.init(timeIntervalSince1970: Common.getTimeFromString(dateStr: message.timestamp!))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        if message.senderId! == senderId {
            var stateTxt = "既読"
            if message.status == "0" {
                stateTxt = "未読"
            }
            let val = "\(stateTxt)\(dateFormatter.string(from: currentDate))"
            return NSAttributedString(string: "")
        }else {
            return NSAttributedString(string: "")
        }
    }

    //#pragma mark - UICollectionView DataSource

      override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageData.count
      }
      
      //----------------------------------------------------------------------------------------------------------------------------
      //                                              Cell View at IndexPath
      //----------------------------------------------------------------------------------------------------------------------------

      override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = chatData[indexPath.item] as! Chat
        if message.senderId! == self.senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
      }
      

      ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //                                                              Cell Height
      ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////.
    // #pragma mark - JSQMessages collection view flow layout delegate
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = chatData[indexPath.item] as! Chat
        if message.senderId! == self.senderId {
            return 0
        } else {
            if indexPath.item % 10 == 0 {
                return 25
            }
            return 0
        }
      }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = chatData[indexPath.item] as! Chat
        if message.senderId! == self.senderId {
            return 0
        } else { 
            return 20
        }
      }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                              Cell Actions
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    #pragma mark - UICollectionView Delegate
    override func collectionView(_ collectionView: UICollectionView,
    canPerformAction action: Selector,
           forItemAt indexPath: IndexPath,
           withSender sender: Any?) -> Bool {
        let message = chatData[indexPath.item] as! Chat

        if action == #selector(actionCopy(indexPath:)) {
            if message.type != "image" {
                return true
            }else {
                return false
            }
        }else if action == #selector(actionDelete(index_path:)){
            if message.senderId! != self.senderId {
                return false
            }
            return true
        }
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView,
    performAction action: Selector,
           forItemAt indexPath: IndexPath,
           withSender sender: Any?) {
        if action == #selector(actionCopy(indexPath:)) {
            self.actionCopy(indexPath: indexPath)
        }else if action == #selector(actionDelete(index_path:)){
            self.actionDelete(index_path: indexPath)
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                              Cell Tap Events
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//    #pragma mark - Responding to collection view tap events
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        let message = chatData[indexPath.item] as! Chat // 1
        //toDetailView
        let vc = ProfileDetailViewController()
        vc.userId = toUser.fbId
        self.present(vc, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let msg = messageData[indexPath.item] as! JSQMessage
        let message = chatData[indexPath.item] as! Chat // 1
        if message.type == "image" {
            let mediaItem = msg.media as! PhotoMediaItem
            let photos = [IDMPhoto(image: mediaItem.image)]
            let imgVC = IDMPhotoBrowser(photos: photos)
            self.present(imgVC!, animated: true, completion: nil)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            self.sendMessage(text: text, imgPath: nil)
            self.finishSendingMessage()
        }
    }

    override func didPressAccessoryButton(_ sender: UIButton) {
      let alert: UIAlertController = UIAlertController(title: "画像の選択",
                                                       message: "",
                                                       preferredStyle: .actionSheet);
      let registerAction: UIAlertAction = UIAlertAction(title: "写真を撮影", style: .default, handler: {
          (action: UIAlertAction!) -> Void in
          let vc = UIImagePickerController()
          vc.sourceType = .camera
          vc.allowsEditing = true
          vc.delegate = self
          self.present(vc, animated: true)
      })
      let loginAction: UIAlertAction = UIAlertAction(title: "アルバムから選択", style: .default, handler: {
          (action: UIAlertAction!) -> Void in
          let vc = UIImagePickerController()
          vc.sourceType = .photoLibrary
          vc.allowsEditing = true
          vc.delegate = self
          self.present(vc, animated: true)
      })
      let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル",
                                                      style: .cancel,
                                                      handler: nil)
      alert.addAction(registerAction)
      alert.addAction(loginAction)
      alert.addAction(cancelAction)
      present(alert, animated: true, completion: nil)
    }

    override func bottomMenuItemClicked(_ buttonMenu: MediaButtonMenuView!, imgData: UIImage!) {
        let img = imgData.jpegData(compressionQuality: 0.3)
        SVProgressHUD.show()
        let refKey = Common.firebaseDb.child("Users").childByAutoId().key
        let storageRef = Common.firebaseStorage.reference()
        let imagesRef = storageRef.child(Common.me!.fbId + "/" + refKey! + ".jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        imagesRef.putData(img!, metadata: metaData) { (metadata, error) in
            SVProgressHUD.dismiss()
                if error != nil {
                    print(error.debugDescription)
                } else {
                    imagesRef.downloadURL(completion: { (url, error) in
                        let imgPath = (url?.absoluteString as String?)!
                        self.sendMessage(text: "Photo message", imgPath: imgPath)
                    })
                }
            }
    }
    
    override func didPressBack(_ button: UIButton!) {
//        if Common.currentChatListner != nil {
//            Common.currentChatListner.remove()
//        }
//        delegateObj = nil
//        if chatAlertView != nil {
//            closeAlertView(view: chatAlertView!)
//        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didBlockBack(_ button: UIButton!) {
        let alert: UIAlertController = UIAlertController(title: nil,
                                                         message: nil,
                                                         preferredStyle: .actionSheet);
        let unMatchAction: UIAlertAction = UIAlertAction(title: "マッチを解除", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            
            SVProgressHUD.show()
            FirebaseApiManager.unMatchUser(u_id: self.toUser.fbId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                SVProgressHUD.dismiss()
                                          self.navigationController?.popViewController(animated: true)
                
            })
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル",
                                                        style: .cancel,
                                                        handler: nil)
        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(unMatchAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = Config.photo_alert
        
        present(alert, animated: true, completion: nil)
    }
    
    override func didUserImgButton(_ button: UIButton!) {
        let vc = ProfileDetailViewController()
        vc.userId = toUser.fbId
        self.present(vc, animated: true, completion: nil)
    }
      
      private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: Config.photo_alert )
      }

      private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor(hexString: "F5F5F5"))
      }
    
    private func setupAvataImage() {
        if toUser!.imageUrl1 != "" {
            let url = NSURL(string: toUser!.imageUrl1)
            let view = UIImageView()
            view.sd_setImage(with: url as! URL, placeholderImage: UIImage(named: "placeholder"), options: .avoidAutoSetImage) { (img, err, type, url) in
                if err == nil {
                    self.avatarImageBlank = JSQMessagesAvatarImageFactory.avatarImage(with: img, diameter: UInt(5.0))
                }else {
                    self.avatarImageBlank = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profile_image_placeholder"), diameter: UInt(5.0))
                }
            }
        }else {
            self.avatarImageBlank = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profile_image_placeholder"), diameter: UInt(5.0))
        }
    }
    
    func Call_api_to_done_chat() {
        let params = [
            "fb_id" : Common.me?.fbId,
            "effected_id" : toUser.fbId
        ]
        
        let urlString = Config.BASEURL + Config.FIRST_CHAT

        ApiManager.postData(urlString, param: params as [String : Any]) { (isSuccess, response) in
            SVProgressHUD.dismiss()
            if isSuccess {
                let status = response!["code"] as! String
                    
                if status == "200" {
                }else {
                }
            }else {
                
            }
        }

    }
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        let imgData = image.jpegData(compressionQuality: 0.3)
        SVProgressHUD.show()
        let refKey = Common.firebaseDb.child("Users").childByAutoId().key
        let storageRef = Common.firebaseStorage.reference()
        let imagesRef = storageRef.child(Common.me!.fbId + "/" + refKey! + ".jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        imagesRef.putData(imgData!, metadata: metaData) { (metadata, error) in
            SVProgressHUD.dismiss()
                if error != nil {
                    print(error.debugDescription)
                } else {
                    imagesRef.downloadURL(completion: { (url, error) in
                        let imgPath = (url?.absoluteString as String?)!
                        self.sendMessage(text: "Photo message", imgPath: imgPath)
                    })
                }
            }
    }
    
    func sendMessage(text: String, imgPath: String?) {
        if chatData.count == 0 {
            FirebaseApiManager.matchUser(user: toUser, state: "chat")
        }
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm:ssZZ"
        let date: Date = Date()
        let formattedDate = dateFormatterGet.string(from: date)
        
        let chat_user_ref: String = "chat/" + toUser.fbId + "-" + Common.me!.fbId
        let current_user_ref: String = "chat/" + Common.me!.fbId + "-" + toUser.fbId;


        let newRef = Common.firebaseDb.child("chat").child(toUser.fbId + "-" + (Common.me?.fbId)!)
        let message_user_map = [
            "receiver_id":toUser.fbId,
            "sender_id":Common.me?.fbId,
            "sender_name":Common.me?.name,
            "chat_id":newRef.childByAutoId().key,
            "text":text,
            "pic_url":imgPath == nil ? "" : imgPath,
            "status":"0",
            "time":"",
            "type":imgPath == nil ? "text" : "image",
            "timestamp":formattedDate
        ]

        let user_map = [
            current_user_ref + "/" + newRef.childByAutoId().key!: message_user_map,
            chat_user_ref + "/" + newRef.childByAutoId().key!: message_user_map
        ]
        
        Common.firebaseDb.updateChildValues(user_map) { (err, snapshot) in
            if err == nil {
                let inbox_sender_ref: String = "Inbox/" + Common.me!.fbId + "/" + self.toUser.fbId
                Common.firebaseDb.child(inbox_sender_ref)
                        .observeSingleEvent(of: .value) { (snapshot) in
                            let receivermap = [
                                "rid":self.toUser.fbId,
                                "name":self.toUser.name,
                                "msg":text,
                                "pic":self.toUser.imageUrl1,
                                "status":"1",
                                "badge":0,
                                "timestamp":-1*date.timeIntervalSince1970 * 1000,
                                "date":formattedDate
                                ] as [String : Any]
                            if snapshot.exists() {
                                Common.firebaseDb.child(inbox_sender_ref).updateChildValues(receivermap)
                            }else {
                                Common.firebaseDb.child(inbox_sender_ref).setValue(receivermap)
                            }
                    }
                let inbox_receiver_ref: String = "Inbox/" + self.toUser.fbId + "/" + Common.me!.fbId
                Common.firebaseDb.child(inbox_receiver_ref)
                    .observeSingleEvent(of: .value) { (snapshot) in
                        if snapshot.exists() {
                            let badgeNum = snapshot.childSnapshot(forPath: "badge").value as! Int
                            let sendermap = [
                                "rid":Common.me?.fbId,
                                "name":Common.me?.name,
                                "msg":text,
                                "pic":Common.me?.imageUrl1,
                                "status":"0",
                                "badge":badgeNum + 1,
                                "timestamp":-1*date.timeIntervalSince1970 * 1000,
                                "date":formattedDate
                                ] as [String : Any]
                            Common.firebaseDb.child(inbox_receiver_ref).updateChildValues(sendermap)
                        }else {
                            let sendermap = [
                                "rid":Common.me?.fbId,
                                "name":Common.me?.name,
                                "msg":text,
                                "pic":Common.me?.imageUrl1,
                                "status":"0",
                                "badge":1,
                                "timestamp":-1*date.timeIntervalSince1970 * 1000,
                                "date":formattedDate
                                ] as [String : Any]
                            Common.firebaseDb.child(inbox_receiver_ref).setValue(sendermap)
                        }
                }
                self.finishSendingMessage()
                PushNotificationSender.sendPushNotification(to: self.toUser.token, title: Config.MESSAGETITLE, body: Common.me!.name + Config.MESSAGEBODY, content_type: "message", content_id: self.toUser.fbId)
            }
        }
    }
    
    func changeStatus() {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm:ssZZ"
        let date: Date = Date()
        let formattedDate = dateFormatterGet.string(from: date)

//        let query1 = Common.firebaseDb.child("chat").child(toUser.fbId + "-" + Common.me!.fbId).queryOrdered(byChild: "status").queryEqual(toValue: "0")
//        let query2 = Common.firebaseDb.child("chat").child(Common.me!.fbId + "-" + toUser.fbId).queryOrdered(byChild: "status").queryEqual(toValue: "0")
//
//        query1.observeSingleEvent(of: .childChanged) { (snapshot) in
//            for snap in snapshot.children.allObjects as! [DataSnapshot] {
//                if snap.childSnapshot(forPath: "sender_id").value as! String != Common.me!.fbId {
//                    let key = snap.key
//                    let path = "chat/" + snapshot.key + "/" + key
//                    let result = [
//                        "status" : "1",
//                        "time" : formattedDate
//                    ]
//                    Common.firebaseDb.child(path).updateChildValues(result)
//                }
//            }
//        }
//
//        query2.observeSingleEvent(of: .childChanged) { (snapshot) in
//            for snap in snapshot.children.allObjects as! [DataSnapshot] {
//                if snap.childSnapshot(forPath: "sender_id").value as! String != Common.me!.fbId {
//                    let key = snap.key
//                    let path = "chat/" + snapshot.key + "/" + key
//                    let result = [
//                        "status" : "1",
//                        "time" : formattedDate
//                    ]
//                    Common.firebaseDb.child(path).updateChildValues(result)
//                }
//            }
//        }
        
        let inbox_receiver_ref: String = "Inbox/" + Common.me!.fbId + "/" + self.toUser.fbId
        Common.firebaseDb.child(inbox_receiver_ref)
            .observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    let sendermap = [
                        "rid":snapshot.childSnapshot(forPath: "rid").value,
                        "name":snapshot.childSnapshot(forPath: "name").value,
                        "msg":snapshot.childSnapshot(forPath: "msg").value,
                        "pic":snapshot.childSnapshot(forPath: "pic").value,
                        "status":"1",
                        "badge":0,
                        "timestamp":snapshot.childSnapshot(forPath: "timestamp").value,
                        "date":snapshot.childSnapshot(forPath: "date").value
                        ] as [String : Any]
                    Common.firebaseDb.child(inbox_receiver_ref).updateChildValues(sendermap)
                }
        }
    }
}
