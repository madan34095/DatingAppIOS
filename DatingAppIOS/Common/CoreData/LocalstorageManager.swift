//
//  LocalstorageManager.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/10/02.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class LocalstorageManager: NSObject {

    static func setLoginInfo(info:User?){
        let key = "user_info"
        do {
            if info != nil {
                let encorded = try NSKeyedArchiver.archivedData(withRootObject: info as Any, requiringSecureCoding: false)
                UserDefaults.standard.set(encorded, forKey: key)
            }else {
                UserDefaults.standard.set(info, forKey: key)
            }
        } catch  {
        }
    }
    static func getLoginInfo() -> User? {
        let key = "user_info"
        let val = UserDefaults.standard.data(forKey: key)
        if val != nil {
            do {
                let decoded = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(val!) as! User
                return decoded
            } catch  {
                return nil
            }
        }else {
            return nil
        }
    }
//    static func setMyLocation(code:String){
//        let key = "my_location"
//        UserDefaults.standard.set(code, forKey: key)
//    }
//    static func getMyLocation() -> String {
//        let key = "my_location"
//        if let val:String = UserDefaults.standard.string(forKey: key) as String? {
//            return val;
//        }else{
//            return ""
//        }
//    }
    static func setMaxDistance(code:String){
        let key = "max_distance"
        UserDefaults.standard.set(code, forKey: key)
    }
    static func getMaxDistance() -> String {
        let key = "max_distance"
        if let val:String = UserDefaults.standard.string(forKey: key) as String? {
            return val;
        }else{
            return "100"
        }
    }
    static func setMinDistance(code:String){
        let key = "min_distance"
        UserDefaults.standard.set(code, forKey: key)
    }
    static func getMinDistance() -> String {
        let key = "min_distance"
        if let val:String = UserDefaults.standard.string(forKey: key) as String? {
            return val;
        }else{
            return "10"
        }
    }
    static func setMaxAge(code:String){
        let key = "max_age"
        UserDefaults.standard.set(code, forKey: key)
    }
    static func getMaxAge() -> String {
        let key = "max_age"
        if let val:String = UserDefaults.standard.string(forKey: key) as String? {
            return val;
        }else{
            return "80"
        }
    }
    static func setMinAge(code:String){
        let key = "min_age"
        UserDefaults.standard.set(code, forKey: key)
    }
    static func getMinAge() -> String {
        let key = "min_age"
        if let val:String = UserDefaults.standard.string(forKey: key) as String? {
            return val;
        }else{
            return "15"
        }
    }
    static func setPassportState(code:String){
        let key = "passport_state"
        UserDefaults.standard.set(code, forKey: key)
    }
    static func getPassportState() -> String {
        let key = "passport_state"
        if let val:String = UserDefaults.standard.string(forKey: key) as String? {
            return val;
        }else{
            return ""
        }
    }
    static func setLikeNotification(code:Bool){
        let key = "like_notification"
        UserDefaults.standard.set(code, forKey: key)
    }
    static func getLikeNotification() -> Bool {
        let key = "like_notification"
        if let val:Bool = UserDefaults.standard.bool(forKey: key) as Bool? {
            return val;
        }else{
            return true
        }
    }
    static func setMessageNotification(code:Bool){
        let key = "message_notification"
        UserDefaults.standard.set(code, forKey: key)
    }
    static func getMessageNotification() -> Bool {
        let key = "message_notification"
        if let val:Bool = UserDefaults.standard.bool(forKey: key) as Bool? {
            return val;
        }else{
            return true
        }
    }
    static func setMatchingNotification(code:Bool){
        let key = "matching_notification"
        UserDefaults.standard.set(code, forKey: key)
    }
    static func getMatchingNotification() -> Bool {
        let key = "matching_notification"
        if let val:Bool = UserDefaults.standard.bool(forKey: key) as Bool? {
            return val;
        }else{
            return true
        }
    }
    static func setViewMode(code:String){
        let key = "view_mode"
        UserDefaults.standard.set(code, forKey: key)
    }
    static func getViewMode() -> String {
        let key = "view_mode"
        if let val:String = UserDefaults.standard.string(forKey: key) as String? {
            return val;
        }else{
            return "grid"
        }
    }
    static func setPurchasedDate(code:String){
        let key = "purchased_date"
        UserDefaults.standard.set(code, forKey: key)
    }
    static func getPurchasedDate() -> String {
        let key = "purchased_date"
        if let val:String = UserDefaults.standard.string(forKey: key) as String? {
            return val;
        }else{
            return "0"
        }
    }
    static func setPurchasedLimit(code:String){
        let key = "purchased_limit"
        UserDefaults.standard.set(code, forKey: key)
    }
    static func getPurchasedLimit() -> String {
        let key = "purchased_limit"
        if let val:String = UserDefaults.standard.string(forKey: key) as String? {
            return val;
        }else{
            return "1"
        }
    }
    static func setLikedLimit(code:String, key: String){
        UserDefaults.standard.set(code, forKey: key)
    }
    static func getLikedLimit(key: String) -> String {
        if let val:String = UserDefaults.standard.string(forKey: key) as String? {
            return val;
        }else{
            return "0"
        }
    }
}
