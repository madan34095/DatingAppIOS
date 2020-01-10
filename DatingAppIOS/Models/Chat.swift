//
//  Chat.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/11.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class Chat : NSObject, NSCoding {

    var id: String?
    var receiverId: String?
    var senderId: String?
    var senderName: String?
    var message: String?
    var picture: String?
    var type: String?
    var timestamp: String?
    var status: String?
    var time: String?

    var json            : NSDictionary = NSDictionary()

    override init() {
        
    }
    convenience init(_ json: NSDictionary){
        self.init()
        self.initWithJSON(json: json)
    }

    func initWithJSON(json:NSDictionary){
        self.json = json
        // Initialize our user here
        if let val = json["id"]{
            self.id = (val as? String) ?? ""
        }
        if let val = json["receiver_id"]{
            self.receiverId = (val as? String) ?? ""
        }
        if let val = json["sender_id"]{
            self.senderId = (val as? String) ?? ""
        }
        if let val = json["sender_name"]{
            self.senderName = (val as? String) ?? ""
        }
        if let val = json["text"]{
            self.message = (val as? String) ?? ""
        }
        if let val = json["pic_url"]{
            self.picture = (val as? String) ?? ""
        }
        if let val = json["type"]{
            self.type = (val as? String) ?? ""
        }
        if let val = json["timestamp"]{
            self.timestamp = (val as? String) ?? ""
        }
        if let val = json["status"]{
            self.status = (val as? String) ?? ""
        }
        if let val = json["time"]{
            self.time = (val as? String) ?? ""
        }
    }
    
    func encode(with aCoder: NSCoder) {
        let newDic = self.json.mutableCopy() as! NSMutableDictionary
        newDic.setValue(self.id, forKey: "id")
        newDic.setValue(self.receiverId, forKey: "receiver_id")
        newDic.setValue(self.senderId, forKey: "sender_id")
        newDic.setValue(self.senderName, forKey: "sender_name")
        newDic.setValue(self.message, forKey: "text")
        newDic.setValue(self.picture, forKey: "pic_url")
        newDic.setValue(self.type, forKey: "type")
        newDic.setValue(self.timestamp, forKey: "timestamp")
        newDic.setValue(self.status, forKey: "status")
        newDic.setValue(self.time, forKey: "time")
        aCoder.encode(newDic, forKey: "json")
    }
    
    required convenience init?(coder decoder:NSCoder) {
        self.init()
        let json = decoder.decodeObject(forKey: "json") as! NSDictionary
        self.initWithJSON(json: json)
    }

}
