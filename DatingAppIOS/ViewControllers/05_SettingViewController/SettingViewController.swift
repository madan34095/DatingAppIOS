//
//  SettingViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/12.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import PassKit
import SVProgressHUD
import PassKit

class SettingViewController: UIViewController
, UITableViewDelegate
, UITableViewDataSource
, PurchaseAlertViewDelegate
{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var profileCell: UITableViewCell!
    
    @IBOutlet var showCell: UITableViewCell!
    @IBOutlet var filterCell: UITableViewCell!
    @IBOutlet var notificationCell: UITableViewCell!
    @IBOutlet var privacyCell: UITableViewCell!
    @IBOutlet var termsCell: UITableViewCell!
    @IBOutlet var restoreCell: UITableViewCell!
    @IBOutlet var reportCell: UITableViewCell!
    @IBOutlet var passportCell: UITableViewCell!
    @IBOutlet var otherCell: UITableViewCell!
    
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userNameLb: UILabel!
    @IBOutlet weak var purchaseStateLb: UILabel!
    
    private var gPopupMaskBG: UIVisualEffectView?;
    private var delegateObj: AppDelegate?;
    private var purchaseAlertView: PurchaseAlertView?

    private var purchaseItems : [NSMutableDictionary] = []
    private var selectedIndex : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        userImgView.layer.cornerRadius = 50
        userImgView.clipsToBounds = true
        if Common.me?.imageUrl1 != "" {
            let url = NSURL(string: (Common.me?.imageUrl1)!)
            userImgView.sd_setImage(with: url as URL?) { (img, err, type, url) in
            }
        }else {
            self.userImgView.image = UIImage(named: "profile_image_placeholder")
        }
        self.userNameLb.text = (Common.me?.name)! + ", \(Common.me?.age ?? 0)"
        
        if Common.checkPurchaseState() {
            purchaseStateLb.text = Config.purchase_state
        }else {
            purchaseStateLb.text = Config.unpurchase_state
        }

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
            return 10
        }
        //-------------------------------------------------------------------------------------------------------------------------
        //                                              Cell for row at index path
        //-------------------------------------------------------------------------------------------------------------------------
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = profileCell
            switch indexPath.row {
            case 1:
                return showCell
            case 2:
                return filterCell
            case 3:
                return notificationCell
            case 4:
                return privacyCell
            case 5:
                return termsCell
            case 6:
                return restoreCell
            case 7:
                return reportCell
            case 8:
                return passportCell
            case 9:
                return otherCell
            default:
                return cell!
            }
        }
     //-------------------------------------------------------------------------------------------------------------------------
        //                                              Height for row at indexPath
        //-------------------------------------------------------------------------------------------------------------------------
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if indexPath.row == 0 {
                return 300
            }else if indexPath.row == 9{
                return 200
            }else {
                return 50
            }
        }


    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func userImgBtnClicked(_ sender: Any) {
        let vc = ProfileEditViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func purchaseBtnClicked(_ sender: Any) {
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
    @IBAction func showItemBtnClicked(_ sender: Any) {
        let vc = ShowSettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func filterBtnClicked(_ sender: Any) {
        let vc = FillerSettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func notificationBtnClicked(_ sender: Any) {
        let vc = NotificationSettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func privacyBtnClicked(_ sender: Any) {
        let vc = PrivacyViewController()
        vc.startMod = "0"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func termsBtnClicked(_ sender: Any) {
        let vc = TermsViewController()
        vc.startMod = "0"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func restoreBtnClicked(_ sender: Any) {
    }
    @IBAction func reportBtnClicked(_ sender: Any) {
        let vc = ReportViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func passportBtnClicked(_ sender: Any) {
        let vc = PassportViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func twitterShareBtnClicked(_ sender: Any) {
        let tweetText = "your text"
        let tweetUrl = "http://myservice.com/"

        let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(tweetUrl)"

        // encode a space to %20 for example
        let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        // cast to an url
        let url = URL(string: escapedShareString)

        // open in safari
        UIApplication.shared.openURL(url!)
        
    }
    @IBAction func deleteAccountBtnClicked(_ sender: Any) {
        SVProgressHUD.show()
        FirebaseApiManager.deleteMyAccount()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            SVProgressHUD.dismiss()
            LocalstorageManager.setLoginInfo(info: nil)
            UIApplication.shared.windows[0].rootViewController = UIStoryboard(
            name: "Main",
            bundle: nil
            ).instantiateInitialViewController()
        })
    }
    
    func selectedPurchase(p_ind: Int) {
        let today: Int = Common.currentTimeInMiliseconds()
            let item: NSMutableDictionary = self.purchaseItems[self.selectedIndex]
//            let limit: Int = item["limit"] as! Int
            let expaire = today + 3600 * 24 * 1000 * 30 * 30
            LocalstorageManager.setPurchasedDate(code: "\(expaire ?? 0)")
            
            FirebaseApiManager.savePurchaseInfo(item: item, limit: expaire, token: "damy") { (result) in
                if result {
                    self.purchaseStateLb.text = Config.purchase_state
                    self.tableView.reloadData()
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


extension SettingViewController: PKPaymentAuthorizationViewControllerDelegate {
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
                self.purchaseStateLb.text = Config.purchase_state
                self.tableView.reloadData()
            }
        }
    }
}
