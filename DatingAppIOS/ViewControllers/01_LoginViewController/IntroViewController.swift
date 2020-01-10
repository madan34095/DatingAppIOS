//
//  IntroViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/11/29.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import SVProgressHUD

class IntroViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var introTxt: UITextView!
    
    @IBOutlet weak var numLb: UILabel!
    
    private let isClickable: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        introTxt.delegate = self
        introTxt.becomeFirstResponder()

        addDoneButtonOnKeyboard()
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = Config.MAXCHARACTER
        let currentString: NSString = textView.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: text) as NSString
        self.numLb.text = "\(newString.length ?? 0)/500"
        return newString.length <= maxLength-1
    }
    

    func textViewDidEndEditing(_ textView: UITextView) {
    }

    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.introTxt.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        self.introTxt.resignFirstResponder()
    }


    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        Common.me?.about = self.introTxt.text
        introTxt.resignFirstResponder()
        signup()
    }
    
    private func signup() {
        FirebaseApiManager.createUser(u_id: Common.me!.fbId, user_info: Common.me!) { (result) in
            if result {
                LocalstorageManager.setLoginInfo(info: Common.me)
                LocalstorageManager.setLikeNotification(code: true)
                LocalstorageManager.setMessageNotification(code: true)
                LocalstorageManager.setMatchingNotification(code: true)
                FirebaseApiManager.getPurchaseInfo { (result) in
                    if result != nil {
                        let limit: Int = result!["limit"] as! Int
                        LocalstorageManager.setPurchasedDate(code: "\(limit ?? 0)")
                    }
                }

                DispatchQueue.main.async
                {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainView")
                    vc.modalPresentationStyle = .fullScreen
                    UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
                }
            }
        }
    }

}
