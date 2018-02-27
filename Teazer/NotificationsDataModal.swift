//
//  NotificationsDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 06/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Alamofire

class NotificationsDataModal: AppDataModal {
    
    var notifications:[Notification]?
    var hasNext:Bool? = false
    var unreadCount: Int?
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            hasNext = responseDict["next_page"] as? Bool
            unreadCount = responseDict["unread_count"] as? Int
            
            if let notificationsList = responseDict["notifications"] as? [[String:Any]] {
                notifications = [Notification]()
                for notification in notificationsList {
                    var notificationModal = Notification()
                    notificationModal.notificationId = notification["notification_id"] as? Int
                    notificationModal.notificationType = notification["notification_type"] as? Int
                    notificationModal.sourceId = notification["source_id"] as? Int
                    notificationModal.accountType = notification["account_type"] as? Int
                    notificationModal.title = notification["title"] as? String
                    notificationModal.message = notification["message"] as? String
                    notificationModal.createdAtStr = notification["created_at"] as? String
                    notificationModal.hasProfileMedia = notification["has_profile_media"] as? Bool
                    notificationModal.highlights = notification["highlights"] as? [String]
                    notificationModal.isActioned = notification["is_actioned"] as? Bool
                    notificationModal.following = notification["following"] as? Bool
                    notificationModal.requestSent = notification["request_sent"] as? Bool

                    if let media = notification["profile_media"] as? [String:Any] {
                        var mediaModal = Media()
                        mediaModal.mediaId = media["media_id"] as? Int
                        mediaModal.mediaUrl = media["media_url"] as? String
                        mediaModal.thumbUrl = media["thumb_url"] as? String
                        mediaModal.duration = media["duration"] as? String
                        mediaModal.dimensions = media["dimension"] as? String
                        mediaModal.isImage = media["is_image"] as? Bool
                        mediaModal.views = media["views"] as? Int
                        mediaModal.createdAt = media["created_at"] as? TimeInterval
                        if let mediaDimensions = media["media_dimension"] as? [String:Any] {
                            mediaModal.width = mediaDimensions["width"] as? CGFloat
                            mediaModal.height = mediaDimensions["height"] as? CGFloat
                        
                        }
                        notificationModal.profileMedia = mediaModal
                    }
                    
                    if let metaData = notification["meta_data"] as? [String:Any]{
                        var metaDataModal = MetaData()
                        metaDataModal.notificationType = metaData["notification_type"] as? Int
                        metaDataModal.thumbUrl = metaData["thumb_url"] as? String
                        metaDataModal.fromId = metaData["from_id"] as? Int
                        metaDataModal.toId = metaData["to_id"] as? Int
                        metaDataModal.sourceId = metaData["source_id"] as? Int
                        
                        notificationModal.metaData = metaDataModal
                    }
                    notifications?.append(notificationModal)
                }
            }
        }
        
    }
    
}

struct Notification {
    
    var notificationId:Int?
    var notificationType:Int?
    var sourceId:Int?
    var accountType:Int?
    var metaData:MetaData?
    var title:String?
    var isActioned:Bool?
    var message:String?
    var createdAtStr:String?
    var hasProfileMedia:Bool? = false
    var profileMedia:Media?
    var highlights:[String]?
    var following:Bool?
    var requestSent:Bool?
}

struct MetaData {
    
    var notificationType:Int?
    var sourceId:Int?
    var toId: Int?
    var fromId: Int?
    var thumbUrl:String?
    
    
}


