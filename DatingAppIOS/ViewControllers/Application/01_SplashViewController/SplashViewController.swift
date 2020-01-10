//
//  SplashViewController.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/09/28.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation
import Firebase

class SplashViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var loadingView: UIView!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let user = LocalstorageManager.getLoginInfo()
        Common.me = user
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let delegateObj = AppDelegate.instance();
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if user != nil {
                FirebaseApiManager.getPurchaseInfo { (result) in
                    if result != nil {
                        let limit: Int = result!["limit"] as! Int
                        LocalstorageManager.setPurchasedDate(code: "\(limit ?? 0)")
                    }
                }

                self.permitionLocation()
            }else {
                let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "loginView") as UIViewController
                vc.modalPresentationStyle = .fullScreen
                delegateObj.window?.rootViewController!.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
                    //test
                    Common.me?.latitude = 33.73804
                    Common.me?.longitude = 73.084488
        //            let currentLocation: CLLocation  = locationManager.location!;
        //            Common.me?.latitude = currentLocation.coordinate.latitude
        //            Common.me?.longitude = currentLocation.coordinate.longitude
                    Auth.auth().signIn(withEmail: Config.FIREUSEREMAIL, password: Config.FIREPASSWORD) { [weak self] fireUser, error in
                        if error == nil {
                            let pushManager = PushNotificationManager(userID: (fireUser?.user.uid)!)
                            pushManager.registerForPushNotifications()
                            DispatchQueue.main.async
                            {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let delegateObj = AppDelegate.instance();
                                let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "mainView") as UIViewController
                                vc.modalPresentationStyle = .fullScreen
                                delegateObj.window?.rootViewController!.present(vc, animated: true, completion: nil)
                            }
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
