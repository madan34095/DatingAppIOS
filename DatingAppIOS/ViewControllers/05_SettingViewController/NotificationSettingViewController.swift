//
//  NotificationSettingViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/15.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class NotificationSettingViewController: UIViewController {
    
    @IBOutlet weak var likeSwitch: MySwitch!
    @IBOutlet weak var messageSwitch: MySwitch!
    @IBOutlet weak var matchingSwitch: MySwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        likeSwitch.setOn(LocalstorageManager.getLikeNotification(), animated: false)
        messageSwitch.setOn(LocalstorageManager.getMessageNotification(), animated: false)
        matchingSwitch.setOn(LocalstorageManager.getMatchingNotification(), animated: false)
    }


    @IBAction func backBtnClicked(_ sender: Any) {
        LocalstorageManager.setLikeNotification(code: likeSwitch.isOn)
        LocalstorageManager.setMessageNotification(code: messageSwitch.isOn)
        LocalstorageManager.setMatchingNotification(code: matchingSwitch.isOn)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    

}
