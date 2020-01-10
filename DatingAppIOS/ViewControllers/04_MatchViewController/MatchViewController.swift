//
//  MatchViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/09.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import PassKit

class MatchViewController: UIViewController
, PurchaseAlertViewDelegate
{

    internal var otherUserInfo: User? = nil
    
    @IBOutlet weak var myImgView: UIImageView!
    @IBOutlet weak var otherImgView: UIImageView!
    private var gPopupMaskBG: UIVisualEffectView?;
    private var delegateObj: AppDelegate?;
    private var purchaseAlertView: PurchaseAlertView?

    private var purchaseItems : [NSMutableDictionary] = []
    private var selectedIndex : Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        myImgView.layer.cornerRadius = 50
        myImgView.clipsToBounds = true
        if Common.me!.imageUrl1 != "" {
            let url = NSURL(string: Common.me!.imageUrl1)
            myImgView.sd_setImage(with: url as URL?) { (img, err, type, url) in
            }
        }else {
            self.myImgView.image = UIImage(named: "profile_image_placeholder")
        }
        
        otherImgView.layer.cornerRadius = 50
        otherImgView.clipsToBounds = true
        if otherUserInfo!.imageUrl1 != "" {
            let url = NSURL(string: otherUserInfo!.imageUrl1)
            otherImgView.sd_setImage(with: url as URL?) { (img, err, type, url) in
            }
        }else {
            self.otherImgView.image = UIImage(named: "profile_image_placeholder")
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

    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendMessageBtnClicked(_ sender: Any) {
        if !Common.checkPurchaseState() && Common.me?.gender == "male" {
            showPurchaseView()
            return
        }
        
        let vc = ChatViewController()
        vc.toUser = otherUserInfo
        self.navigationController?.pushViewController(vc, animated: true)
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


extension MatchViewController: PKPaymentAuthorizationViewControllerDelegate {
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
                let vc = ChatViewController()
                vc.toUser = self.otherUserInfo
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
