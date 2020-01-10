//
//  BlockAlertView.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/10/03.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

@objc protocol PurchaseAlertViewDelegate {
    func selectedPurchase(p_ind: Int)
    func closeView()
}

class PurchaseAlertView: UIView {

    @IBOutlet var rootView: UIView!
    
    @IBOutlet weak var inappIntroImg: UIImageView!
    @IBOutlet weak var inappIntroLb: UILabel!
    @IBOutlet weak var inappItemMonthLb11: UILabel!
    @IBOutlet weak var inappItemMonthLb12: UILabel!
    @IBOutlet weak var inappItemMonthLb13: UILabel!
    @IBOutlet weak var inappItemMonthLb21: UILabel!
    @IBOutlet weak var inappItemMonthLb22: UILabel!
    @IBOutlet weak var inappItemMonthLb23: UILabel!
    @IBOutlet weak var inappItemMonthLb31: UILabel!
    @IBOutlet weak var inappItemMonthLb32: UILabel!
    @IBOutlet weak var inappItemMonthLb33: UILabel!
    @IBOutlet weak var inappItemView1: UIView!
    @IBOutlet weak var inappItemView2: UIView!
    @IBOutlet weak var inappItemView3: UIView!
    @IBOutlet weak var inappIntroIndicate: UIImageView!
    
    internal weak var delegate : PurchaseAlertViewDelegate? = nil;
    
    private var currentItemIndex: Int = 0
    private var selectedIntroIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        Bundle.main.loadNibNamed("PurchaseAlertView", owner: self, options: nil)
        var rect: CGRect = frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
        self.rootView.frame = rect;
        self.addSubview(self.rootView);
        self.layer.cornerRadius = 10;
        self.clipsToBounds = true
        
        self.currentItemIndex = 0
        self.inappItemView1.layer.borderWidth = 3
        self.inappItemView1.backgroundColor = Config.white
        self.inappItemView1.layer.borderColor = Config.photo_alert?.cgColor
        self.inappItemMonthLb11.textColor = Config.photo_alert
        self.inappItemMonthLb12.textColor = Config.photo_alert
        self.inappItemMonthLb13.textColor = Config.photo_alert
        self.inappItemView2.layer.borderWidth = 0
        self.inappItemView2.backgroundColor = Config.GRAY
        self.inappItemMonthLb21.textColor = Config.BLACK
        self.inappItemMonthLb22.textColor = Config.BLACK
        self.inappItemMonthLb23.textColor = Config.BLACK
        self.inappItemView3.layer.borderWidth = 0
        self.inappItemView3.backgroundColor = Config.GRAY
        self.inappItemMonthLb31.textColor = Config.BLACK
        self.inappItemMonthLb32.textColor = Config.BLACK
        self.inappItemMonthLb33.textColor = Config.BLACK
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func inappIntroItemClicked(_ sender: Any) {
        if selectedIntroIndex == 0 {
            selectedIntroIndex = 1
            self.inappIntroLb.text = Config.inapp_intro_2
            self.inappIntroImg.image = UIImage(named: "inapp_intro_item2")
            self.inappIntroIndicate.image = UIImage(named: "inapp_intro_indi2")
        }else if selectedIntroIndex == 1 {
            selectedIntroIndex = 2
            self.inappIntroLb.text = Config.inapp_intro_3
            self.inappIntroImg.image = UIImage(named: "inapp_intro_item3")
            self.inappIntroIndicate.image = UIImage(named: "inapp_intro_indi3")
        }else {
            selectedIntroIndex = 0
            self.inappIntroLb.text = Config.inapp_intro_1
            self.inappIntroImg.image = UIImage(named: "inapp_intro_item1")
            self.inappIntroIndicate.image = UIImage(named: "inapp_intro_indi_1")
        }
    }
    
    @IBAction func inappItem1Clicked(_ sender: Any) {
        self.currentItemIndex = 0
        self.inappItemView1.layer.borderWidth = 3
        self.inappItemView1.backgroundColor = Config.white
        self.inappItemView1.layer.borderColor = Config.photo_alert?.cgColor
        self.inappItemMonthLb11.textColor = Config.photo_alert
        self.inappItemMonthLb12.textColor = Config.photo_alert
        self.inappItemMonthLb13.textColor = Config.photo_alert
        self.inappItemView2.layer.borderWidth = 0
        self.inappItemView2.backgroundColor = Config.GRAY
        self.inappItemMonthLb21.textColor = Config.BLACK
        self.inappItemMonthLb22.textColor = Config.BLACK
        self.inappItemMonthLb23.textColor = Config.BLACK
        self.inappItemView3.layer.borderWidth = 0
        self.inappItemView3.backgroundColor = Config.GRAY
        self.inappItemMonthLb31.textColor = Config.BLACK
        self.inappItemMonthLb32.textColor = Config.BLACK
        self.inappItemMonthLb33.textColor = Config.BLACK
    }
    
    @IBAction func inappItem2Clicked(_ sender: Any) {
        self.currentItemIndex = 1
        self.inappItemView1.layer.borderWidth = 0
        self.inappItemView1.backgroundColor = Config.GRAY
        self.inappItemMonthLb11.textColor = Config.BLACK
        self.inappItemMonthLb12.textColor = Config.BLACK
        self.inappItemMonthLb13.textColor = Config.BLACK
        self.inappItemView2.layer.borderWidth = 3
        self.inappItemView2.layer.borderColor = Config.photo_alert?.cgColor
        self.inappItemView2.backgroundColor = Config.white
        self.inappItemMonthLb21.textColor = Config.photo_alert
        self.inappItemMonthLb22.textColor = Config.photo_alert
        self.inappItemMonthLb23.textColor = Config.photo_alert
        self.inappItemView3.layer.borderWidth = 0
        self.inappItemView3.backgroundColor = Config.GRAY
        self.inappItemMonthLb31.textColor = Config.BLACK
        self.inappItemMonthLb32.textColor = Config.BLACK
        self.inappItemMonthLb33.textColor = Config.BLACK
    }
    
    @IBAction func inappItem3Clicked(_ sender: Any) {
        self.currentItemIndex = 2
        self.inappItemView1.layer.borderWidth = 0
        self.inappItemView1.backgroundColor = Config.GRAY
        self.inappItemMonthLb11.textColor = Config.BLACK
        self.inappItemMonthLb12.textColor = Config.BLACK
        self.inappItemMonthLb13.textColor = Config.BLACK
        self.inappItemView2.layer.borderWidth = 0
        self.inappItemView2.backgroundColor = Config.GRAY
        self.inappItemMonthLb21.textColor = Config.BLACK
        self.inappItemMonthLb22.textColor = Config.BLACK
        self.inappItemMonthLb23.textColor = Config.BLACK
        self.inappItemView3.backgroundColor = Config.white
        self.inappItemView3.layer.borderWidth = 3
        self.inappItemView3.layer.borderColor = Config.photo_alert?.cgColor
        self.inappItemMonthLb31.textColor = Config.photo_alert
        self.inappItemMonthLb32.textColor = Config.photo_alert
        self.inappItemMonthLb33.textColor = Config.photo_alert
    }
    
    @IBAction func purchaseBtnClicked(_ sender: Any) {
        delegate?.selectedPurchase(p_ind: currentItemIndex)
    }
    
    @IBAction func closeBtnClicked(_ sender: Any) {
        delegate?.closeView()
    }
    
    
    
    
}
