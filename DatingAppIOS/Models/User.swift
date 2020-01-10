//
//  User.swift
//  Tinder
//
//  Created by Bekzod Rakhmatov on 26/01/2019.
//  Copyright © 2019 BekzodRakhmatov. All rights reserved.
//

import UIKit

class User : NSObject, NSCoding {

    var fbId: String = ""
    var name: String = ""
    var gender: String = ""
    var token: String = ""
    var age: Int = 15
    var birthday: String = ""
    var jobTitle: String = ""
    var imageUrl1: String = ""
    var imageUrl2: String = ""
    var imageUrl3: String = ""
    var imageUrl4: String = ""
    var imageUrl5: String = ""
    var imageUrl6: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var about: String = ""

    var minSeekingAge: Int?
    var maxSeekingAge: Int?

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
        if let val = json["fb_id"]{
            self.fbId = (val as? String) ?? ""
        }
        if let val = json["name"]{
            self.name = (val as? String) ?? ""
        }
        if let val = json["gender"]{
            self.gender = (val as? String) ?? ""
        }
        if let val = json["job_title"]{
            self.jobTitle = (val as? String) ?? ""
        }
        if let val = json["token"]{
            self.token = (val as? String) ?? ""
        }
        if let val = json["birthday"]{
            self.birthday = (val as? String) ?? ""
        }
        if let val = json["age"]{
            self.age = (val as? Int) ?? 15
        }
        if let val = json["image1"]{
            self.imageUrl1 = (val as? String) ?? ""
        }
        if let val = json["image2"]{
            self.imageUrl2 = (val as? String) ?? ""
        }
        if let val = json["image3"]{
            self.imageUrl3 = (val as? String) ?? ""
        }
        if let val = json["image4"]{
            self.imageUrl4 = (val as? String) ?? ""
        }
        if let val = json["image5"]{
            self.imageUrl5 = (val as? String) ?? ""
        }
        if let val = json["image6"]{
            self.imageUrl6 = (val as? String) ?? ""
        }
        if let val = json["about_me"]{
            self.about = (val as? String) ?? ""
        }
        if let val = json["latitude"]{
            self.latitude = (val as? Double) ?? 0
        }
        if let val = json["longitude"]{
            self.longitude = (val as? Double) ?? 0
        }
    }
    
    func encode(with aCoder: NSCoder) {
        let newDic = self.json.mutableCopy() as! NSMutableDictionary
        newDic.setValue(self.fbId, forKey: "fb_id")
        newDic.setValue(self.name, forKey: "name")
        newDic.setValue(self.gender, forKey: "gender")
        newDic.setValue(self.birthday, forKey: "birthday")
        newDic.setValue(self.age, forKey: "age")
        newDic.setValue(self.jobTitle, forKey: "job_title")
        newDic.setValue(self.token, forKey: "token")
        newDic.setValue(self.imageUrl1, forKey: "image1")
        newDic.setValue(self.imageUrl2, forKey: "image2")
        newDic.setValue(self.imageUrl3, forKey: "image3")
        newDic.setValue(self.imageUrl4, forKey: "image4")
        newDic.setValue(self.imageUrl5, forKey: "image5")
        newDic.setValue(self.imageUrl6, forKey: "image6")
        newDic.setValue(self.about, forKey: "about_me")
        newDic.setValue(self.latitude, forKey: "latitude")
        newDic.setValue(self.longitude, forKey: "longitude")
        aCoder.encode(newDic, forKey: "json")
    }
    
    required convenience init?(coder decoder:NSCoder) {
        self.init()
        let json = decoder.decodeObject(forKey: "json") as! NSDictionary
        self.initWithJSON(json: json)
    }

    func getDictionaryData() -> NSMutableDictionary  {
        let newDic = self.json.mutableCopy() as! NSMutableDictionary
        newDic.setValue(self.fbId, forKey: "fb_id")
        newDic.setValue(self.name, forKey: "name")
        newDic.setValue(self.gender, forKey: "gender")
        newDic.setValue(self.birthday, forKey: "birthday")
        newDic.setValue(self.age, forKey: "age")
        newDic.setValue(self.jobTitle, forKey: "job_title")
        newDic.setValue(self.token, forKey: "token")
        newDic.setValue(self.imageUrl1, forKey: "image1")
        newDic.setValue(self.imageUrl2, forKey: "image2")
        newDic.setValue(self.imageUrl3, forKey: "image3")
        newDic.setValue(self.imageUrl4, forKey: "image4")
        newDic.setValue(self.imageUrl5, forKey: "image5")
        newDic.setValue(self.imageUrl6, forKey: "image6")
        newDic.setValue(self.latitude, forKey: "latitude")
        newDic.setValue(self.longitude, forKey: "longitude")
        newDic.setValue(self.about, forKey: "about_me")
        return newDic
    }

}
