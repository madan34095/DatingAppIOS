//
//  HomeViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/05.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import PassKit
import Firebase
import SVProgressHUD

class HomeViewController: UIViewController
, UICollectionViewDelegate
, UICollectionViewDataSource
, PurchaseAlertViewDelegate
, UserDetailViewControllerDelegate
, UICollectionViewDelegateFlowLayout {
    
    internal var senderId:String? = nil
    
    @IBOutlet weak var cardsDeckView: UIView!
    @IBOutlet weak var likeMeView: UIView!
    @IBOutlet weak var likeNumTxt: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var likeNumTabLb: UILabel!
    @IBOutlet weak var likeTabImg: UIImageView!
    
    @IBOutlet weak var inboxImg: UIImageView!
    private var gPopupMaskBG: UIVisualEffectView?;
    private var delegateObj: AppDelegate?;
    private var purchaseAlertView: PurchaseAlertView?

    private var purchaseItems : [NSMutableDictionary] = []
    private var selectedIndex : Int = 0
    
    private var swipeView: TinderSwipeView<User>!{
        didSet{
            self.swipeView.delegate = self
        }
    }
    
    var userModels : [User] = []
    var likeMeUsers : [User] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        likeNumTabLb.text = ""
        
        self.collectionView.register(UINib(nibName: "LikeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LikeCollectionViewCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        SVProgressHUD.show()
        fetchCurrentUser()
        getLikeMeUsers()
        loadMessageDatas()
        
        let item1: NSMutableDictionary = NSMutableDictionary()
        item1["name"] = "12ヶ月Point"
        item1["price"] = 3000 * 12
        item1["limit"] = 12
        purchaseItems.append(item1)
        
        let item2: NSMutableDictionary = NSMutableDictionary()
        item2["name"] = "6ヶ月Point"
        item2["price"] = 3300 * 6
        item2["limit"] = 6
        purchaseItems.append(item2)
        
        let item3: NSMutableDictionary = NSMutableDictionary()
        item3["name"] = "1ヶ月Point"
        item3["price"] = 3600
        item3["limit"] = 1
        purchaseItems.append(item3)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if senderId != nil {
            cardsDeckView.isHidden = true
            likeMeView.isHidden = false
        }else {
            cardsDeckView.isHidden = false
            likeMeView.isHidden = true
        }
        self.collectionView.reloadData()
    }
    
    private func initializeCardView() {
        let contentView: (Int, CGRect, User) -> (UIView) = { (index: Int ,frame: CGRect , userModel: User) -> (UIView) in
            let customView = CustomView(frame: frame)
            customView.user = userModel
            customView.buttonAction.addTarget(self, action: #selector(self.customViewButtonSelected), for: UIControl.Event.touchUpInside)
            return customView
        }
        DispatchQueue.main.async {
            self.swipeView = TinderSwipeView<User>(frame: self.cardsDeckView.bounds, contentView: contentView)
            self.cardsDeckView.addSubview(self.swipeView)
            self.swipeView.showTinderCards(with: self.userModels ,isDummyShow: false)
        }
    }
    
    var startFlag: Bool = false
    
    private func fetchCurrentUser() {
        SVProgressHUD.show()
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        FirebaseApiManager.getUserNearBy(frome_age: Int(LocalstorageManager.getMinAge())!,
                                         to_age: Int(LocalstorageManager.getMaxAge())!,
                                         from_dist: Int(LocalstorageManager.getMinDistance())!,
                                         to_dist: Int(LocalstorageManager.getMaxDistance())!) { (result) in
                                            if result != nil {
                                                self.userModels.append(result!)
                                                if !self.startFlag {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                                                        if self.userModels.count > 0 {
                                                            self.initializeCardView()
                                                        }
                                                    })
                                                    self.startFlag = true
                                                }
                                            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            SVProgressHUD.dismiss()
        })
    }
    
    private func getLikeMeUsers() {
        FirebaseApiManager.getMatchingUserInfo(user_id: (Common.me?.fbId)!) { (result, diff_state) in
            if result != nil {
                let user = User()
                user.fbId = (result!["id"] as! String)
                user.name = (result!["name"] as! String)
                user.age = (result!["age"] as! Int)
                user.imageUrl1 = (result!["pic"] as! String)
                
                switch diff_state {
                case "added":
                    if result!["state"] as! String == "like" {
                        self.likeMeUsers.append(user)
                    }
                    break
                case "modified":
                    for i in 0..<self.likeMeUsers.count {
                        let item = self.likeMeUsers[i]
                        if item.fbId == user.fbId {
                            if result!["state"] as! String == "like" {
                                self.likeMeUsers[i] = user
                            }else {
                                self.likeMeUsers.remove(at: i)
                            }
                            break
                        }
                    }
                    break
                case "removed":
                    for i in 0..<self.likeMeUsers.count {
                        let item = self.likeMeUsers[i]
                        if item.fbId == user.fbId {
                            self.likeMeUsers.remove(at: i)
                            break
                        }
                    }
                    break
                default:
                    break
                }
                DispatchQueue.main.async {
                    self.likeNumTxt.text = "\(self.likeMeUsers.count)" + Config.like_num
                    self.likeNumTabLb.text = "\(self.likeMeUsers.count)"
                    Common.likeNum = self.likeMeUsers.count
                    if Common.checkPurchaseState() {
                        self.likeTabImg.image = UIImage(named: "ic_like_tab")
                        self.likeNumTabLb.textColor = Config.purchased_like
                    }else {
                        self.likeTabImg.image = UIImage(named: "ic_like_tab_d")
                        self.likeNumTabLb.textColor = Config.no_purchased_like
                    }
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func loadMessageDatas () {
        let query: DatabaseQuery = Common.firebaseDb.child("Inbox").child(Common.me!.fbId).queryOrdered(byChild: "date")
        query.observe(.value) { (snapshot) in
            SVProgressHUD.dismiss()
            self.inboxImg.image = UIImage(named: "ic_chat_tab")
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                if snap.exists() {
                    let badgeNum = snap.childSnapshot(forPath: "badge").value == nil ? 0 : snap.childSnapshot(forPath: "badge").value as! Int
                    if badgeNum > 0 {
                        self.inboxImg.image = UIImage(named: "ic_chat_badge")
                        break
                    }
                }
            }
        }
    }

    //===================================================================
    
    //==========================UICollectionView Delegate==========================
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.likeMeUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var cellWidth = (collectionView.bounds.width - (3 * 20))/2
        var cellSize = CGSize(width: cellWidth, height: cellWidth * 1.3)
        let viewMode = LocalstorageManager.getViewMode()
        if viewMode != "grid" {
            cellWidth = collectionView.bounds.width - 40
            cellSize = CGSize(width: cellWidth, height: cellWidth * 0.7)
        }
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        let sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:LikeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikeCollectionViewCell", for: indexPath as IndexPath) as! LikeCollectionViewCell;
        cell.initData(userInfo: self.likeMeUsers[indexPath.item], purchased: Common.checkPurchaseState())
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !Common.checkPurchaseState() {
            showPurcahseAlertView()
        }else {
            let vc = UserDetailViewController()
            vc.userInfo = likeMeUsers[indexPath.item]
            vc.delegate = self
            vc.swipe = true
            self.present(vc, animated: true, completion: nil)
        }

    }
    
    private func showPurcahseAlertView() {
        let rect: CGRect = CGRect(x: (Config.SCREEN_WIDTH - SCALE(value: 375)) / 2, y: (Config.SCREEN_HEIGHT-SCALE(value: 550))/2, width: SCALE(value: 375), height: SCALE(value: 550));
        
        purchaseAlertView = PurchaseAlertView(frame: rect);
        purchaseAlertView?.backgroundColor = UIColor.white
        purchaseAlertView?.delegate = self
        purchaseAlertView?.clipsToBounds = true;
        delegateObj = AppDelegate.instance();
        gPopupMaskBG = UIVisualEffectView.init(frame: UIScreen.main.bounds);
        delegateObj!.window?.addSubview(gPopupMaskBG!);
        gPopupMaskBG!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6);
        delegateObj!.window?.addSubview(purchaseAlertView!);
        
        self.gPopupMaskBG?.isHidden = true;
        self.view?.isHidden = true;
        
        UIView.animate(withDuration: 0.3) { () -> Void in
            self.gPopupMaskBG?.isHidden = false;
            self.view?.isHidden = false;
        }
    }

    private func programticViewForOverlay(frame:CGRect, userModel:User) -> UIView{
    
        let containerView = UIView(frame: frame)
        
        let backGroundImageView = UIImageView(frame:containerView.bounds)
        backGroundImageView.image = UIImage(named: "profile_image_placeholder")
        if userModel.imageUrl1 != "" {
            let url = NSURL(string: userModel.imageUrl1)
            backGroundImageView.sd_setImage(with: url as URL?) { (img, err, type, url) in
            }
        }else {
            backGroundImageView.image = UIImage(named: "profile_image_placeholder")
        }
        backGroundImageView.contentMode = .scaleAspectFill
        backGroundImageView.clipsToBounds = true;
        containerView.addSubview(backGroundImageView)
        
//        let labelText = UILabel(frame:CGRect(x: 90, y: frame.size.height - 80, width: frame.size.width - 100, height: 60))
//        labelText.attributedText = self.attributeStringForModel(userModel: userModel)
//        labelText.numberOfLines = 2
//        containerView.addSubview(labelText)
        
        return containerView
    }
    
    @objc func customViewButtonSelected(button:UIButton){
        
        if let customView = button.superview(of: CustomView.self) , let userModel = customView.user{
            print("button selected for \(userModel.name)")
            
            let vc = UserDetailViewController()
            vc.delegate = self
            vc.userInfo = userModel
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    private func attributeStringForModel(userModel:User) -> NSAttributedString{
        
        let attributedText = NSMutableAttributedString(string: userModel.name, attributes: [.foregroundColor: UIColor.white,.font:UIFont.boldSystemFont(ofSize: 25)])
//        attributedText.append(NSAttributedString(string: "\nnums :\( userModel.num!) (programitically)", attributes: [.foregroundColor: UIColor.white,.font:UIFont.systemFont(ofSize: 18)]))
        return attributedText
    }
    

    @IBAction func leftSwipeAction(_ sender: Any) {
        if let swipeView = swipeView{
            swipeView.makeLeftSwipeAction()
        }
    }
    
    @IBAction func rightSwipeAction(_ sender: Any) {
        if let swipeView = swipeView{
            swipeView.makeRightSwipeAction()
        }
    }
    
    @IBAction func undoButtonPressed(_ sender: Any) {
        if let swipeView = swipeView{
            swipeView.undoCurrentTinderCard()
        }
    }
    
    @IBAction func profileTabBtnClicked(_ sender: Any) {
        let vc = SettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func searchTabBtnClicked(_ sender: Any) {
//        fetchCurrentUser()
        cardsDeckView.isHidden = false
        likeMeView.isHidden = true
    }
    
    @IBAction func likeMeTabBtnClicked(_ sender: Any) {
//        getLikeMeUsers()
        cardsDeckView.isHidden = true
        likeMeView.isHidden = false
        collectionView.reloadData()
    }
    
    @IBAction func inboxTabBtnClicked(_ sender: Any) {
        let vc = InboxViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func leftSwipeAction(currentUser: User) {
        FirebaseApiManager.likeUser(user: currentUser, type: "unlike")
    }
    
    private func rightSwipeAction(currentUser: User) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy"
        let date: Date = Date()
        let formattedDate = dateFormatterGet.string(from: date)
        var totalLikeNum: Int = Int(LocalstorageManager.getLikedLimit(key: formattedDate))!
        if Common.checkPurchaseState() {
            if totalLikeNum > 150 {
                if let swipeView = swipeView{
                    swipeView.undoCurrentTinderCard()
                }
                let alertController = UIAlertController(title: "エラー", message: "「いいね」の限界を超えました。", preferredStyle: UIAlertController.Style.alert)

                let okAction = UIAlertAction(title: Config.YES, style: .default, handler: {(cAlertAction) in
                })
                alertController.addAction(okAction)

                self.present(alertController, animated: true, completion: {
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if let swipeView = self.swipeView{
                        swipeView.undoCurrentTinderCard()
                    }
                }
                return
            }
        }else {
            if totalLikeNum > 50 {
                let alertController = UIAlertController(title: "エラー", message: "「いいね」の限界を超えました。有料会員に登録しますか？", preferredStyle: UIAlertController.Style.alert)

                let okAction = UIAlertAction(title: Config.YES, style: .default, handler: {(cAlertAction) in
                    self.showPurcahseAlertView()
                })

                let cancelAction = UIAlertAction(title: Config.NO, style: UIAlertAction.Style.cancel)
                alertController.addAction(cancelAction)

                alertController.addAction(okAction)

                self.present(alertController, animated: true, completion: {
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if let swipeView = self.swipeView{
                        swipeView.undoCurrentTinderCard()
                    }
                }
                return
            }
        }
        totalLikeNum += 1
        LocalstorageManager.setLikedLimit(code: "\(totalLikeNum ?? 0)", key: formattedDate)
        FirebaseApiManager.likeUser(user: currentUser, type: "like")
    }
    
    private func undoSwipeAction(currentUser: User) {
        FirebaseApiManager.undoUser(user: currentUser)
    }
    
    private func sendPuchNotification(receiverId: String, message: String) {
        Common.firebaseDb.child("Users").child(receiverId)
            .observe(.value) { (snapshot) in
                if snapshot.exists() {
                    let token = snapshot.childSnapshot(forPath: "token").value
                    PushNotificationSender.sendPushNotification(to: token as! String, title: message, body: "", content_type: "", content_id: "");
                }
        }
    }
    
    func selectedPurchase(p_ind: Int) {
        
          let today: Int = Common.currentTimeInMiliseconds()
                    let item: NSMutableDictionary = self.purchaseItems[self.selectedIndex]
        //            let limit: Int = item["limit"] as! Int
                    let expaire = today + 3600 * 24 * 1000 * 30 * 30
        LocalstorageManager.setPurchasedDate(code: "\(expaire )")
                    
                    FirebaseApiManager.savePurchaseInfo(item: item, limit: expaire, token: "damy") { (result) in
                        if result {
                        }
                    }
/*
        //test
        closeAlertView()
        selectedIndex = p_ind
        let item: NSMutableDictionary = self.purchaseItems[self.selectedIndex]
        let paymentItem = PKPaymentSummaryItem.init(label: item["name"] as! String, amount: NSDecimalNumber(value: item["price"] as! Int))
        
        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            let request = PKPaymentRequest()
            request.currencyCode = "JPY" // 1
            request.countryCode = "JP" // 2
            request.merchantIdentifier = "merchant.nsg.datingapp.ios" // 3
            request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
            request.supportedNetworks = paymentNetworks // 5
            request.paymentSummaryItems = [paymentItem] // 6
            
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
                return
            }
                paymentVC.delegate = self
                self.present(paymentVC, animated: true, completion: nil)
            
        } else {
        }
 */
    }
    
    func closeView() {
        closeAlertView()
    }
    
    func closeAlertView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.purchaseAlertView!.isHidden = true;
            self.gPopupMaskBG?.isHidden = true;
        }, completion: { Void in
            self.purchaseAlertView?.removeFromSuperview();
            self.gPopupMaskBG?.removeFromSuperview();
            self.gPopupMaskBG = nil;
        });
    }

    func unlikeAction(userInfo: User) {
        if let swipeView = swipeView{
            swipeView.makeLeftSwipeAction()
        }
    }
    
    func likeAction(userInfo: User) {
        if let swipeView = swipeView{
            swipeView.makeRightSwipeAction()
            
        }
    }
    
    func matchUnLikeAction(userInfo: User) {
        leftSwipeAction(currentUser: userInfo)
    }
    
    func matchAction(userInfo: User) {
        FirebaseApiManager.matchUser(user: userInfo, state: "matched")
        let vc = MatchViewController()
        vc.otherUserInfo = userInfo
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension HomeViewController : TinderSwipeViewDelegate{
    
    func dummyAnimationDone() {
        print("Watch out shake action")
    }
    
    func didSelectCard(model: Any) {
        print("Selected card")
    }
    
    func fallbackCard(model: Any) {
        let userModel = model as! User
    }
    
    func cardGoesLeft(model: Any) {
        let userModel = model as! User
        self.leftSwipeAction(currentUser: userModel)
    }
    
    func cardGoesRight(model : Any) {
        let userModel = model as! User
        self.rightSwipeAction(currentUser: userModel)
   }
    
    func undoCardsDone(model: Any) {
        let userModel = model as! User
        self.undoSwipeAction(currentUser: userModel)
    }
    
    func endOfCardsReached() {
    }
    
    func currentCardStatus(card object: Any, distance: CGFloat) {
    }
}

extension UIView {
    
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview.map { $0.superview(of: type)! }
    }
    
    func subview<T>(of type: T.Type) -> T? {
        return subviews.compactMap { $0 as? T ?? $0.subview(of: type) }.first
    }
}

extension HomeViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {

        dismiss(animated: true, completion: nil)

    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        let today: Int = Common.currentTimeInMiliseconds()
        let item: NSMutableDictionary = self.purchaseItems[self.selectedIndex]
        let limit: Int = item["limit"] as! Int
        let expaire = today + 3600 * 24 * 1000 * limit * 30
        LocalstorageManager.setPurchasedDate(code: "\(expaire ?? 0)")
        
        FirebaseApiManager.savePurchaseInfo(item: item, limit: expaire, token: payment.token.description) { (result) in
            if result {
                self.likeTabImg.image = UIImage(named: "ic_like_tab")
                self.likeNumTabLb.textColor = Config.purchased_like
                self.collectionView.reloadData()
            }
        }
    }
}
