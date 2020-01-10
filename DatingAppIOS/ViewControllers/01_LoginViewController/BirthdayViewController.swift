//
//  BirthdayViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/11/29.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import PinCodeTextField

class BirthdayViewController: UIViewController, PinCodeTextFieldDelegate {

    
    
    @IBOutlet weak var yearTxt: PinCodeTextField!
    @IBOutlet weak var monthTxt: PinCodeTextField!
    @IBOutlet weak var dayTxt: PinCodeTextField!
    @IBOutlet weak var nextImg: UIImageView!
    
    private var isClickable: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

        yearTxt.delegate = self
        monthTxt.delegate = self
        dayTxt.delegate = self
        
        yearTxt.keyboardType = .numberPad
        monthTxt.keyboardType = .numberPad
        dayTxt.keyboardType = .numberPad
        
        yearTxt.becomeFirstResponder();

        addDoneButtonOnKeyboard()
    }

    func textFieldDidEndEditing(_ textField: PinCodeTextField) {
        if yearTxt.text?.count == 4 {
            monthTxt.becomeFirstResponder()
        }
        if monthTxt.text?.count == 2 {
            dayTxt.becomeFirstResponder()
        }
        checkValue()
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.yearTxt.inputAccessoryView = doneToolbar
        self.monthTxt.inputAccessoryView = doneToolbar
        self.dayTxt.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        self.yearTxt.resignFirstResponder()
        self.monthTxt.resignFirstResponder()
        self.dayTxt.resignFirstResponder()
    }


    private func checkValue() {
        if yearTxt.text?.count == 4 && monthTxt.text?.count == 2 && dayTxt.text?.count == 2 {
            isClickable = true
            nextImg.image = UIImage(named: "btn_next")
        }else {
            isClickable = false
            nextImg.image = UIImage(named: "btn_next_0")
        }
    }

    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        if isClickable {
            let year: Int = Int(yearTxt!.text!)!
            if year < 1900 || year > 2020 {
                let alert: UIAlertController = UIAlertController(title: Config.input_err_title,
                                                                 message: Config.input_err_msg as String,
                                                                 preferredStyle: .alert);
                let okAction: UIAlertAction = UIAlertAction(title: Config.YES,
                                                                style: .default,
                                                                handler: {
                                                                    (action: UIAlertAction!) -> Void in
                                                                    self.yearTxt.text = ""
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let month: Int = Int(monthTxt!.text!)!
            if month == 0 || month > 12 {
                let alert: UIAlertController = UIAlertController(title: Config.input_err_title,
                                                                 message: Config.input_err_msg as String,
                                                                 preferredStyle: .alert);
                let okAction: UIAlertAction = UIAlertAction(title: Config.YES,
                                                                style: .default,
                                                                handler: {
                                                                    (action: UIAlertAction!) -> Void in
                                                                    self.monthTxt.text = ""
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let day: Int = Int(dayTxt!.text!)!
            if day == 0 || day > 31 {
                let alert: UIAlertController = UIAlertController(title: Config.input_err_title,
                                                                 message: Config.input_err_msg as String,
                                                                 preferredStyle: .alert);
                let okAction: UIAlertAction = UIAlertAction(title: Config.YES,
                                                                style: .default,
                                                                handler: {
                                                                    (action: UIAlertAction!) -> Void in
                                                                    self.dayTxt.text = ""
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            Common.me?.birthday = monthTxt!.text! + "/" + dayTxt!.text! + "/" + yearTxt!.text!

            let vc = PhotoViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
