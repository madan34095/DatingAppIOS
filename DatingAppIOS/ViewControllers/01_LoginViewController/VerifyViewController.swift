//
//  VerifyViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/11/29.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import OTPTextField
import Firebase
import CoreLocation
import SVProgressHUD

class VerifyViewController: UIViewController, CLLocationManagerDelegate {

    internal var verificationID: String!
    internal var phoneNumber: String!
    
    private var isClickable: Bool = false
    @IBOutlet weak var codeTxt: OTPTextField!
    @IBOutlet weak var nextBtnImg: UIImageView!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

        codeTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        codeTxt.font = codeTxt.font?.withSize(30)
        codeTxt.textColor = Config.text_code
        codeTxt.becomeFirstResponder()
        
        addDoneButtonOnKeyboard()
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        let originTxt: String = textField.text!
        if originTxt.count == 6 {
            isClickable = true
            nextBtnImg.image = UIImage(named: "btn_next")
        }else {
            isClickable = false
            nextBtnImg.image = UIImage(named: "btn_next_0")
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

        self.codeTxt.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        self.codeTxt.resignFirstResponder()
    }

    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resendBtnClicked(_ sender: Any) {
        codeTxt.text = ""
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if error == nil {
                guard let verificationID = verificationID else { return }
                self.verificationID = verificationID
                
            }
        }
    }
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        if isClickable {
            SVProgressHUD.show()
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: codeTxt.text!)
            Auth.auth().signIn(with: credential) { (result, error) in
                SVProgressHUD.dismiss()
                if error == nil  {
                    try? Auth.auth().signOut()
                    self.getUserInfo()
                    self.codeTxt.endEditing(true)
                }
            }
        }
    }
    
    private func getUserInfo() {
        let uId = self.phoneNumber.replacingOccurrences(of: " ", with: "").substring(from: 1)
        FirebaseApiManager.getUserInfo(u_id: uId) { (result) in
            if result != nil {
                Common.me = result!
                LocalstorageManager.setLoginInfo(info: result)
                DispatchQueue.main.async {
                    self.permitionLocation()
                }
            }else {
                let user = User.init()
                user.fbId = self.phoneNumber.replacingOccurrences(of: " ", with: "").substring(from: 1)
                Common.me = user

                let vc = GenderViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }


    private func permitionLocation() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                showPermissionAlert()
                return
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                break
            }
        } else {
            locationManager.startUpdatingLocation()
        }
        FirebaseApiManager.getPurchaseInfo { (result) in
            if result != nil {
                let limit: Int = result!["limit"] as! Int
                LocalstorageManager.setPurchasedDate(code: "\(limit ?? 0)")
            }
        }


                                //test
                                Common.me?.latitude = 33.73804
                                Common.me?.longitude = 73.084488
        //                        let currentLocation: CLLocation  = locationManager.location!;
        //                        Common.me?.latitude = currentLocation.coordinate.latitude
        //                        Common.me?.longitude = currentLocation.coordinate.longitude
                    let addInfo: NSMutableDictionary = NSMutableDictionary()
                    addInfo.addEntries(from: ["latitude" : Common.me?.latitude])
                    addInfo.addEntries(from: ["longitude" : Common.me?.longitude])
                    addInfo.addEntries(from: ["state" : "1"])
                    addInfo.addEntries(from: ["type" : "iphone"])
                    addInfo.addEntries(from: ["token" : Common.deviceToken])
                    addInfo.addEntries(from: ["created_at" : Common.currentTimeInMiliseconds()])
                    FirebaseApiManager.updateUser(u_id: Common.me!.fbId, docData: addInfo) { (result) in
                        if result {
                            LocalstorageManager.setLikeNotification(code: true)
                            LocalstorageManager.setMessageNotification(code: true)
                            LocalstorageManager.setMatchingNotification(code: true)
                            Auth.auth().signIn(withEmail: Config.FIREUSEREMAIL, password: Config.FIREPASSWORD) { [weak self] fireUser, error in
                                if error == nil {
                                    let pushManager = PushNotificationManager(userID: (fireUser?.user.uid)!)
                                    pushManager.registerForPushNotifications()
                                    DispatchQueue.main.async {
                                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainView")
                                        vc.modalPresentationStyle = .fullScreen
                                        UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
                                    }
                                }
                            }
                        }else {
                            
                        }
                    }
    }
    
    func showPermissionAlert(){
        let alertController = UIAlertController(title: "位置情報許可", message: "位置情報を許可しますか？", preferredStyle: UIAlertController.Style.alert)

        let okAction = UIAlertAction(title: Config.YES, style: .default, handler: {(cAlertAction) in
            //Redirect to Settings app
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })

        let cancelAction = UIAlertAction(title: Config.NO, style: UIAlertAction.Style.cancel)
        alertController.addAction(cancelAction)

        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        permitionLocation()
    }

}

