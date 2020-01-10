//
//  ShowSettingViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/15.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class ShowSettingViewController: UIViewController {
    
    @IBOutlet weak var cardCheckImg: UIImageView!
    @IBOutlet weak var gridCheckImg: UIImageView!

    var currentViewMode:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        currentViewMode = LocalstorageManager.getViewMode()
        if currentViewMode == "grid" {
            cardCheckImg.isHidden = true
            gridCheckImg.isHidden = false
        }else {
            cardCheckImg.isHidden = false
            gridCheckImg.isHidden = true
        }
    }


    @IBAction func backBtnClicked(_ sender: Any) {
        LocalstorageManager.setViewMode(code: currentViewMode)
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func cardModeBtnClicked(_ sender: Any) {
        cardCheckImg.isHidden = false
        gridCheckImg.isHidden = true
        currentViewMode = "card"
    }
    
    @IBAction func gridModeBtnClicked(_ sender: Any) {
        cardCheckImg.isHidden = true
        gridCheckImg.isHidden = false
        currentViewMode = "grid"
    }
    
    
}
