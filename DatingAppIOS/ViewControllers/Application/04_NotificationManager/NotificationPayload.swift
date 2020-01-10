//
//  NotificationPayload.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/11/06.
//  Copyright © 2019 ADV. All rights reserved.
//

import Foundation
import SwiftyJSON
/** Sample payload style.
{
    "token" : "bk3RNwTe3H0:CI2k_HHwgIpoDKCIZvvDMExUdFQ3P1...",
    "notification" : {
      "body" : "This is an FCM notification that displays an image.!",
      "title" : "FCM Notification",
     },
     "apns": {
         "payload": {
             "aps": {
                 "content_type": "chat" or "alert",
                 "content_id": "user_id"
             }
         }
       }
 }
*/

struct NotificationPayload {
    private let json: JSON
    
    // TODO: 通知のペイロードで渡される各種dataを取り出せるようなプロパティを追加してください。
    /// ex.　以下例です
    /// 通知を受け取り、そこからの遷移先をenumで定義しています。
    enum NotificationTransitionDirection {
        case Chat(String)
        case Like(String)
        case Match(String)
        case Nowhere
    }
    
    enum ContentType: String {
        case Chat = "chat"
        case Like = "like"
        case Match = "match"
        case Nowhere = "nowhere"
    }
    
    private var contentId: String? { return json["sender_id"].string }
    private var contentType: String? { return json["content_type"].string }
    
    var content: ContentType {
        guard let raw = self.contentType, let contentType = ContentType(rawValue: raw) else { return .Nowhere }
        return contentType
    }
    
    var direction: NotificationTransitionDirection {
        guard let raw = self.contentType, let contentType = ContentType(rawValue: raw) else { return .Nowhere }
        
        switch contentType {
        case .Chat:
            guard let contentId = contentId else {
                return .Nowhere
            }
            return .Chat(contentId)
        case .Like:
            guard let contentId = contentId else {
                return .Nowhere
            }
            return .Like(contentId)
        case .Match:
            guard let contentId = contentId else {
                return .Nowhere
            }
            return .Match(contentId)
        default:
            return .Nowhere
        }
    }
    
    init(userInfo: [String: String]) {
        self.json = JSON(userInfo)
        print(userInfo)
        print(self.json)
    }
}
