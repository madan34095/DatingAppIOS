//
//  PrivacyViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/15.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {
    
    internal var startMod: String?

    
    @IBOutlet weak var contentTxt: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FirebaseApiManager.getOtherInfo(key: "privacy") { (result) in
            if result != nil {
                self.contentTxt.text = result
            }
        }
    }


    @IBAction func backBtnClicked(_ sender: Any) {
        if startMod == "1" {
            self.dismiss(animated: true, completion: nil)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
