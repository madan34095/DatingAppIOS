//
//  FirebaseApiManager.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/10/08.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class FirebaseApiManager: NSObject {
    static func createUser(u_id: String, user_info: User, completionBlock: @escaping (_ success: Bool) -> Void) {
        SVProgressHUD.show()
        let docData = user_info.getDictionaryData()
        docData.addEntries(from: ["state": "1"])
        docData.addEntries(from: ["created_at": Common.currentTimeInMiliseconds()])
        docData.addEntries(from: ["type": "iphone"])

        Common.firestoreDb.collection("Users").document(u_id).setData(docData as! [String : Any]) { err in
            SVProgressHUD.dismiss()
            if err != nil {
                completionBlock(false)
            } else {
                completionBlock(true)
            }
        }
    }

    static func getUserInfo(u_id: String, completionBlock: @escaping (_ success: User?) -> Void) {
        SVProgressHUD.show()
        let docRef = Common.firestoreDb.collection("Users").document(u_id)

        docRef.getDocument { (document, error) in
            SVProgressHUD.dismiss()
            if let document = document, document.exists {
                let user = User.init(document.data() as! NSDictionary)
                completionBlock(user)
            } else {
                completionBlock(nil)
            }
        }
    }

    static func updateUser(u_id: String, docData: NSMutableDictionary, completionBlock: @escaping (_ success: Bool) -> Void) {
        SVProgressHUD.show()
        Common.firestoreDb.collection("Users").document(u_id).updateData(docData as! [String : Any]) { err in
            SVProgressHUD.dismiss()
            if err != nil {
                completionBlock(false)
            } else {
                completionBlock(true)
            }
        }
    }

    static func getUserNearBy(frome_age: Int, to_age: Int, from_dist: Int, to_dist: Int, completionBlock: @escaping (_ succuss: User?) -> Void) {
        Common.firestoreDb.collection("Users")
            .whereField("state", isEqualTo: "1")
            .order(by: "created_at", descending: true)
        .getDocuments { (snapshot, err) in
            if err != nil {
                completionBlock(nil)
            } else if snapshot!.isEmpty {
                completionBlock(nil)
                return
            } else {
                for document in snapshot!.documents {
                    let user_data = User.init(document.data() as NSDictionary)
                    if user_data.fbId == Common.me?.fbId {
                        continue
                    }
                    var dist = Common.calDistanceFromLocation(lat1: Common.me!.latitude, long1: Common.me!.longitude, lat2: user_data.latitude, long2: user_data.longitude)
                    if dist <= 10 {
                        dist = 10
                    }
                    if user_data.age >= frome_age && user_data.age <= to_age &&
                        dist >= from_dist && dist <= to_dist {
                        Common.firestoreDb.collection("Match").document(Common.me!.fbId).collection("me").document(user_data.fbId)
                            .getDocument { (document, error) in
                                if let document = document, document.exists {
                                } else {
                                    completionBlock(user_data)
                                }
                            }
                    }
                }
            }
        }
    }

    static func getMatchingUserInfo(user_id: String, completionBlock: @escaping (_ succuss: NSDictionary?, _ _state: String?) -> Void) {
        Common.firestoreDb.collection("Match").document(user_id).collection("other")
            .order(by: "date", descending: true)
        .addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                completionBlock(nil, nil)
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                let diffData = diff.document.data() as NSDictionary
                if (diff.type == .added) {
                    completionBlock(diffData, "added")
                }
                if (diff.type == .modified) {
                    completionBlock(diffData, "modified")
                }
                if (diff.type == .removed) {
                    completionBlock(diffData, "removed")
                }
            }
        }
    }

    static func likeUser(user: User, type: String) -> Void {
        let docRef = Common.firestoreDb.collection("Match").document(Common.me!.fbId).collection("me").document(user.fbId)

        docRef.getDocument { (document, error) in
            let map: NSMutableDictionary = NSMutableDictionary()
            map.addEntries(from: ["id" : user.fbId as Any])
            map.addEntries(from: ["name" : user.name as Any])
            map.addEntries(from: ["age" : user.age as Any])
            map.addEntries(from: ["pic" : user.imageUrl1 as Any])
            map.addEntries(from: ["state" : type])
            map.addEntries(from: ["date" : Common.currentTimeInMiliseconds() as Any])
            if let document = document, document.exists {
                docRef.updateData(map as! [AnyHashable : Any])
            } else {
                docRef.setData(map as! [String : Any])
            }
        }
        
        let docRef2 = Common.firestoreDb.collection("Match").document(user.fbId).collection("other").document(Common.me!.fbId)

        docRef2.getDocument { (document, error) in
            let map: NSMutableDictionary = NSMutableDictionary()
            map.addEntries(from: ["id" : Common.me!.fbId as Any])
            map.addEntries(from: ["name" : Common.me!.name as Any])
            map.addEntries(from: ["age" : Common.me!.age as Any])
            map.addEntries(from: ["pic" : Common.me!.imageUrl1 as Any])
            map.addEntries(from: ["state" : type])
            map.addEntries(from: ["date" : Common.currentTimeInMiliseconds() as Any])
            if let document = document, document.exists {
                docRef2.updateData(map as! [AnyHashable : Any])
            } else {
                docRef2.setData(map as! [String : Any])
            }
        }
        
        let map: NSMutableDictionary = NSMutableDictionary()
        map.addEntries(from: ["s_id" : Common.me!.fbId as Any])
        map.addEntries(from: ["s_name" : Common.me!.name as Any])
        map.addEntries(from: ["r_id" : user.fbId as Any])
        map.addEntries(from: ["r_name" : user.name as Any])
        map.addEntries(from: ["state" : type])
        map.addEntries(from: ["date" : Common.currentTimeInMiliseconds() as Any])
        let mCt = Common.firestoreDb.collection("Matches")
        let newDoc = mCt.document()
        mCt.document(newDoc.documentID).setData(map as! [String : Any])
        
        if type == "like" {
            PushNotificationSender.sendPushNotification(to: user.token, title: Config.LIKETITLE, body: Common.me!.name + Config.LIKEBODY, content_type: type, content_id: user.fbId)
        }
    }
    
    static func undoUser(user: User) -> Void {
        Common.firestoreDb.collection("Match").document(Common.me!.fbId).collection("me").document(user.fbId).delete()
        Common.firestoreDb.collection("Match").document(user.fbId).collection("other").document(Common.me!.fbId).delete()
    }

    static func matchUser(user: User, state: String) -> Void {
        let docRef = Common.firestoreDb.collection("Match").document(Common.me!.fbId).collection("me").document(user.fbId)

        docRef.getDocument { (document, error) in
            let map: NSMutableDictionary = NSMutableDictionary()
            map.addEntries(from: ["id" : user.fbId as Any])
            map.addEntries(from: ["name" : user.name as Any])
            map.addEntries(from: ["age" : user.age as Any])
            map.addEntries(from: ["pic" : user.imageUrl1 as Any])
            map.addEntries(from: ["state" : state])
            map.addEntries(from: ["date" : Common.currentTimeInMiliseconds() as Any])
            if let document = document, document.exists {
                docRef.updateData(map as! [AnyHashable : Any])
            } else {
                docRef.setData(map as! [String : Any])
            }
        }

        let docRef3 = Common.firestoreDb.collection("Match").document(Common.me!.fbId).collection("other").document(user.fbId)

        docRef3.getDocument { (document, error) in
            let map: NSMutableDictionary = NSMutableDictionary()
            map.addEntries(from: ["id" : user.fbId as Any])
            map.addEntries(from: ["name" : user.name as Any])
            map.addEntries(from: ["age" : user.age as Any])
            map.addEntries(from: ["pic" : user.imageUrl1 as Any])
            map.addEntries(from: ["state" : state])
            map.addEntries(from: ["date" : Common.currentTimeInMiliseconds() as Any])
            if let document = document, document.exists {
                docRef3.updateData(map as! [AnyHashable : Any])
            } else {
                docRef3.setData(map as! [String : Any])
            }
        }

        let docRef2 = Common.firestoreDb.collection("Match").document(user.fbId).collection("other").document(Common.me!.fbId)

        docRef2.getDocument { (document, error) in
            let map: NSMutableDictionary = NSMutableDictionary()
            map.addEntries(from: ["id" : Common.me!.fbId as Any])
            map.addEntries(from: ["name" : Common.me!.name as Any])
            map.addEntries(from: ["age" : Common.me!.age as Any])
            map.addEntries(from: ["pic" : Common.me!.imageUrl1 as Any])
            map.addEntries(from: ["state" : state])
            map.addEntries(from: ["date" : Common.currentTimeInMiliseconds() as Any])
            if let document = document, document.exists {
                docRef2.updateData(map as! [AnyHashable : Any])
            } else {
                docRef2.setData(map as! [String : Any])
            }
        }
        
        let docRef4 = Common.firestoreDb.collection("Match").document(user.fbId).collection("me").document(Common.me!.fbId)

        docRef4.getDocument { (document, error) in
            let map: NSMutableDictionary = NSMutableDictionary()
            map.addEntries(from: ["id" : Common.me!.fbId as Any])
            map.addEntries(from: ["name" : Common.me!.name as Any])
            map.addEntries(from: ["age" : Common.me!.age as Any])
            map.addEntries(from: ["pic" : Common.me!.imageUrl1 as Any])
            map.addEntries(from: ["state" : state])
            map.addEntries(from: ["date" : Common.currentTimeInMiliseconds() as Any])
            if let document = document, document.exists {
                docRef4.updateData(map as! [AnyHashable : Any])
            } else {
                docRef4.setData(map as! [String : Any])
            }
        }

        if state == "matched" {
            PushNotificationSender.sendPushNotification(to: user.token, title: Config.MATCHEDTITLE, body: Common.me!.name + Config.MATCHEDBODY, content_type: "matching", content_id: user.fbId)
        }
    }
    
    static func unMatchUser(u_id: String) -> Void {
        Common.firestoreDb.collection("Match").document(Common.me!.fbId).collection("me").document(u_id).delete()
        Common.firestoreDb.collection("Match").document(Common.me!.fbId).collection("other").document(u_id).delete()
        Common.firestoreDb.collection("Match").document(u_id).collection("me").document(Common.me!.fbId).delete()
        Common.firestoreDb.collection("Match").document(u_id).collection("other").document(Common.me!.fbId).delete()
        Common.firebaseDb.child("Inbox/" + Common.me!.fbId + "/" + u_id).removeValue()
    }
    
    static func deleteMyAccount() -> Void {
        let map: NSMutableDictionary = NSMutableDictionary()
        map.addEntries(from: ["state" : "0"])
        Common.firestoreDb.collection("Users").document(Common.me!.fbId).updateData(map as! [AnyHashable : Any])
        let myRef = Common.firestoreDb.collection("Match").document(Common.me!.fbId).collection("me")
        myRef.getDocuments { (snapshot, err) in
            if err != nil {
            } else if snapshot!.isEmpty {
            } else {
                for document in snapshot!.documents {
                    Common.firestoreDb.collection("Match").document(document.documentID).collection("other").document(Common.me!.fbId).delete();
                    myRef.document(document.documentID).delete();
                }
            }
        }
        let otherRef = Common.firestoreDb.collection("Match").document(Common.me!.fbId).collection("other")
        otherRef.getDocuments { (snapshot, err) in
            if err != nil {
            } else if snapshot!.isEmpty {
            } else {
                for document in snapshot!.documents {
                    otherRef.document(document.documentID).delete();
                }
            }
        }
        Common.firebaseDb.child("Inbox/" + Common.me!.fbId).removeValue()
    }
    
    static func getOtherInfo(key: String, completionBlock: @escaping (_ success: String?) -> Void) {
        SVProgressHUD.show()
        let docRef = Common.firestoreDb.collection("settings").document(key)

        docRef.getDocument { (document, error) in
            SVProgressHUD.dismiss()
            if let document = document, document.exists {
                completionBlock(document.data()!["value"] as! String)
            } else {
                completionBlock(nil)
            }
        }
        
    }

    static func sendPassportImg(img_path: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        SVProgressHUD.show()
        let docRef = Common.firestoreDb.collection("Passports").document(Common.me!.fbId)

        let map: NSMutableDictionary = NSMutableDictionary()
        map.addEntries(from: ["id" : Common.me!.fbId as Any])
        map.addEntries(from: ["image" : img_path as Any])
        map.addEntries(from: ["state" : "request"])
        map.addEntries(from: ["date" : Common.currentTimeInMiliseconds() as Any])
        
        docRef.setData(map as! [String : Any]){ error in
            SVProgressHUD.dismiss()
            if error == nil {
                completionBlock(true)
            }else {
                completionBlock(false)
            }
        }
    }
    
    static func sendNotify(email: String, content: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        SVProgressHUD.show()
        let docRef = Common.firestoreDb.collection("Notify")
        let newDoc = docRef.document()

        let map: NSMutableDictionary = NSMutableDictionary()
        map.addEntries(from: ["s_id" : Common.me!.fbId as Any])
        map.addEntries(from: ["email" : email as Any])
        map.addEntries(from: ["content" : content as Any])
        map.addEntries(from: ["date" : Common.currentTimeInMiliseconds() as Any])
        
        docRef.document(newDoc.documentID).setData(map as! [String : Any]){ error in
            SVProgressHUD.dismiss()
            if error == nil {
                completionBlock(true)
            }else {
                completionBlock(false)
            }
        }
    }
    
    static func reportUser(u_id: String, u_name: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        SVProgressHUD.show()
        let docRef = Common.firestoreDb.collection("Reports")
        let newDoc = docRef.document()

        let map: NSMutableDictionary = NSMutableDictionary()
        map.addEntries(from: ["s_id" : Common.me?.fbId as Any])
        map.addEntries(from: ["s_name" : Common.me?.name as Any])
        map.addEntries(from: ["r_id" : u_id as Any])
        map.addEntries(from: ["r_name" : u_name as Any])
        map.addEntries(from: ["date" : Common.currentTimeInMiliseconds() as Any])
        
        docRef.document(newDoc.documentID).setData(map as! [String : Any]){ error in
            SVProgressHUD.dismiss()
            if error == nil {
                completionBlock(true)
            }else {
                completionBlock(false)
            }
        }
    }

    static func getValidationUrl() {
        Common.firestoreDb.collection("validation").getDocuments { (result, err) in
            if err == nil {
                let doc = result?.documents[0].data() as! NSDictionary
                Common.validationUrl = doc["url"] as! NSString
                print(Common.validationUrl)
            }
        }
    }
    
    static func savePurchaseInfo(item: NSMutableDictionary, limit: Int, token: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        SVProgressHUD.show()
        let p_info: NSMutableDictionary = NSMutableDictionary()
        p_info["id"] = Common.me?.fbId
        p_info["user_name"] = Common.me?.name
        p_info["plan_name"] = item["name"]
        p_info["price"] = item["price"]
        p_info["type"] = "AppleStore"
        p_info["limit"] = limit
        p_info["date"] = Common.currentTimeInMiliseconds()
        p_info["token"] = token

        let docRef = Common.firestoreDb.collection("Purchase")
        let newDoc = docRef.document()
        let docKey = newDoc.documentID
        
        docRef.document(docKey).setData(p_info as! [String : Any]){ error in
            SVProgressHUD.dismiss()
            if error == nil {
                completionBlock(true)
            }else {
                completionBlock(false)
            }
        }
    }

    
    static func getPurchaseInfo(completionBlock: @escaping (_ success: NSDictionary?) -> Void) {
        SVProgressHUD.show()

        Common.firestoreDb.collection("Purchase")
            .whereField("id", isEqualTo: Common.me?.fbId)
            .order(by: "date", descending: true)
            .getDocuments { (snapshots, err) in
                if err == nil {
                    if snapshots!.count > 0 {
                        let document = snapshots!.documents[0]
                        completionBlock((document.data() as NSDictionary))
                    }else {
                        completionBlock(nil)
                    }
                }else {
                    completionBlock(nil)
                }
        }
    }
}
