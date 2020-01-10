//
//  ReportViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/15.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {

    @IBOutlet weak var emailTxt: UITextView!    
    @IBOutlet weak var contentTxt: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func reportBtnClicked(_ sender: Any) {
        if emailTxt.text == "" || contentTxt.text == "" {
            
        }else {
            FirebaseApiManager.sendNotify(email: emailTxt.text, content: contentTxt.text) { (result) in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }else {
                    
                }
                
            }
        }
    }
}
