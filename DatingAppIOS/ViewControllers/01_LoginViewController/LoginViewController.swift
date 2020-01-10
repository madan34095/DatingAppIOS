//
//  LoginViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/11/29.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import CoreLocation
import SVProgressHUD

class LoginViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var fbLoginBtnBackView: UIView!
    @IBOutlet weak var phoneLoginBtnBackView: UIView!
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

        fbLoginBtnBackView.layer.cornerRadius = 25
        fbLoginBtnBackView.clipsToBounds = true
        

        phoneLoginBtnBackView.layer.cornerRadius = 25
        phoneLoginBtnBackView.clipsToBounds = true

    }

    @IBAction func fbLoginBtnClicked(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [ .publicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                Common.showErrorAlert(vc: self, title: "FBLogin", message: "Failed!")
                print(error)
            case .cancelled:
                print("User cancelled login.")
                Common.showErrorAlert(vc: self, title: "FBLogin", message: "Failed!")
            case .success( _, _, let accessToken):
                Common.grabUserData(accessToken: accessToken.tokenString) { (result) in
                    if result != nil {
                        Common.me = result!
                        FirebaseApiManager.getUserInfo(u_id: result!.fbId) { (user) in
                            if user != nil {
                                Common.showErrorAlert(vc: self, title: "FBLogin", message: "Success!")
                                Common.me = user!
                                LocalstorageManager.setLoginInfo(info: result)
                                DispatchQueue.main.async {
                                    self.permitionLocation()
                                }
                            }else {
                                Common.showErrorAlert(vc: self, title: "FBLogin", message: "Failed!")
                                let vc = LocationViewController()
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func phoneLoginBtnClicked(_ sender: Any) {
        let vc = PhoneNumberViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func termsBtnClicked(_ sender: Any) {
//        let vc = TermsViewController()
 //       vc.startMod = "1"
  //      self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func privacyBtnClicked(_ sender: Any) {
   //     let vc = PrivacyViewController()
    //    vc.startMod = "1"
     //   self.present(vc, animated: true, completion: nil)
    }
    
        private func permitionLocation() {
            
            FirebaseApiManager.getPurchaseInfo { (result) in
                if result != nil {
                    let limit: Int = result!["limit"] as! Int
                    LocalstorageManager.setPurchasedDate(code: "\(limit ?? 0)")
                }
            }


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
                                        DispatchQueue.main.async
                                        {
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
