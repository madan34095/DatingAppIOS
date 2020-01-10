//
//  Common.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/09/28.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import CommonCrypto
import Firebase
import CoreLocation
import Foundation
import FacebookCore
import FacebookLogin
import Firebase

class Common {
    
    static var me: User?;
    static var deviceToken: NSString = "";
    static var currentNavViewController: UINavigationController?
    static var firebaseDb: DatabaseReference = Database.database().reference()
    static var firestoreDb = Firestore.firestore()
    static var firebaseStorage = Storage.storage()
    static var transID: String = ""
    static var validationUrl: NSString = "https://sandbox.itunes.apple.com/verifyReceipt"
    static var likeNum: Int = 0

    static func setBorderColor(view: UIView) {
        view.layer.borderColor = Config.GRAY.cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
    }

    static func convertNumericalFormat(original: NSInteger) -> String {
        let str: NSMutableString = NSMutableString(string: "\(original)");
        if str == "" {
            return str as String;
        }
        
        if original > 999 {
            let loop: Int = str.length / 3 - 1;
            for i in 0...loop {
                if str.length - (3 * (i + 1) + i) == 0 {
                    break;
                }
                str.insert(",", at: str.length - (3 * (i + 1) + i));
            }
        }
        return str as String;
    }
    //------------------------------------------------------------------------------------------------------------------------
    //convert int to YYYYY/MM/DD HH:MM
    //------------------------------------------------------------------------------------------------------------------------
    static func convertIntToDateTimeStr(time:Int) -> String {
        let date = Date(timeIntervalSince1970: Double(time))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
    //------------------------------------------------------------------------------------------------------------------------
    //convert int to YYYYY/MM/DD
    //------------------------------------------------------------------------------------------------------------------------
    static func convertIntToDateStr(time:Int) -> String {
        let date = Date(timeIntervalSince1970: Double(time))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: date)
    }
    
    static func imageFromView(view: UIView) -> UIImage
    {
        if UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale)) {
            UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale);
        }else{
            UIGraphicsBeginImageContext(view.frame.size);
        }
        
        view.layer.render(in: UIGraphicsGetCurrentContext()!);
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return image;
    }
    
    static func getCurrentViewController(sender : UIView) ->  UIViewController{
        //let sender = UIApplication.sharedApplication().keyWindow?.subviews.last;
        var vc = sender.next;
        while vc != nil && !(vc!.isKind(of: UIViewController.self)) {
            vc = vc!.next;
        }
        return vc as! UIViewController;
    }
    
    static func showErrorAlert(vc: UIViewController, title: NSString?, message: NSString) {
        let alert: UIAlertController = UIAlertController(title: title as String?,
                                                         message: message as String,
                                                         preferredStyle: .alert);
        let cancelAction: UIAlertAction = UIAlertAction(title: Config.YES,
                                                        style: .cancel,
                                                        handler: nil)
        alert.addAction(cancelAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func dateFromInt(date_time: Int) -> NSDate
    {
        let date = NSDate(timeIntervalSince1970: Double(date_time))
        return date
    }
    
    static func getRemainTimeString(from dateTime: Int) -> String {
        guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else { return "" }
        calendar.locale = Locale(identifier: "ja_JP") as Locale
        let comp = calendar.components([ .hour, .minute], from: Date(), to: dateFromInt(date_time: dateTime) as Date, options: [])
        let hour = comp.hour
        let minute = comp.minute
        
        if hour! > 0 {
            return "\(String(describing: hour))時間"
        }
        else {
            return "\(String(describing: minute))分"
        }
    }
    
    static func getRemainDateComp(from dateTime: Int) -> NSDateComponents? {
        guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else { return nil }
        calendar.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        return calendar.components([ .hour, .minute], from: Date(), to: dateFromInt(date_time: dateTime) as Date, options: []) as NSDateComponents
    }
    
    static func calRemainTime(dateTime: Int) -> Double? {
        guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else { return nil }
        calendar.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        let comp = calendar.components([ .hour, .minute], from: Date(), to: dateFromInt(date_time: dateTime) as Date, options: [])
        
        if comp.hour! > 0 {
            return Double(comp.hour!)
        }
        else {
            return Double(comp.minute!) / 100
        }
    }
    
    static func calExpiredTime(dateTime: Int) -> NSInteger {
        var time: NSInteger = 0;
        let seconds: NSInteger = calTime(dateTime: dateTime);
        if seconds > 0 {
            return 0;
        }else
        {
            time = -NSInteger(seconds) / (60 * 60);
        }
        return time;
    }
    
    static func calTime(dateTime: Int) -> NSInteger {
        let now = NSDate();
        var seconds: NSInteger = 0;
        if dateTime != 0 {
            let publishedDate = Common.dateFromInt(date_time: dateTime);
            seconds = NSInteger(now.timeIntervalSince(publishedDate as Date));
        }
        return seconds;
    }
    
    static func calExpiredDateString(timeInterval: TimeInterval) -> Int {
        let now = NSDate();
        let newTimeStamp = now.timeIntervalSince1970 + timeInterval;
        return Int(newTimeStamp);
    }
    
    static func getTextHeight(text: String, width: CGFloat, para: NSMutableParagraphStyle, fontname: String, fontsize: CGFloat) -> CGFloat
    {
        let aStr :NSMutableAttributedString = NSMutableAttributedString(string: text);
        aStr.addAttributes([
            NSAttributedString.Key.font: UIFont(name: fontname, size: fontsize)!,
            NSAttributedString.Key.paragraphStyle: para
            ], range: NSMakeRange(0, aStr.length)
        );
        
        let rect = aStr.boundingRect(with: CGSize(width: width, height: 10000),
                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                             context: nil);
        return rect.height;
    }
    
    static func currentTimeInMiliseconds() -> Int {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    static func calExpairedTime(time: Double) -> String {
        let currentDate = Date()
        let currentTime: Int = Int(currentDate.timeIntervalSince1970 * 1000)
        let expiredTime: Int = currentTime - Int(time)
        let year: Int = 60000 * 60 * 24 * 365
        let month: Int = 60000 * 60 * 24 * 30
        let day: Int = 60000 * 60 * 24
        let hour: Int = 60000 * 60
        let minute: Int = 60000
        
        if expiredTime < minute {
            return "\(expiredTime < 0 ? 0 : expiredTime/1000)秒前"
        }else if expiredTime < hour {
            return "\(expiredTime/minute)分前"
        }else if expiredTime < day {
            return "\(expiredTime/hour)時間前"
        }else if expiredTime < month {
            return "\(expiredTime/day)日前"
        }else if expiredTime < year {
            return "\(expiredTime/month)ヶ月前"
        }else {
            return "\(expiredTime/year)年前"
        }
    }
    
    static func getTimeFromString(dateStr: String) -> Double {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd-MM-yyyy HH:mm:ssZZ"
        let date = dateFormatterGet.date(from: dateStr)
        return date!.timeIntervalSince1970
    }
    
    static func calExpairedDate(time: Double) -> String {
        let currentDate = Date(timeIntervalSince1970: time/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: currentDate)
    }

    static func MD5(_ string: String) -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)

        if let d = string.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }

        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    static func receiptValidation(url: String) {
        let SUBSCRIPTION_SECRET = "Apptest111"
        let receiptPath = Bundle.main.appStoreReceiptURL?.path
        if FileManager.default.fileExists(atPath: receiptPath!){
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                print("ERROR: " + error.localizedDescription)
            }
            //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)

            print(base64encodedReceipt!)


            let requestDictionary = ["receipt-data":base64encodedReceipt!,"password":SUBSCRIPTION_SECRET]

            guard JSONSerialization.isValidJSONObject(requestDictionary) else {  print("requestDictionary is not valid JSON");  return }
            do {
                let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
                guard let validationURL = URL(string: url) else { print("the validation url could not be created, unlikely error"); return }
                let session = URLSession(configuration: URLSessionConfiguration.default)
                var request = URLRequest(url: validationURL)
                request.httpMethod = "POST"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                let task = session.uploadTask(with: request, from: requestData) { (data, response, error) in
                    if let data = data , error == nil {
                        do {
                            let appReceiptJSON = try JSONSerialization.jsonObject(with: data)
                            print("success. here is the json representation of the app receipt: \(appReceiptJSON)")
                            // if you are using your server this will be a json representation of whatever your server provided
                        } catch let error as NSError {
                            print("json serialization failed with error: \(error)")
                        }
                    } else {
                        print("the upload task returned an error: \(error)")
                    }
                }
                task.resume()
            } catch let error as NSError {
                print("json serialization failed with error: \(error)")
            }



        }
    }
    
    static var hasSafeArea: Bool {
        guard #available(iOS 11.0, *), let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, topPadding > 24 else {
            return false
        }
        return true
    }

    static func restartApp() {
        LocalstorageManager.setLoginInfo(info: nil)
        UIApplication.shared.windows[0].rootViewController = UIStoryboard(
        name: "Main",
        bundle: nil
        ).instantiateInitialViewController()
    }
    
    static func MD5(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }

    static func calDistanceFromLocation(lat1: Double, long1: Double, lat2: Double, long2: Double) -> Int {
        //My location
        let myLocation = CLLocation(latitude: lat1, longitude: long1)

        //My buddy's location
        let myBuddysLocation = CLLocation(latitude: lat2, longitude: long2)

        //Measuring my distance to my buddy's (in km)
        let distance = myLocation.distance(from: myBuddysLocation) / 1000
        return Int(distance)
    }
    
    static func grabUserData(accessToken: String, completionBlock: @escaping (_ succuss: User?) -> Void) {
        let connection = GraphRequestConnection()
        let params = ["fields":"public_profile"]
        connection.add(GraphRequest(graphPath: "/me", parameters: params)) { httpResponse, result, error   in
            if error != nil {
                NSLog(error.debugDescription)
                completionBlock(nil)
                return
            }

            guard let response = result as? Dictionary<String, Any> else {
                return
            }

            let user = User()
            if let name = response["name"] as? String {
                user.name = name
            }

            if let id = response["id"] as? String {
                user.fbId = id
            }

            if let gender = response["gender"] as? String {
                user.gender = gender
            }

            if let gender = response["birthday"] as? String {
                user.birthday = gender
            }

            user.imageUrl1 = "https://graph.facebook.com/"+user.fbId+"/picture?width=500&width=500"
            completionBlock(user)

        }
        connection.start()
    }
    
    static func checkPurchaseState() -> Bool {
        let purchasedDate = LocalstorageManager.getPurchasedDate()
        if Int(purchasedDate)! > 0 {
            let today = currentTimeInMiliseconds()
            if Int(purchasedDate)! >= today {
                return true
            }
        }
        return false
    }
}
