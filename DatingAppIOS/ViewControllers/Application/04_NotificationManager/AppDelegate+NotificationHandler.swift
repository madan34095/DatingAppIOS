//
//  AppDelegate+NotificationHandler.swift
//  Manga
//
//  Created by juc com on 3/9/17.
//  Copyright © 2017 juc com. All rights reserved.
//
import UIKit

let APNSPermissionDidChange = "APNSPermissionDidChange"
let APNSPermissionDenyKey = "APNSPermissionDenyKey"
let APNSPermissionTriedKey = "APNSPermissionTriedKey"

extension AppDelegate {
    
    func requestNotificationPermission() {
        if #available(iOS 10.0, *) {
            center.requestAuthorization(options: [ .alert, .badge, .sound]) { granted, error in
                guard error == nil else {
                    return
                }
                
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        else {
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    func handle(payload: NotificationPayload, state: UIApplication.State? = nil) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        setTransition(payload: payload)
    }
    
    func open(payload: NotificationPayload) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        setTransition(payload: payload, waitSecond: 0.5)
    }
    
    private func setTransition(payload: NotificationPayload, waitSecond: Double = 2.5) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + waitSecond) {
             guard let top = UIApplication.topViewController() else {
                 return
             }
             
             // your function here
             switch payload.direction {
             case .Chat(let senderId):
                  let vc = ChatViewController()
                  FirebaseApiManager.getUserInfo(u_id: senderId) { (user) in
                    if user != nil {
                        vc.toUser = user!
                        if ((top as? ChatViewController) == nil) {
                            if let top = top as? UINavigationController {
                                top.pushViewController(vc, animated: true)
                            }
                            else {
                                top.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                  }
             case .Like(let senderId):
                let vc = HomeViewController()
                vc.senderId = senderId
                 if ((top as? HomeViewController) == nil) {
                     if let top = top as? UINavigationController {
                        top.popToRootViewController(animated: true)
                     }
                     else {
                         top.navigationController?.popToRootViewController(animated: true)
                     }
                 }
             case .Match(let senderId):
                let vc = InboxViewController()
                vc.senderId = senderId
                 if ((top as? InboxViewController) == nil) {
                     if let top = top as? UINavigationController {
                         top.pushViewController(vc, animated: true)
                     }
                     else {
                         top.navigationController?.pushViewController(vc, animated: true)
                     }
                 }
             case .Nowhere:
                 break
             }
        }
    }
}
