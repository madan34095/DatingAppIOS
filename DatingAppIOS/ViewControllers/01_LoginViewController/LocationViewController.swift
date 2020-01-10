//
//  LocationViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/11/29.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

        // Do any additional setup after loading the view.
    }

    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        permitionLocation()
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
                                        DispatchQueue.main.async {
                                            let vc = IntroViewController()
                                            self?.navigationController?.pushViewController(vc, animated: true)
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
