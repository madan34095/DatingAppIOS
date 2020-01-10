//
//  Match.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/11.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class Match : NSObject, NSCoding {

    var id: String = ""
    var name: String = ""
    var picture: String = ""

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
        if let val = json["pic"]{
            self.picture = (val as? String) ?? ""
        }
    }
    
    func encode(with aCoder: NSCoder) {
        let newDic = self.json.mutableCopy() as! NSMutableDictionary
        newDic.setValue(self.id, forKey: "id")
        newDic.setValue(self.name, forKey: "name")
        newDic.setValue(self.picture, forKey: "pic")
        aCoder.encode(newDic, forKey: "json")
    }
    
    required convenience init?(coder decoder:NSCoder) {
        self.init()
        let json = decoder.decodeObject(forKey: "json") as! NSDictionary
        self.initWithJSON(json: json)
    }

    func getDictionaryData() -> NSMutableDictionary  {
        let newDic = self.json.mutableCopy() as! NSMutableDictionary
        newDic.setValue(self.id, forKey: "id")
        newDic.setValue(self.name, forKey: "name")
        newDic.setValue(self.picture, forKey: "pic")
        return newDic
    }
}
