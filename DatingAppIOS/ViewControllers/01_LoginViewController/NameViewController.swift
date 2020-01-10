//
//  NameViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/11/29.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class NameViewController: UIViewController {

    @IBOutlet weak var nextImg: UIImageView!
    @IBOutlet weak var nameTxt: UITextField!
    
    private var isClickable: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

        nameTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nameTxt.becomeFirstResponder()
        
        addDoneButtonOnKeyboard()
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text!.count > 10 {
            nameTxt.text = textField.text!.substring(to: 10)
            return
        }
        if textField.text!.count > 0 {
            isClickable = true
            nextImg.image = UIImage(named: "btn_next")
        }else {
            isClickable = false
            nextImg.image = UIImage(named: "btn_next_0")
        }
    }

    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.nameTxt.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        self.nameTxt.resignFirstResponder()
    }

    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        if isClickable {
            self.nameTxt.resignFirstResponder()
            Common.me?.name = self.nameTxt.text!
            let vc = BirthdayViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
