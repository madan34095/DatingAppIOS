//
//  PushNotificationSender.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/10/19.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
class PushNotificationSender {
    static func sendPushNotification(to token: String, title: String, body: String, content_type: String, content_id: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "priority":"high",
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : [
                                               "action_type" : content_type,
                                               "sender_id" : content_id
                                           ]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAyfaxazc:APA91bGPtE5Hz0rwzG5jnxwDi8k2X6DV3H888ieKkeUlY7pmEpDJLh1hpHjvXIi4y3AP149nhImGrwIOyp2CQBk_fCOpNg8TO6r7DViELaW17M6d3MewdMatEFEsb0lTseCGv4keXVUV", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
