//
//  SearchModel.swift
//  SampleApplicatinX
//
//  Created by ADV on 2019/11/15.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class SearchModel: NSObject, NSCoding {
    
    var searchId       : String = ""
    var title          : String = ""
    var desc1          : String = ""
    var desc2          : String = ""
    var photoUrl       : String = ""
    
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
        if let val = json["search_id"]{
            searchId = (val as? String) ?? ""
        }
        if let val = json["title"]{
            title = (val as? String) ?? ""
        }
        if let val = json["desc2"]{
            desc1 = (val as? String) ?? ""
        }
        if let val = json["desc1"]{
            desc2 = (val as? String) ?? ""
        }
        if let val = json["photo_url"]{
            photoUrl = (val as? String) ?? ""
        }
    }
    //---------------------------------------------------------------------------------------------------------
    //                                      Encode With Coder
    //---------------------------------------------------------------------------------------------------------
    func encode(with aCoder: NSCoder) {
        let newDic = self.json.mutableCopy() as! NSMutableDictionary
        newDic.setValue(self.searchId, forKey: "search_id")
        newDic.setValue(self.title, forKey: "title")
        newDic.setValue(self.desc1, forKey: "desc1")
        newDic.setValue(self.desc2, forKey: "desc2")
        newDic.setValue(self.photoUrl, forKey: "photo_url")
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
