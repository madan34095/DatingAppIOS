//
//  UserModel.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/10/02.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class UserModel: NSObject, NSCoding {
    
    var fb_id       : String = ""
    var name        : String = ""
    var job_title     : String = ""
    var birthday     : String = ""
    var gender     : String = ""
    var about     : String = ""
    var location : String = ""

    var json            : NSDictionary = NSDictionary()

    //---------------------------------------------------------------------------------------------------------
    //                                      Init
    //---------------------------------------------------------------------------------------------------------
    override init() {
        
    }
    //---------------------------------------------------------------------------------------------------------
    //                                      Init With JSON
    //---------------------------------------------------------------------------------------------------------
    convenience init(_ json: NSDictionary){
        self.init()
        self.initWithJSON(json: json)
    }
    
    func initWithJSON(json:NSDictionary){
        self.json = json
        if let fb_id = json["user_id"]{
            userId = (val as? String) ?? ""
        }
        if let val = json["mail_address"]{
            email = (val as? String) ?? ""
        }
        if let val = json["password"]{
            password = (val as? String) ?? ""
        }
        if let val = json["prefecture_id"]{
            prefectureId = (val as? Int) ?? 0
        }
    }
    //---------------------------------------------------------------------------------------------------------
    //                                      Encode With Coder
    //---------------------------------------------------------------------------------------------------------
    func encode(with aCoder: NSCoder) {
        let newDic = self.json.mutableCopy() as! NSMutableDictionary
        newDic.setValue(self.userId, forKey: "user_id")
        newDic.setValue(self.email, forKey: "mail_address")
        newDic.setValue(self.password, forKey: "password")
        newDic.setValue(self.prefectureId, forKey: "prefecture_id")
        aCoder.encode(newDic, forKey: "json")
    }
    //---------------------------------------------------------------------------------------------------------
    //                                      Decode With Coder
    //---------------------------------------------------------------------------------------------------------
    required convenience init?(coder decoder:NSCoder) {
        self.init()
        let json = decoder.decodeObject(forKey: "json") as! NSDictionary
        self.initWithJSON(json: json)
    }
}
