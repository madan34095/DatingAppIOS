//
//  NoticeModel.swift
//  SampleApplicatinX
//
//  Created by ADV on 2019/11/15.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class NoticeModel: NSObject, NSCoding {
    
    var noticeId       : NSString = ""
    var title        : NSString = ""
    var desc     : NSString = ""
    var photoUrl      : NSString = ""
    var createdDate     : Double = 0.0
    
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
        if let val = json["notice_id"]{
            noticeId = (val as? NSString) ?? ""
        }
        if let val = json["title"]{
            title = (val as? NSString) ?? ""
        }
        if let val = json["desc"]{
            desc = (val as? NSString) ?? ""
        }
        if let val = json["photo_url"]{
            photoUrl = (val as? NSString) ?? ""
        }
        if let val = json["created_date"]{
            createdDate = (val as? Double) ?? 0.0
        }
    }
    //---------------------------------------------------------------------------------------------------------
    //                                      Encode With Coder
    //---------------------------------------------------------------------------------------------------------
    func encode(with aCoder: NSCoder) {
        let newDic = self.json.mutableCopy() as! NSMutableDictionary
        newDic.setValue(self.noticeId, forKey: "notice_id")
        newDic.setValue(self.desc, forKey: "title")
        newDic.setValue(self.photoUrl, forKey: "photo_url")
        newDic.setValue(self.createdDate, forKey: "created_date")
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
    
    func getDictionaryData() -> NSMutableDictionary  {
        let newDic = self.json.mutableCopy() as! NSMutableDictionary
        newDic.setValue(self.noticeId, forKey: "notice_id")
        newDic.setValue(self.desc, forKey: "title")
        newDic.setValue(self.photoUrl, forKey: "photo_url")
        newDic.setValue(self.createdDate, forKey: "created_date")
        return newDic
    }
}
