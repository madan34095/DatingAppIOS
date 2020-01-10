//
//  PhoneNumberViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/11/29.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import MRCountryPicker
import Firebase

class PhoneNumberViewController: UIViewController, MRCountryPickerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var phoneNumTxt: UITextField!    
    @IBOutlet weak var countryFlagImg: UIImageView!
    @IBOutlet weak var nextBtnImg: UIImageView!
    @IBOutlet weak var countryPicker: MRCountryPicker!
    @IBOutlet weak var countryPickerViewPos: NSLayoutConstraint!
    
    @IBOutlet weak var countryCodeTxt: UILabel!
    private var isClickable: Bool = false
    private var countryCode: String = "+81"
    
    private var oldTxt: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

        countryPickerViewPos.constant = 250
        countryPicker.countryPickerDelegate = self
        countryPicker.showPhoneNumbers = true
        countryPicker.setCountry("JP")
        countryPicker.setLocale("ja_JP")
        countryPicker.setCountryByName("Japan")
        
        phoneNumTxt.delegate = self
        phoneNumTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phoneNumTxt.becomeFirstResponder()
        
        addDoneButtonOnKeyboard()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        var originTxt: String = textField.text!
        
//        if originTxt.count > 13 {
//            phoneNumTxt.text = originTxt.substring(to: 13)
//            return
//        }
        if (originTxt != oldTxt) {
            originTxt = originTxt.replacingOccurrences(of: " ", with: "")
            if (originTxt.count >= 11) {
                self.isClickable = true;
                self.nextBtnImg.image = UIImage(named: "btn_next")
            }else {
                isClickable = false;
                self.nextBtnImg.image = UIImage(named: "btn_next_0")
            }
            var newTxt: String = originTxt
            if (originTxt.count > 3) {
                newTxt = originTxt.substring(to: originTxt.index(originTxt.startIndex, offsetBy: 3)) + " " +
                    originTxt.substring(from: originTxt.index(originTxt.startIndex, offsetBy: 3))
            }
            if (newTxt.count > 8) {
                newTxt = newTxt.substring(to: newTxt.index(newTxt.startIndex, offsetBy: 8)) + " " +
                    newTxt.substring(from: newTxt.index(newTxt.startIndex, offsetBy: 8))
            }
            oldTxt = newTxt
            phoneNumTxt.text = newTxt
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

        self.phoneNumTxt.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        self.phoneNumTxt.resignFirstResponder()
    }

    
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.countryCode = phoneCode
        self.countryFlagImg.image = flag
        self.countryCodeTxt.text = self.countryCode
    }
    
    func hideCountryPicker()  {
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.countryPickerViewPos.constant = 250
                    self.view.layoutIfNeeded()
                    self.phoneNumTxt.becomeFirstResponder()
                } ,
                completion: nil
            )
        }
    }
    
    func showCountryPicker()  {
        self.view.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.countryPickerViewPos.constant = 0
                    self.view.layoutIfNeeded()
                } ,
                completion: nil
            )
        }
    }

    @IBAction func countryBtnClicked(_ sender: Any) {
        phoneNumTxt.endEditing(true)
        showCountryPicker()
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        if isClickable {
            var phoneNumber: String = countryCode + phoneNumTxt.text!
            if countryCode == "+81" {
                phoneNumber = countryCode + (phoneNumTxt.text?.substring(from: 1))!
            }
            
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                if error == nil {
                    guard let verificationID = verificationID else { return }
                    let vc = VerifyViewController()
                    vc.verificationID = verificationID
                    vc.phoneNumber = phoneNumber
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.phoneNumTxt.endEditing(true)
                }
            }
        }
    }
    
    @IBAction func doneBtnClicked(_ sender: Any) {
        hideCountryPicker()
    }
    
    
    
    
}
