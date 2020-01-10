//
//  InboxViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/11.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import CCBottomRefreshControl
import PullToRefreshKit
import collection_view_layouts
import PassKit

class InboxViewController: UIViewController
, UICollectionViewDelegate
, UICollectionViewDataSource
, UITableViewDelegate
, UITableViewDataSource
, PurchaseAlertViewDelegate
, LayoutDelegate
, MessageTableViewCellDelegate {

    internal var senderId: String? = nil
    
    @IBOutlet weak var messageTabTitle: UILabel!
    @IBOutlet weak var messageTabUnderline: UILabel!
    @IBOutlet weak var matchesTabTitle: UILabel!
    @IBOutlet weak var matchesTabUnderline: UILabel!
    
    @IBOutlet weak var noView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var matchesView: UIView!
    
    @IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var matchNumTxt: UILabel!
    @IBOutlet weak var matchesCollectionView: UICollectionView!
    private var gPopupMaskBG: UIVisualEffectView?;
    private var delegateObj: AppDelegate?;
    private var purchaseAlertView: PurchaseAlertView?

    private var purchaseItems : [NSMutableDictionary] = []
    private var selectedIndex : Int = 0

    
    var currentTabIndex: Int = 0
    var messageModels : [Channel] = []
    var matchModels : [Match] = []

    private var layout: PinterestLayout!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noView.isHidden = false

        // table view settings
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        self.messageTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")

        let headerView = SwipeUpdateHeader()
        self.messageTableView.configRefreshHeader(with: headerView, container: self) { [weak self] in
            self!.loadMessageDatas()
        };
//        let bottomRefreshController = UIRefreshControl()
//        bottomRefreshController.triggerVerticalOffset = 20
//        bottomRefreshController.addTarget(self, action: #selector(refreshBottom), for: .valueChanged)
//        messageTableView.bottomRefreshControl = bottomRefreshController

        
        // collection view settings
        self.matchesCollectionView.register(UINib(nibName: "MatchesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MatchesCollectionViewCell")
        self.matchesCollectionView.dataSource = self
        self.matchesCollectionView.delegate = self
        layout = PinterestLayout()
        layout.delegate = self

        // All layouts support this configs
        layout.contentPadding = ItemsPadding(horizontal: 20, vertical: 20)
        layout.cellsPadding = ItemsPadding(horizontal: 20, vertical: 20)
        layout.columnsCount = 3
        matchesCollectionView.collectionViewLayout = layout
        matchesCollectionView.setContentOffset(CGPoint.zero, animated: false)
        
        self.matchNumTxt.text = "\(Common.likeNum ?? 0)" + Config.inbox_like_num

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

        self.loadMatchDatas()
        SVProgressHUD.show()
    }

    @objc func refreshBottom() {
//        if !updateFlag {
//            updateData()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if senderId != nil {
            messageView.isHidden = true
            matchesView.isHidden = false
        }else {
            messageView.isHidden = false
            matchesView.isHidden = true
        }
        self.loadMessageDatas()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        var handle: UInt = 0
//        handle = Common.firebaseDb.observe(.value, with: { snapshot in
//            print(snapshot)
//            if snapshot.exists() && snapshot.value as! String {
//                Common.firebaseDb.removeObserver(withHandle: handle)
//            }
//        })
    }

    private func loadMessageDatas () {
        let query: DatabaseQuery = Common.firebaseDb.child("Inbox").child(Common.me!.fbId).queryOrdered(byChild: "date")
        query.observe(.value) { (snapshot) in
            SVProgressHUD.dismiss()
            self.messageModels.removeAll()
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                let item = Channel()
                item.id = snap.key
                item.name = (snap.childSnapshot(forPath: "name").value as! String)
                item.message = (snap.childSnapshot(forPath: "msg").value as! String)
                item.timestamp = (snap.childSnapshot(forPath: "date").value as! String)
                item.status = (snap.childSnapshot(forPath: "status").value as! String)
                item.picture = (snap.childSnapshot(forPath: "pic").value as! String)
                item.badge = (snap.childSnapshot(forPath: "badge").value as! Int)

                self.messageModels.append(item)
                self.messageTableView.tableHeaderView?.isHidden = true
                self.messageTableView.switchRefreshHeader(to: .normal(.none, 0.1))
            }
            if self.messageModels.count > 0 {
                self.noView.isHidden = true
            }else {
                self.noView.isHidden = false
            }
            self.messageModels.reverse()
            self.messageTableView.reloadData()
        }
    }
    
    private func loadMatchDatas () {
        FirebaseApiManager.getMatchingUserInfo(user_id: (Common.me?.fbId)!) { (result, diff_state) in
            if result != nil {
                let user = Match.init(result!)
                switch diff_state {
                case "added":
                    if result!["state"] as! String == "matched" {
                        self.matchModels.append(user)
                    }
                    break
                case "modified":
                    for i in 0..<self.matchModels.count {
                        let item = self.matchModels[i]
                        if item.id == user.id {
                            if result!["state"] as! String == "matched" {
                                self.matchModels[i] = user
                            }else {
                                self.matchModels.remove(at: i)
                            }
                            break
                        }
                    }
                    break
                case "removed":
                    for i in 0..<self.matchModels.count {
                        let item = self.matchModels[i]
                        if item.id == user.id {
                            self.matchModels.remove(at: i)
                            break
                        }
                    }
                    break
                default:
                    break
                }
                DispatchQueue.main.async {
                    if self.matchModels.count > 0 {
                        self.noView.isHidden = true
                    }else {
                        self.noView.isHidden = false
                    }
                    self.matchesCollectionView.reloadData()
                }
            }
        }
    }
    
    
        //-------------------------------------------------------------------------------------------------------------------------
            //                                              Number of sections
            //-------------------------------------------------------------------------------------------------------------------------
            func numberOfSections(in tableView: UITableView) -> Int {
                return 1
            }
           
         //-------------------------------------------------------------------------------------------------------------------------
            //                                              Number of rows in section
            //-------------------------------------------------------------------------------------------------------------------------
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return messageModels.count
            }
            //-------------------------------------------------------------------------------------------------------------------------
            //                                              Cell for row at index path
            //-------------------------------------------------------------------------------------------------------------------------
            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath as IndexPath) as! MessageTableViewCell
                let channelData = self.messageModels[indexPath.row]
                cell.initData(messageInfo: channelData)
                cell.delegate = self
                return cell
            }
         //-------------------------------------------------------------------------------------------------------------------------
            //                                              Height for row at indexPath
            //-------------------------------------------------------------------------------------------------------------------------
            func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                return 80
            }
            //-------------------------------------------------------------------------------------------------------------------------
            //                                              Did select row at indexPath
            //-------------------------------------------------------------------------------------------------------------------------
            func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            }
            
            func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return 0.0;
            }
        //    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        //        return 0.001;
        //    }
            
            func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            }
            
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "マッチを解除") { action, index in

            self.deleteRowVal(indexPath: indexPath)
        }
        deleteAction.backgroundColor = .red

        return [deleteAction]
    }

    func deleteRowVal(indexPath: IndexPath) {
        self.unMathThisUser(otheInfo: self.messageModels[indexPath.row], ind: indexPath.row)
    }

    
    
    
        //===================================================================
        
        //==========================UICollectionView Delegate==========================
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.matchModels.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell:MatchesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchesCollectionViewCell", for: indexPath as IndexPath) as! MatchesCollectionViewCell;
            cell.initData(matchInfo: self.matchModels[indexPath.item])
            return cell;
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let other = self.matchModels[indexPath.item]
            self.gotoChatView(other_id: other.id)
        }

    // MARK: - LayoutDelegate

    func cellSize(indexPath: IndexPath) -> CGSize {
        let cellWidth = (self.matchesCollectionView.bounds.width - (4 * 20))/3
        if indexPath.item == 1 {
            return CGSize(width: cellWidth, height: 225)
        }else {
            return CGSize(width: cellWidth, height: 150)
        }
    }
    
    func selectedUserImgView(mInfo: Channel) {
        let vc = ProfileDetailViewController()
        vc.userId = mInfo.id
        self.present(vc, animated: true, completion: nil)
    }
    
    func selectedMessageItem(mInfo: Channel) {
        self.gotoChatView(other_id: mInfo.id)
    }
    

    
    private func unMathThisUser(otheInfo: Channel, ind: Int) {
        FirebaseApiManager.unMatchUser(u_id: otheInfo.id)
    }
    
    func gotoChatView(other_id: String) {
        if !Common.checkPurchaseState() && Common.me?.gender == "male" {
            showPurchaseView()
            return
        }

        FirebaseApiManager.getUserInfo(u_id: other_id) { (result) in
            if result != nil {
                DispatchQueue.main.async {
                    let vc = ChatViewController()
                    vc.toUser = result
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func messageTabClicked(_ sender: Any) {
        messageView.isHidden = false
        matchesView.isHidden = true
        currentTabIndex = 0
        messageTabTitle.textColor = Config.photo_alert
        messageTabUnderline.backgroundColor = Config.photo_alert
        matchesTabTitle.textColor = Config.text_gray
        matchesTabUnderline.backgroundColor = Config.text_gray
        if messageModels.count > 0 {
            noView.isHidden = true
        }else {
            noView.isHidden = false
        }
    }
    
    @IBAction func matchesTabClicked(_ sender: Any) {
        messageView.isHidden = true
        matchesView.isHidden = false
        currentTabIndex = 1
        messageTabTitle.textColor = Config.text_gray
        messageTabUnderline.backgroundColor = Config.text_gray
        matchesTabTitle.textColor = Config.photo_alert
        matchesTabUnderline.backgroundColor = Config.photo_alert
        if matchModels.count > 0 {
            noView.isHidden = true
        }else {
            noView.isHidden = false
        }
    }
    
    
    private func showPurchaseView() {
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

    
    
    
}



extension InboxViewController: PKPaymentAuthorizationViewControllerDelegate {
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
            }
        }
    }
}
