//
//  Channel.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/11.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class Channel : NSObject, NSCoding {

    var id: String = ""
    var name: String = ""
    var message: String = ""
    var picture: String = ""
    var type: String = ""
    var timestamp: String = ""
    var status: String = ""
    var badge: Int = 0

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
        if let val = json["name"]{
            self.name = (val as? String) ?? ""
        }
        if let val = json["msg"]{
            self.message = (val as? String) ?? ""
        }
        if let val = json["pic"]{
            self.picture = (val as? String) ?? ""
        }
        if let val = json["type"]{
            self.type = (val as? String) ?? ""
        }
        if let val = json["date"]{
            self.timestamp = (val as? String) ?? ""
        }
        if let val = json["status"]{
            self.status = (val as? String) ?? ""
        }
        if let val = json["badge"]{
            self.badge = (val as? Int) ?? 0
        }
    }
    
    func encode(with aCoder: NSCoder) {
        let newDic = self.json.mutableCopy() as! NSMutableDictionary
        newDic.setValue(self.id, forKey: "id")
        newDic.setValue(self.name, forKey: "name")
        newDic.setValue(self.message, forKey: "msg")
        newDic.setValue(self.picture, forKey: "pic")
        newDic.setValue(self.type, forKey: "type")
        newDic.setValue(self.timestamp, forKey: "date")
        newDic.setValue(self.status, forKey: "status")
        newDic.setValue(self.badge, forKey: "badge")
        aCoder.encode(newDic, forKey: "json")
    }
    
    required convenience init?(coder decoder:NSCoder) {
        self.init()
        let json = decoder.decodeObject(forKey: "json") as! NSDictionary
        self.initWithJSON(json: json)
    }

}
