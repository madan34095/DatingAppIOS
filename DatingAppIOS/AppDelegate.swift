//
//  AppDelegate.swift
//  SampleApplicatinX
//
//  Created by ADV on 11/14/19.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import Fabric
import Crashlytics
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate  {

    var window: UIWindow?

    var notificationInfo: [AnyHashable : Any]?

    @available(iOS 10.0, *)
    var center: UNUserNotificationCenter {
        return .current()
    }

    static func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate;
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Only allow portrait (standard behaviour)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(Config.BASE)
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setDefaultMaskType(.black)
        return .portrait;
    }

    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKind(of: UITabBarController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKind(of: UINavigationController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(Config.BACK!)
        SVProgressHUD.setForegroundColor(UIColor.black)
        SVProgressHUD.setDefaultMaskType(.black)
        // Override point for customization after application launch.
        
        
        FirebaseApp.configure()
        
        center.delegate = self
        // Override point for customization after application launch.
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable : Any] {
            self.notificationInfo = userInfo
        }


        return true
    }
    
    /// Remote Push
    //MARK:- USER NOTIFICATION DELEGATE

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        if notification.request.identifier == "rig"{
            completionHandler( [.alert,.sound,.badge])
        }else{
            completionHandler([.alert, .badge, .sound])
        }

    }

    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        //Handle the notification
        completionHandler(
            [UNNotificationPresentationOptions.alert,
             UNNotificationPresentationOptions.sound,
             UNNotificationPresentationOptions.badge])
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        Messaging.messaging().apnsToken = deviceToken
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)

    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo
        let type :String = userInfo["content_type"] as! String
        let id :String = userInfo["sender_id"] as! String
        let payload = NotificationPayload(userInfo: ["content_type":type, "sender_id":id])
        // TODO: payloadを解析してデータに応じて処理を書きます。
        open(payload: payload)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {

        switch application.applicationState {
        case .active:
            let content = UNMutableNotificationContent()
            if let title = userInfo["title"]
            {
                content.title = title as! String
            }
            if let title = userInfo["text"]
            {
                content.body = title as! String
            }
            content.userInfo = userInfo
            content.sound = UNNotificationSound.default

            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.5, repeats: false)
            let request = UNNotificationRequest(identifier:"rig", content: content, trigger: trigger)

            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().add(request) { (error) in
                if let getError = error {
                    print(getError.localizedDescription)
                }
            }
        case .inactive:
            break
        case .background:
            break
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("i am not available in simulator \(error)")
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")

    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

}
